(* Native `numeric` SQL primitive: exact decimal stored in a real numeric column
 * (Postgres numeric / MySQL decimal / SQLite text), never floating point.  Held
 * as a canonical decimal string.  This fixture parses decimals with redundant
 * zeros (checking normalization: "-12.50" -> "-12.5", "0.00100" -> "0.001"),
 * stores a NOT NULL and a nullable `option numeric`, queries back BY numeric
 * equality (the WHERE-parameter path + that a bound value equals an inlined
 * literal), and renders via numericToString -- so the read path (which must
 * normalize MySQL's trailing-zero padding back to canonical form) is covered. *)
table t : { Id : int, N : numeric, Opt : option numeric }
    PRIMARY KEY Id

fun optStr (r : option numeric) : string =
    case r of
        None => "none"
      | Some x => numericToString x

fun main () : transaction page =
    case stringToNumeric "-12.50" of
        None => return <xml><body>PARSE_FAIL_N</body></xml>
      | Some n =>
        case stringToNumeric "0.00100" of
            None => return <xml><body>PARSE_FAIL_M</body></xml>
          | Some m =>
            dml (DELETE FROM t WHERE t.Id = 1);
            dml (INSERT INTO t (Id, N, Opt) VALUES (1, {[n]}, {[Some m]}));
            rows <- queryX1 (SELECT t.N, t.Opt FROM t WHERE t.N = {[n]})
                            (fn r => <xml>{[numericToString r.N]},opt={[optStr r.Opt]}</xml>);
            return <xml><body>NUM_ROUNDTRIP:{rows}</body></xml>
