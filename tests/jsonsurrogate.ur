(* DIAG: compare fromJson of a COMPILE-TIME CONSTANT literal vs a RUNTIME-built
 * string (prefixed with an always-"" value the compiler can't fold away).
 * If const decodes to "U" but runtime decodes to 4 bytes, urweb is mis-folding
 * the recursive unescape at compile time (a pre-existing optimizer bug), and
 * the #211 fix is correct at runtime. *)
val decodedConst : string = Json.fromJson "\"\\uD83D\\uDE00\""

fun main () : transaction page =
    t <- now;
    let
        val pfx = if toSeconds t < 0 then "x" else ""
        val decodedRT : string = Json.fromJson (pfx ^ "\"\\uD83D\\uDE00\"")
    in
        return <xml><body>
          <p>CONST bytes={[strlenUtf8 decodedConst]} cp={[strlen decodedConst]}</p>
          <p>RUNTIME bytes={[strlenUtf8 decodedRT]} cp={[strlen decodedRT]} {[if strlenUtf8 decodedRT = 4 && strlen decodedRT = 1 then "SURROGATE_PAIR_OK" else "SURROGATE_PAIR_BAD"]}</p>
        </body></xml>
    end
