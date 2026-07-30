(* Pins the post-COMMIT transactional contract (urweb/urweb#273; covers the
 * urweb/mail mechanism reported crashing in urweb/urweb#110):
 *   /ok   -- INSERT row 1, arm a NULL-rollback transactional whose commit
 *            callback records that it ran (post-COMMIT side effect, the email
 *            send-after-durable-write pattern). Request must succeed.
 *   /fail -- INSERT row 2, arm one whose commit callback FAILS after COMMIT.
 *            The request must fail with the callback's message, the page body
 *            must NOT render, and -- the #273 crux -- the row must STAY
 *            committed (no bogus SQL ROLLBACK on the already-committed txn).
 *   /check-- proves rows 1 AND 2 are durable, the ok callback ran, and the
 *            server survived the failing callback (this request is served). *)
table t : { Id : int, Lbl : string }
    PRIMARY KEY Id

fun ok () : transaction page =
    dml (DELETE FROM t WHERE t.Id = 1);
    dml (INSERT INTO t (Id, Lbl) VALUES (1, "okrow"));
    Postcommitffi.armOk;
    return <xml><body>OK_ARMED</body></xml>

fun fail () : transaction page =
    dml (DELETE FROM t WHERE t.Id = 2);
    dml (INSERT INTO t (Id, Lbl) VALUES (2, "failrow"));
    Postcommitffi.armFail;
    return <xml><body>FAIL_BODY_MUST_NOT_RENDER</body></xml>

fun check () : transaction page =
    r1 <- oneOrNoRows1 (SELECT t.Lbl FROM t WHERE t.Id = 1);
    r2 <- oneOrNoRows1 (SELECT t.Lbl FROM t WHERE t.Id = 2);
    ran <- Postcommitffi.okRan;
    return <xml><body>CHECK:r1={[case r1 of None => "none" | Some r => r.Lbl]},r2={[case r2 of None => "none" | Some r => r.Lbl]},cb={[ran]}</body></xml>
