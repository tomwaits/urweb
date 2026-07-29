(* Native `uuid` SQL primitive type fixture (#106). A table whose primary key is
 * a native `uuid` column plus a plain column. The handler parses a canonical
 * UUID with stringToUuid (given UPPERCASE input, to exercise normalization),
 * INSERTs it, queries by uuid equality, SELECTs it back, and renders it via
 * uuidToString -- exercising sqlifyUuid (write, with the ::uuid cast on
 * Postgres) and the unsql read path end to end. *)
table t : { Id : uuid, Label : string }
    PRIMARY KEY Id

fun main () : transaction page =
    case stringToUuid "550E8400-E29B-41D4-A716-446655440000" of
        None => return <xml><body>UUID_PARSE_FAILED</body></xml>
      | Some theId =>
        dml (DELETE FROM t WHERE t.Id = {[theId]});
        dml (INSERT INTO t (Id, Label) VALUES ({[theId]}, {["hello"]}));
        rows <- queryX1 (SELECT t.Id, t.Label FROM t WHERE t.Id = {[theId]})
                        (fn r => <xml>{[uuidToString r.Id]}={[r.Label]};</xml>);
        return <xml><body>UUID_ROUNDTRIP:{rows}</body></xml>
