(* SQL-side exact arithmetic on numeric columns: the database computes A+B, A-B,
 * A*B on native numeric/decimal, and the results round-trip through numeric. *)
table t : { Id : int, A : numeric, B : numeric }
    PRIMARY KEY Id

fun main () : transaction page =
    case (stringToNumeric "10.50", stringToNumeric "3.25") of
        (Some a, Some b) =>
        dml (DELETE FROM t WHERE t.Id = 1);
        dml (INSERT INTO t (Id, A, B) VALUES (1, {[a]}, {[b]}));
        rows <- queryX (SELECT (t.A + t.B) AS Sm, (t.A - t.B) AS Df, (t.A * t.B) AS Pr
                        FROM t WHERE t.Id = 1)
                       (fn r => <xml>sum={[numericToString r.Sm]},diff={[numericToString r.Df]},prod={[numericToString r.Pr]}</xml>);
        return <xml><body>NUM_ARITH:{rows}</body></xml>
      | _ => return <xml><body>PARSE_FAIL</body></xml>
