MODULES := Axioms Name Syntax Semantics
VS      := $(MODULES:%=%.v)

.PHONY: coq check clean

coq: Makefile.coq
	$(MAKE) -f Makefile.coq

Makefile.coq: Makefile $(VS)
	coq_makefile -arg -impredicative-set $(VS) -o Makefile.coq

# Re-check the compiled proof terms in Coq's small trusted KERNEL, independently
# of the tactic engine that produced them. `coqc` succeeding only says the
# tactics ran; `coqchk` is what says the kernel accepts the resulting proofs.
# It also reports the axioms actually depended upon -- Axioms.v declares exactly
# one (ext_eq, functional extensionality).
check: coq
	coqchk -impredicative-set -R . Top Top.Semantics
	@# Assumptions.v both PINS the statements (it fails to compile if one is
	@# weakened or deleted) and reports the axiom set. Redirect rather than pipe:
	@# make has no pipefail, and piping through tee swallowed coqc's failure --
	@# deleting the interpreter went from red to green.
	coqc -impredicative-set -R . Top Assumptions.v > assumptions.out \
	  || { cat assumptions.out; rm -f assumptions.out; exit 1; }
	@cat assumptions.out
	@# Exact golden diff, not a regex: Coq only breaks an assumption's name onto
	@# its own line when `name : type` is long, so a pattern-based guard silently
	@# misses short-typed axioms and short Admitted statements.
	diff -u Assumptions.expected assumptions.out

clean:: Makefile.coq
	$(MAKE) -f Makefile.coq clean
	rm -f Makefile.coq assumptions.out Assumptions.vo Assumptions.vok Assumptions.vos Assumptions.glob .Assumptions.aux
