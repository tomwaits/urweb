(* Regression (urweb/urweb#271, tightening half): '/' is NOT a legal HTTP
 * header-name character (RFC 7230 token), but the old check reused validMime,
 * which permits '/'. bless*Header on such a name must be REJECTED at compile
 * time. Same minimal shape as hdrtok (getHeader in a page -- no form/action,
 * so nothing but the character check can fail); the .urp wildcard makes the
 * rule-list half always pass. All four header functions share the validHeader
 * predicate, so exercising the request path covers the response path too. *)
fun main () : transaction page =
  ag <- getHeader (blessRequestHeader "X/Bad");
  return <xml><body>{[ag]}</body></xml>
