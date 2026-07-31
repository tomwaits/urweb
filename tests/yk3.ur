(* Two-let control for tests/yk2 (the yankLets wrong-environment crash pin).
 * Same shape, one fewer surviving let: the required de Bruijn index is 0, which
 * still resolves, so this does NOT crash -- it silently reads the WRONG
 * binder's type instead. It must keep COMPILING; its job is to be the tripwire
 * against anyone "simplifying" yk2 down to two lets and quietly losing the
 * crash coverage. *)
fun g (x : int) : int = x + 1

fun mk (n : int) : {A : int, B : int} =
    let
        val y1 = g n
        val y2 = g (y1 * y1)

    in
        {A = y1 * y2 * y1, B = 2}
    end

val v : int = (mk 3).B

fun main () : transaction page = return <xml><body>{[v]}</body></xml>
