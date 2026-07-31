(* fork issue #3: the #221 fix is syntactic, so an abort reached through a
 * NAMED call was still discarded -- `let val _ = f () in b end` where f always
 * errors. boom is deliberately LARGE and called TWICE so mayInline will not
 * inline it away (inlining is what masks this in practice, per the issue), and
 * both results are UNUSED so the bindings are DCE candidates. The abort must
 * therefore be seen interprocedurally (the abortSyms fixpoint). Serving this
 * page must abort with the marker, never render the body. *)
fun boom (n : int) : int =
    let
        val a = n + 1
        val b = a * 2
        val c = b + a
        val d = c * 3
        val e = d + b
        val f = e * 5
        val g = f + d
        val h = g * 7
    in
        if h > 0 then
            error <xml>Do not drop my interprocedural abort</xml>
        else
            error <xml>Do not drop my interprocedural abort</xml>
    end

fun main () : transaction page =
    let
        val unused1 = boom 1
        val unused2 = boom 2
    in
        return <xml><body>INTERPROCEDURAL_ABORT_DROPPED</body></xml>
    end
