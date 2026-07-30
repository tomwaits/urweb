(* Native `timeOfDay` SQL primitive type fixture.
 *
 * Part 1 (validation battery): asserts that stringToTimeOfDay accepts exactly a
 * 24-hour wall-clock time (00:00:00 .. 23:59:59, whole seconds) and rejects the
 * impossible ones -- hour 24, minute/second 60 (a leap second), a fractional
 * part, and any non-HH:MM:SS shape.  A correct uw_timeOfDay_valid emits no BAD_
 * marker.
 *
 * Part 2 (round-trip): a table whose primary key is a native `time` column, a
 * plain column, and a NULLABLE `time` column.  Three rows exercise, together,
 * the 00:00:00 and 23:59:59 boundaries, a NULL nullable value (the Nullable
 * TimeOfDay None branch), and Some nullable values -- INSERTed, queried by time
 * equality, SELECTed back, and rendered via timeOfDayToString.  Exercises the
 * write path (the value is bound as a prepared-statement parameter, with the
 * codegen'd `::time` cast on Postgres), the option/nullable path, and the unsql
 * read/validation path end to end.  (These static queries are prepared, so the
 * interpreted sqlifyTimeOfDay literal-writer -- used only for non-prepared
 * dynamic SQL -- is not the path under test here.) *)
table t : { Id : timeOfDay, Label : string, Ref : option timeOfDay }
    PRIMARY KEY Id

(* [s] must PARSE; emit a marker if it is wrongly rejected. *)
fun expectSome (s : string) : xbody =
    case stringToTimeOfDay s of
        Some _ => <xml></xml>
      | None => <xml>BAD_REJECT:{[s]};</xml>

(* [s] must be REJECTED; emit a marker if it is wrongly accepted. *)
fun expectNone (s : string) : xbody =
    case stringToTimeOfDay s of
        None => <xml></xml>
      | Some _ => <xml>BAD_ACCEPT:{[s]};</xml>

fun validationBattery () : xbody = <xml>
    {expectSome "00:00:00"}   (* midnight, lower boundary *)
    {expectSome "23:59:59"}   (* last valid instant, upper boundary *)
    {expectSome "12:30:45"}   (* an ordinary time *)
    {expectNone "24:00:00"}   (* hour 24 is not a wall-clock time-of-day *)
    {expectNone "23:60:00"}   (* minute 60 *)
    {expectNone "23:59:60"}   (* second 60 (leap second) *)
    {expectNone "12:30:45.5"} (* fractional part: wrong shape *)
    {expectNone "1:30:45"}    (* hour not zero-padded (wrong length) *)
    {expectNone "12:30"}      (* too short *)
    {expectNone "12-30-45"}   (* wrong separators *)
    {expectNone "aa:bb:cc"}   (* garbage *)
    {expectNone ""}           (* empty *)
</xml>

fun showOpt (r : option timeOfDay) : string =
    case r of
        None => "none"
      | Some tod => timeOfDayToString tod

fun main () : transaction page =
    case (stringToTimeOfDay "00:00:00", stringToTimeOfDay "12:30:45", stringToTimeOfDay "23:59:59") of
        (Some tMid, Some tNoon, Some tMax) =>
        dml (DELETE FROM t WHERE t.Id = {[tMid]} OR t.Id = {[tNoon]} OR t.Id = {[tMax]});
        dml (INSERT INTO t (Id, Label, Ref) VALUES ({[tMid]}, {["mid"]}, {[(None : option timeOfDay)]}));
        dml (INSERT INTO t (Id, Label, Ref) VALUES ({[tNoon]}, {["noon"]}, {[Some tNoon]}));
        dml (INSERT INTO t (Id, Label, Ref) VALUES ({[tMax]}, {["max"]}, {[Some tMax]}));
        rows <- queryX1 (SELECT t.Id, t.Label, t.Ref FROM t
                         WHERE t.Id = {[tMid]} OR t.Id = {[tNoon]} OR t.Id = {[tMax]}
                         ORDER BY t.Id)
                        (fn r => <xml>{[timeOfDayToString r.Id]}={[r.Label]},ref={[showOpt r.Ref]};</xml>);
        return <xml><body>VALIDATION:{validationBattery ()}|TOD_ROUNDTRIP:{rows}</body></xml>
      | _ => return <xml><body>TOD_PARSE_FAILED</body></xml>
