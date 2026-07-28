(* SQL-DSL regression guard (self-contained, current syntax). A spread of
 * VALID queries that must typecheck both before and after the #269 fix, so a
 * regression in the query type layer (sql_query/sql_order_by/aggregates/set
 * ops) surfaces. Deliberately avoids the two #269 behaviours that change --
 * ORDER BY on an ungrouped column, and an aggregate in ORDER BY -- so this
 * fixture stays stable across that fix; those cases live in the #269 PR. The
 * `: sql_query [] [] _ _` annotations pin the phantom free/afree parameters
 * (as tests/agg.ur does), since these top-level bindings have no use to do so. *)
table t : {A : int, B : string, C : float}
table u : {A : int, D : int}

(* plain SELECT: WHERE, ORDER BY (multiple, ASC/DESC), ORDER BY an AS-alias *)
val q_plain  : sql_query [] [] _ _ = (SELECT t.A, t.B FROM t WHERE t.A > 0 ORDER BY t.A, t.B DESC)
val q_alias  : sql_query [] [] _ _ = (SELECT t.A, t.A < 5 AS Lt FROM t ORDER BY Lt ASC, t.A DESC)

(* aggregates in SELECT *)
val q_agg    : sql_query [] [] _ _ = (SELECT COUNT( * ) AS N, MIN(t.A) AS Mn, MAX(t.A) AS Mx,
                                             SUM(t.C) AS S, AVG(t.C) AS Av FROM t)

(* GROUP BY: select a grouped column + aggregate; ORDER BY the grouped column
 * (valid before and after #269) *)
val q_group  : sql_query [] [] _ _ = (SELECT t.B, COUNT( * ) AS N FROM t GROUP BY t.B ORDER BY t.B)

(* comma join *)
val q_join   : sql_query [] [] _ _ = (SELECT t.A, u.D FROM t, u WHERE t.A = u.A ORDER BY t.A, u.D)

(* UNION (both sides share a row shape, as set ops require). INTERSECT/EXCEPT
 * coverage lives in the relops fixture; scalar subqueries in the subquery one. *)
val q_union  : sql_query [] [] _ _ = (SELECT t.A FROM t WHERE t.A > 0 UNION SELECT t.A FROM t WHERE t.A < 0)

(* LIMIT / OFFSET *)
val q_limit  : sql_query [] [] _ _ = (SELECT t.A FROM t ORDER BY t.A LIMIT 5 OFFSET 2)
