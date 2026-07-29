(* urweb/urweb#259: the blockquote tag must be available in the standard
 * library. Typechecking this at all is the test -- it fails to elaborate on a
 * compiler whose basis.urs lacks `val blockquote`. *)
fun main () : transaction page =
    return <xml><body><blockquote>A quotation.</blockquote></body></xml>
