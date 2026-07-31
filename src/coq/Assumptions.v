(* What the soundness development ASSUMES, and what it SAYS.
 *
 * Two independent guards, because they catch different failures:
 *
 * 1. The `Definition pin_* : <statement> := @thm` lines below fail at COMPILE
 *    time if a theorem's statement is weakened or a constant is deleted.
 *    `Print Assumptions` checks only what a theorem RESTS on, never what it
 *    SAYS -- so without these, `disj_correct` could be restated as `-> True`,
 *    or the entire interpreter deleted, with every other check still green.
 *
 * 2. `Print Assumptions` then reports the axioms each result depends on. CI
 *    diffs that output against Assumptions.expected, an exact golden. A regex
 *    was tried first and was WRONG: Coq breaks an assumption's name onto its
 *    own line only when `name : type` exceeds the print width, so short-typed
 *    axioms -- and Admitted theorems with short statements -- printed on one
 *    line and slipped through. An exact diff is fail-CLOSED on any output
 *    change, which is the correct direction for a soundness gate. *)
Require Import Top.Syntax.
Require Import Top.Semantics.

Definition pin_subs_correct
  : forall (k1 : kind) (c1 : con kDen k1) (k2 : kind)
           (c2 : kDen k1 -> con kDen k2) (c2' : con kDen k2),
      subs c1 c2 c2' -> cDen (c2 (cDen c1)) = cDen c2'
  := @subs_correct.

Definition pin_deq_correct
  : forall (k : kind) (c1 c2 : con kDen k), deq dvar c1 c2 -> cDen c1 = cDen c2
  := @deq_correct.

Definition pin_disj_correct
  : forall (k : kind) (c1 c2 : con kDen (KRecord k)),
      disj dvar c1 c2 -> disjoint (cDen c1) (cDen c2)
  := @disj_correct.

Definition pin_cut_disjoint
  : forall (n1 : name) (v : Set) (r : row Set),
      disjoint (fun n : name => if name_eq_dec n n1 then Some v else None) r
      -> unit = match r n1 with Some T => T | None => unit end
  := @cut_disjoint.

Definition pin_name_eq_dec_refl
  : forall n : name, name_eq_dec n n = left eq_refl := @name_eq_dec_refl.

(* THE soundness statement: every well-typed term denotes a value of its
 * denoted type, i.e. the interpreter is a TOTAL Coq function. Without this pin
 * the whole expression language could be deleted and CI would stay green. *)
Definition pin_eDen
  : forall t : con kDen KType, exp dvar tDen t -> tDen t := @eDen.

Print Assumptions subs_correct.
Print Assumptions deq_correct.
Print Assumptions disj_correct.
Print Assumptions cut_disjoint.
Print Assumptions name_eq_dec_refl.
Print Assumptions eDen.
