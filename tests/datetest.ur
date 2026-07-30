(* Native `date` SQL primitive type fixture.
 *
 * Part 1 (validation battery): asserts that stringToDate accepts exactly the
 * proper Gregorian dates and rejects the impossible ones -- leap-year rule
 * (incl. the century / 400-year exceptions), per-month day counts, month
 * bounds, and the fixed YYYY-MM-DD shape.  A correct uw_date_valid emits no
 * BAD_ marker; any acceptance/rejection mismatch shows up in the output.
 *
 * Part 2 (round-trip): a table whose primary key is a native `date` column, a
 * plain column, and a NULLABLE `date` column.  Parses a valid date, INSERTs it
 * (including into the nullable column via an `option date` injection), queries
 * by date equality, SELECTs it back, and renders it via dateToString --
 * exercising sqlifyDate (write, with the ::date cast on Postgres), the
 * option/nullable path (sql_option_prim + the Nullable Date read path), and the
 * unsql read path end to end. *)
table t : { Id : date, Label : string, Ref : option date }
    PRIMARY KEY Id

(* [s] must PARSE; emit a marker if it is wrongly rejected. *)
fun expectSome (s : string) : xbody =
    case stringToDate s of
        Some _ => <xml></xml>
      | None => <xml>BAD_REJECT:{[s]};</xml>

(* [s] must be REJECTED; emit a marker if it is wrongly accepted. *)
fun expectNone (s : string) : xbody =
    case stringToDate s of
        None => <xml></xml>
      | Some _ => <xml>BAD_ACCEPT:{[s]};</xml>

fun validationBattery () : xbody = <xml>
    {expectSome "2024-02-29"}  (* leap year (div 4, not div 100): Feb 29 exists *)
    {expectNone "2023-02-29"}  (* common year: Feb 29 does not exist *)
    {expectSome "2000-02-29"}  (* div 400: leap, Feb 29 exists *)
    {expectNone "1900-02-29"}  (* div 100 but not 400: not leap *)
    {expectNone "2024-02-30"}  (* Feb never has 30 days *)
    {expectNone "2024-04-31"}  (* April has 30 days *)
    {expectSome "2024-12-31"}  (* year-end boundary *)
    {expectSome "0001-01-01"}  (* lowest portable year *)
    {expectNone "0000-01-01"}  (* year 0000: no year zero / MySQL zero-date *)
    {expectNone "2024-13-01"}  (* month > 12 *)
    {expectNone "2024-00-15"}  (* month 0 *)
    {expectNone "2024-01-00"}  (* day 0 *)
    {expectNone "2024-1-15"}   (* not zero-padded (wrong length) *)
    {expectNone "2024-01-15 "} (* trailing junk *)
    {expectNone "not-a-date!"} (* garbage *)
</xml>

fun showOpt (r : option date) : string =
    case r of
        None => "none"
      | Some d => dateToString d

(* Three rows chosen to exercise, together:
 *   - a year < 1000 ("0500"): proves the backend zero-pads it back to 4 digits
 *     on read (the canonical form the reader requires),
 *   - a NULL nullable column (Ref = None on the low row): the ONLY row that
 *     drives the Nullable Date read path's None branch,
 *   - the "9999" upper boundary,
 *   - a Some nullable value (the mid + max rows).
 * ORDER BY Id makes the rendered order deterministic across backends (the
 * zero-padded YYYY-MM-DD strings sort chronologically). *)
fun main () : transaction page =
    case (stringToDate "0500-06-15", stringToDate "2024-01-15", stringToDate "9999-12-31") of
        (Some dLow, Some dMid, Some dMax) =>
        dml (DELETE FROM t WHERE t.Id = {[dLow]} OR t.Id = {[dMid]} OR t.Id = {[dMax]});
        dml (INSERT INTO t (Id, Label, Ref) VALUES ({[dLow]}, {["low"]}, {[(None : option date)]}));
        dml (INSERT INTO t (Id, Label, Ref) VALUES ({[dMid]}, {["hello"]}, {[Some dMid]}));
        dml (INSERT INTO t (Id, Label, Ref) VALUES ({[dMax]}, {["max"]}, {[Some dMax]}));
        rows <- queryX1 (SELECT t.Id, t.Label, t.Ref FROM t
                         WHERE t.Id = {[dLow]} OR t.Id = {[dMid]} OR t.Id = {[dMax]}
                         ORDER BY t.Id)
                        (fn r => <xml>{[dateToString r.Id]}={[r.Label]},ref={[showOpt r.Ref]};</xml>);
        return <xml><body>VALIDATION:{validationBattery ()}|DATE_ROUNDTRIP:{rows}</body></xml>
      | _ => return <xml><body>DATE_PARSE_FAILED</body></xml>
