(* urweb/urweb#39: a custom 404 page via the `notFoundPage` .urp directive.
 * `main` is the only route; any other URL hits the dispatcher's 404 fallthrough,
 * which must serve the custom body (see tests/notfound.urp) as text/html. *)
fun main () : transaction page = return <xml><body>home</body></xml>
