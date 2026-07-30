(* Native `uuid` SQL primitive type fixture (#106). A table whose primary key is
 * a native `uuid` column, a plain column, and a NULLABLE `uuid` column. The
 * handler parses a canonical UUID with stringToUuid (given UPPERCASE input, to
 * exercise normalization), INSERTs it (including into the nullable column via an
 * `option uuid` injection), queries by uuid equality, SELECTs it back, and
 * renders it via uuidToString -- exercising sqlifyUuid (write, with the ::uuid
 * cast on Postgres), the option/nullable path (sql_option_prim + the Nullable
 * Uuid read path), and the unsql read path end to end. *)
table t : { Id : uuid, Label : string, Ref : option uuid }
    PRIMARY KEY Id

fun showOpt (r : option uuid) : string =
    case r of
        None => "none"
      | Some u => uuidToString u

fun main () : transaction page =
    case stringToUuid "550E8400-E29B-41D4-A716-446655440000" of
        None => return <xml><body>UUID_PARSE_FAILED</body></xml>
      | Some theId =>
        dml (DELETE FROM t WHERE t.Id = {[theId]});
        dml (INSERT INTO t (Id, Label, Ref) VALUES ({[theId]}, {["hello"]}, {[Some theId]}));
        rows <- queryX1 (SELECT t.Id, t.Label, t.Ref FROM t WHERE t.Id = {[theId]})
                        (fn r => <xml>{[uuidToString r.Id]}={[r.Label]},ref={[showOpt r.Ref]};</xml>);
        return <xml><body>UUID_ROUNDTRIP:{rows}</body></xml>
