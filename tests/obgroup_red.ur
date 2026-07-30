(* urweb/urweb#269's accepts-invalid half: ORDER BY on a bare column that is
 * NOT in the GROUP BY set. Postgres rejects this at runtime; since the #269
 * fix the type system rejects it at compile time. make test asserts this
 * module FAILS to elaborate. *)
table t : { A : int, B : int }

fun main () : transaction page =
    r <- queryX1 (SELECT t.A FROM t GROUP BY t.A ORDER BY t.B)
                 (fn r => <xml>{[r.A]};</xml>);
    return <xml><body>{r}</body></xml>
