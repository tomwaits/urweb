(* Regression pin for a compiler CRASH (uncaught UnboundRel) that the fork-#6
 * yankLets purity guard briefly introduced: the guard tested sibling fields
 * with the environment captured at the EField node, while yankLets had already
 * descended through ELet binders, so simpleImpure's ERel lookup ran past the
 * end of that environment. Compiling this at all is the test.
 *
 * The shape is load-bearing -- do NOT "simplify" it:
 *   - each let RHS must be NON-passive (a real call `g n`; `val a = 1` is an
 *     EPrim, hence passive, hence substituted away before yankLets sees it),
 *   - and used MORE THAN ONCE in the body (countFree > 1), so doLet declines
 *     to substitute and the chain survives,
 *   - and the projection must apply to the LET-CHAIN ITSELF ((mk 3).B), not to
 *     a let-bound record variable -- otherwise yankLets meets EField (ERel r,
 *     B) and takes the `_ =>` arm instead of walking the ELet spine,
 *   - and >= 2 lets must survive at a site nested under only one binder, so the
 *     required de Bruijn index outruns the outer environment.
 * Measured at the guard site here: depth=2, outerEnv=1, innerEnv=3 -- index 1
 * needed, outer env holds only index 0, hence UnboundRel 1.
 * tests/yk3 is the two-let control: it does NOT crash (index 0 still resolves)
 * and instead silently reads the WRONG binder -- the failure mode no test can
 * observe, which is exactly why this one must keep its three lets. *)
fun g (x : int) : int = x + 1

fun mk (n : int) : {A : int, B : int} =
    let
        val y1 = g n
        val y2 = g (y1 * y1)
        val y3 = g (y2 * y2)
    in
        {A = y1 * y2 * y3 * y1, B = 2}
    end

val v : int = (mk 3).B

fun main () : transaction page = return <xml><body>{[v]}</body></xml>
