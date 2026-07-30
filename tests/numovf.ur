(* Edge case: a product whose scale exceeds numeric's 30 fractional digits.
 * Pins the per-backend divergence: Postgres computes full scale and REJECTS the
 * out-of-range result loudly on read; MySQL silently rounds to scale 30. *)
table t : { Id : int, A : numeric, B : numeric }
    PRIMARY KEY Id
fun main () : transaction page =
    case (stringToNumeric "1.00000000000000000001", stringToNumeric "1.00000000000000000001") of
        (Some a, Some b) =>
        dml (DELETE FROM t WHERE t.Id = 1);
        dml (INSERT INTO t (Id, A, B) VALUES (1, {[a]}, {[b]}));
        rows <- queryX (SELECT (t.A * t.B) AS P FROM t WHERE t.Id = 1)
                       (fn r => <xml>{[numericToString r.P]}</xml>);
        return <xml><body>OVF:{rows}</body></xml>
      | _ => return <xml><body>PARSE_FAIL</body></xml>
