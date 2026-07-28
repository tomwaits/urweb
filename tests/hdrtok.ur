(* Regression (urweb/urweb#271, widening half): an RFC 7230 token character
 * such as '_' is a valid HTTP header-name character and must be accepted.
 * The old check reused validMime, which rejects '_', so this failed to
 * compile. The harness compiles this fully and asserts it produces an
 * executable, so the acceptance is actually exercised (not vacuously green). *)
fun main () : transaction page =
  ag <- getHeader (blessRequestHeader "X-Trace_Id");
  return <xml><body>{[ag]}</body></xml>
