/* FFI module pinning the post-COMMIT transactional contract (urweb/urweb#273,
 * which also covers the urweb/mail mechanism behind urweb/urweb#110): a
 * transactional registered with a NULL rollback runs its commit callback AFTER
 * the SQL COMMIT; a FAILURE there (uw_set_error_message) must fail the request
 * WITHOUT issuing a bogus SQL ROLLBACK (the row stays committed) and without
 * crashing the server. ctx is passed as the callback data pointer, the same
 * pattern the in-tree Sqlcache transactional uses. */
#include <urweb.h>

static int ok_ran = 0;

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

uw_unit uw_Postcommitffi_armOk(struct uw_context *ctx) {
  uw_register_transactional(ctx, ctx, ok_commit, NULL, noop_free);
  return 0;
}

uw_unit uw_Postcommitffi_armFail(struct uw_context *ctx) {
  uw_register_transactional(ctx, ctx, fail_commit, NULL, noop_free);
  return 0;
}

uw_Basis_bool uw_Postcommitffi_okRan(struct uw_context *ctx) {
  (void)ctx;
  return ok_ran ? uw_Basis_True : uw_Basis_False;
}
