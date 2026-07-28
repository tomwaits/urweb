(* Postgres runtime integration fixture. Exercised by the postgres-integration
 * CI job against a live Postgres: compiling with -dbms postgres emits the
 * schema, and RUNNING the binary performs the startup schema-structure check
 * (urweb/urweb#230) then serves a request that INSERTs and SELECTs, including a
 * `time` column (the surface for the timezone work, urweb/urweb#163). This is
 * the runtime ground truth the sqlite-only `make test` cannot reach. *)
table t : { Id : int, Name : string, When : time }
    PRIMARY KEY Id

fun main () : transaction page =
    n <- now;
    dml (DELETE FROM t WHERE t.Id = {[1]});
    dml (INSERT INTO t (Id, Name, When) VALUES ({[1]}, {["hello"]}, {[n]}));
    rows <- queryX1 (SELECT t.Id, t.Name FROM t ORDER BY t.Id)
                    (fn r => <xml>{[r.Id]}={[r.Name]};</xml>);
    return <xml><body>{rows}</body></xml>
