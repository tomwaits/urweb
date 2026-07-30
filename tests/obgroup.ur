(* urweb/urweb#269 (fixed): ORDER BY now types like Having -- bare columns come
 * from the GROUPED set and aggregates over the underlying tables. This module
 * must KEEP typechecking: ORDER BY a grouped column, ORDER BY an aggregate
 * (the previously-REJECTED valid form), and ORDER BY on an ungrouped query. *)
table t : { A : int, B : int }

fun grouped () : transaction page =
    r <- queryX1 (SELECT t.A FROM t GROUP BY t.A ORDER BY t.A)
                 (fn r => <xml>{[r.A]};</xml>);
    return <xml><body>{r}</body></xml>

fun byAggregate () : transaction page =
    r <- queryX1 (SELECT t.A FROM t GROUP BY t.A ORDER BY COUNT( * ) DESC, t.A)
                 (fn r => <xml>{[r.A]};</xml>);
    return <xml><body>{r}</body></xml>

fun ungrouped () : transaction page =
    r <- queryX1 (SELECT t.A FROM t ORDER BY t.B)
                 (fn r => <xml>{[r.A]};</xml>);
    return <xml><body>{r}</body></xml>
