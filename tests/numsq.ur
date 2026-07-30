(* SQLite performs numeric arithmetic in binary double, so an in-range value with
 * >15 significant digits is FLOAT-APPROXIMATE (documented in basis.urs).  This
 * pins that (inexact) contract so it cannot silently change. *)
table t : { Id : int, A : numeric, B : numeric }
    PRIMARY KEY Id
fun main () : transaction page =
    case (stringToNumeric "1.2345678901234567890123456789", stringToNumeric "1") of
        (Some a, Some b) =>
        dml (DELETE FROM t WHERE t.Id = 1);
        dml (INSERT INTO t (Id, A, B) VALUES (1, {[a]}, {[b]}));
        rows <- queryX (SELECT (t.A + t.B) AS S FROM t WHERE t.Id = 1)
                       (fn r => <xml>{[numericToString r.S]}</xml>);
        return <xml><body>SQ:{rows}</body></xml>
      | _ => return <xml><body>PARSE_FAIL</body></xml>
