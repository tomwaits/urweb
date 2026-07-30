(* urweb/urweb#269 (fixed): ORDER BY now types like Having -- bare columns come
 * from the GROUPED set and aggregates over the underlying tables. This module
 * must KEEP typechecking: ORDER BY a grouped column, ORDER BY aggregates --
 * SUM(t.B) is the true differential (an aggregate over a column constrains the
 * agg row, so the OLD compiler rejected it; COUNT( * ) never did) -- and ORDER
 * BY on an ungrouped query.
 *
 * Known pre-existing holes, shared with Having and NOT introduced or fixed by
 * #269: implicit aggregation (SELECT COUNT( * ) FROM t ORDER BY t.B typechecks
 * because an absent GROUP BY pins grouped = tables) and SELECT DISTINCT's
 * ORDER-BY-must-be-selected rule are still unchecked; Postgres rejects both at
 * runtime. *)
table t : { A : int, B : int }

fun grouped () : transaction page =
    r <- queryX1 (SELECT t.A FROM t GROUP BY t.A ORDER BY t.A)
                 (fn r => <xml>{[r.A]};</xml>);
    return <xml><body>{r}</body></xml>

fun byAggregate () : transaction page =
    r <- queryX1 (SELECT t.A FROM t GROUP BY t.A ORDER BY COUNT( * ) DESC, SUM(t.B), t.A)
                 (fn r => <xml>{[r.A]};</xml>);
    return <xml><body>{r}</body></xml>

fun ungrouped () : transaction page =
    r <- queryX1 (SELECT t.A FROM t ORDER BY t.B)
                 (fn r => <xml>{[r.A]};</xml>);
    return <xml><body>{r}</body></xml>
