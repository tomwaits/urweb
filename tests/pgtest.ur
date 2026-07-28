(* Postgres runtime integration fixture. Exercised by the postgres-integration
 * CI job against a live Postgres. Two tables and a view so the startup
 * schema-structure check (urweb/urweb#230) validates MULTIPLE relations and a
 * view -- the case the collapsed-query refactor optimizes. Running the binary
 * at all means that check passed; the response also round-trips an INSERT/
 * SELECT through each relation, including a `time` column (urweb/urweb#163). *)
table t : { Id : int, Name : string, When : time }
    PRIMARY KEY Id
table u : { Uid : int, Note : string }
    PRIMARY KEY Uid
view v = SELECT t.Id AS Vid, t.Name AS Vname FROM t

fun main () : transaction page =
    n <- now;
    dml (DELETE FROM t WHERE t.Id = {[1]});
    dml (INSERT INTO t (Id, Name, When) VALUES ({[1]}, {["hello"]}, {[n]}));
    dml (DELETE FROM u WHERE u.Uid = {[1]});
    dml (INSERT INTO u (Uid, Note) VALUES ({[1]}, {["note"]}));
    trows <- queryX1 (SELECT t.Id, t.Name FROM t ORDER BY t.Id)
                     (fn r => <xml>t{[r.Id]}={[r.Name]};</xml>);
    urows <- queryX1 (SELECT u.Uid, u.Note FROM u ORDER BY u.Uid)
                     (fn r => <xml>u{[r.Uid]}={[r.Note]};</xml>);
    vrows <- queryX (SELECT * FROM v)
                    (fn r => <xml>v{[r.V.Vid]}={[r.V.Vname]};</xml>);
    return <xml><body>{trows}{urows}{vrows}</body></xml>
