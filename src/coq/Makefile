MODULES := Axioms Name Syntax Semantics
VS      := $(MODULES:%=%.v)

.PHONY: coq check clean

coq: Makefile.coq
	make -f Makefile.coq

Makefile.coq: Makefile $(VS)
	coq_makefile -arg -impredicative-set $(VS) -o Makefile.coq

# Re-check the compiled proof terms in Coq's small trusted KERNEL, independently
# of the tactic engine that produced them. `coqc` succeeding only says the
# tactics ran; `coqchk` is what says the kernel accepts the resulting proofs.
# It also reports the axioms actually depended upon -- Axioms.v declares exactly
# one (ext_eq, functional extensionality).
check: coq
	coqchk -impredicative-set -R . Top Top.Semantics
	@# Report (and let CI assert) exactly which axioms the theorems depend on.
	coqc -impredicative-set -R . Top Assumptions.v

clean:: Makefile.coq
	make -f Makefile.coq clean
	rm -f Makefile.coq
