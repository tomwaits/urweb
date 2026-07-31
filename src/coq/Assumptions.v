(* Machine-checked statement of what the soundness proof ASSUMES.
 *
 * `Print Assumptions` walks each theorem's proof term and reports every axiom
 * it actually depends on -- including anything introduced by `Admitted`, which
 * appears here as an axiom. CI greps this output and fails if any assumption
 * other than Axioms.ext_eq (functional extensionality) shows up, so a proof
 * cannot be quietly weakened by admitting a lemma or adding an axiom.
 *
 * "Theory: Set is impredicative" is not an axiom; it records the
 * -impredicative-set flag the development is built with. *)
Require Import Top.Semantics.

Print Assumptions subs_correct.
Print Assumptions deq_correct.
Print Assumptions disj_correct.
Print Assumptions cut_disjoint.
Print Assumptions name_eq_dec_refl.
