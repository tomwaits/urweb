(* Verifies urweb/urweb#222: Basis.setResponseStatus sets the HTTP response
 * status code. The harness serves this and greps the status line. Two distinct
 * codes (404, 429) are served from two handlers so the test proves the emitted
 * code tracks the argument rather than a hardcoded value. safeGet whitelists
 * the side-effecting GETs. *)

fun notFound () : transaction page =
    setResponseStatus 404;
    return <xml><body>nope</body></xml>

fun tooMany () : transaction page =
    setResponseStatus 429;
    return <xml><body>slow down</body></xml>
