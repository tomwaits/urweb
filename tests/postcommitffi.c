/* FFI module pinning the post-COMMIT transactional contract (urweb/urweb#273,
 * which also covers the urweb/mail mechanism behind urweb/urweb#110): a
 * transactional registered with a NULL rollback runs its commit callback AFTER
 * the SQL COMMIT; a FAILURE there (uw_set_error_message) must fail the request
 * WITHOUT issuing a bogus SQL ROLLBACK (the row stays committed) and without
 * crashing the server. ctx is passed as the callback data pointer, the same
 * pattern the in-tree Sqlcache transactional uses. */
#include <urweb.h>

static int ok_ran = 0;

/* Counts free() invocations for the FAILING transactional, pinning the
 * free-EXACTLY-ONCE half of the uw_register_transactional contract.
 *
 * Honest scope (an adversarial review corrected an earlier, wrong claim here):
 * this assertion is NOT differential for fork #7's pre-fix double-fire on the
 * ordinary request path -- request.c's uw_reset_keep_error_message already
 * zeroes used_transactionals before any try_rollback, so that path never
 * double-fired. The genuinely reachable pre-fix double-fires were
 * uw_initialize's startup COMMIT-serialization path and any raw C-API
 * embedder that calls uw_commit then uw_rollback. What this test does is pin
 * the contract itself, so a future change to the sweep/consume discipline that
 * DOES break the common path fails loudly here. */
static int fail_free_count = 0;

static void ok_commit(void *data) {
  (void)data;
  ok_ran = 1;
}

static void fail_commit(void *data) {
  uw_set_error_message((struct uw_context *)data, "POSTCOMMIT_FAILURE_MARKER");
}

static void noop_free(void *data, int will_retry) {
  (void)data;
  (void)will_retry;
}

static void fail_free(void *data, int will_retry) {
  (void)data;
  (void)will_retry;
  ++fail_free_count;
}

uw_unit uw_Postcommitffi_armOk(struct uw_context *ctx) {
  uw_register_transactional(ctx, ctx, ok_commit, NULL, noop_free);
  return 0;
}

uw_unit uw_Postcommitffi_armFail(struct uw_context *ctx) {
  uw_register_transactional(ctx, ctx, fail_commit, NULL, fail_free);
  return 0;
}

uw_Basis_int uw_Postcommitffi_failFreeCount(struct uw_context *ctx) {
  (void)ctx;
  return fail_free_count;
}

uw_Basis_bool uw_Postcommitffi_okRan(struct uw_context *ctx) {
  (void)ctx;
  return ok_ran ? uw_Basis_True : uw_Basis_False;
}
