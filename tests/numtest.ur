(* Native `numeric` SQL primitive: exact decimal stored in a real numeric column
 * (Postgres numeric(65,30) / MySQL decimal(65,30) / SQLite text), never floating
 * point.  Held as a canonical decimal string.  Covers:
 *   - normalization of redundant zeros ("-12.50" -> "-12.5", "0.00100" -> "0.001")
 *   - a NOT NULL + a nullable `option numeric`, queried BY numeric equality
 *   - a high-precision value at the bound (30 fractional digits) round-tripping
 *     EXACTLY (proves no precision is lost within the supported range, and that
 *     the read normalizes MySQL's decimal(65,30) padding back to canonical form)
 *   - an OVER-precision value (31 fractional digits) being REJECTED (None), so
 *     it fails loudly and uniformly instead of MySQL silently rounding it. *)
table t : { Id : int, N : numeric, Opt : option numeric }
    PRIMARY KEY Id

fun optStr (r : option numeric) : string =
    case r of
        None => "none"
      | Some x => numericToString x

fun main () : transaction page =
    let
        val over = case stringToNumeric "0.0000000000000000000000000000001" of
                       None => "rej"
                     | Some _ => "ACCEPTED_BUG"
    in
        case stringToNumeric "-12.50" of
            None => return <xml><body>PARSE_FAIL_N</body></xml>
          | Some n =>
            case stringToNumeric "0.00100" of
                None => return <xml><body>PARSE_FAIL_M</body></xml>
              | Some m =>
                case stringToNumeric "123.123456789012345678901234567891" of
                    None => return <xml><body>PARSE_FAIL_HP</body></xml>
                  | Some hp =>
                    dml (DELETE FROM t WHERE t.Id = 1);
                    dml (DELETE FROM t WHERE t.Id = 2);
                    dml (INSERT INTO t (Id, N, Opt) VALUES (1, {[n]}, {[Some m]}));
                    dml (INSERT INTO t (Id, N, Opt) VALUES (2, {[hp]}, {[None]}));
                    r1 <- queryX1 (SELECT t.N, t.Opt FROM t WHERE t.N = {[n]})
                                  (fn r => <xml>{[numericToString r.N]},opt={[optStr r.Opt]}</xml>);
                    r2 <- queryX1 (SELECT t.N FROM t WHERE t.Id = 2)
                                  (fn r => <xml>{[numericToString r.N]}</xml>);
                    return <xml><body>NUM_ROUNDTRIP:{r1};hp={r2};over={[over]}</body></xml>
    end
