(* fork #17: findTableForCunifsError's table diff went to STDOUT via `print`,
 * while every other diagnostic uses stderr (eprefaces/ErrorMsg). On stdout it
 * interleaves with program output and vanishes from the usual `2>` capture --
 * so a developer redirecting stderr silently lost the most useful part of the
 * message. The make-test check discards stdout and greps stderr, which is
 * exactly the discrimination that fails on the pre-fix compiler. *)
table t : { A : int, B : string }

fun main () : transaction page =
    xs <- queryX (SELECT t.A, t.C FROM t) (fn r => <xml/>);
    return <xml/>
