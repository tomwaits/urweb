(* Work around a correctness bug in the smlnj-lib that ships with recent MLton
 * releases.  In the smlnj-lib snapshot bundled with MLton 20241230 (SML/NJ
 * 2025.1), IntBinarySet's `union`, `intersection`, and `difference` return
 * corrupted trees -- e.g. `difference {1,2,3,4,5} {3,4,5,6,7}` yields a 24-node
 * garbage set instead of {1,2}.  This is smlnj/smlnj#310, fixed upstream in
 * SML/NJ 2025.2 but not yet in a MLton release; MLton 20210117 predates the
 * regression and is unaffected.
 *
 * The bug is specific to the hand-written integer specialization
 * (int-binary-set.sml); the generic BinarySetFn, IntBinaryMap, and BinaryMapFn
 * are correct.  urweb leans on these three set operations inside fixpoints
 * (reachability in core_untangle, effect/dependency analyses, sqlcache, ...),
 * so a corrupted result is not merely slow -- a wrong `difference` makes those
 * fixpoints diverge or converge to the wrong answer.
 *
 * We shadow IntBinarySet, re-deriving the three bulk operations from the
 * point operations (`foldl`/`add`/`member`), which are correct on every MLton.
 * This keeps urweb building correctly and quickly on any MLton version.  Cost
 * is O(n log n) -- negligible at the set sizes urweb produces.  When a MLton
 * release ships the SML/NJ 2025.2 fix, this file can simply be removed. *)

structure IntBinarySet =
struct
    structure Orig = IntBinarySet

    open Orig

    fun union (s1, s2) =
        Orig.foldl (fn (x, s) => Orig.add (s, x)) s2 s1

    fun intersection (s1, s2) =
        Orig.foldl (fn (x, s) => if Orig.member (s2, x) then Orig.add (s, x) else s)
                   Orig.empty s1

    fun difference (s1, s2) =
        Orig.foldl (fn (x, s) => if Orig.member (s2, x) then s else Orig.add (s, x))
                   Orig.empty s1
end
