(* Native `timestamptz` SQL primitive (the proper fix for the #163 timezone
 * skew): a timezone-aware column stored/retrieved in UTC.  Round-trips an
 * instant through a timestamptz column -- both a NOT NULL and a nullable
 * `option timestamptz` -- and asserts the exact instant survives.  If the type
 * serialized in server-local time (as plain `time` does), a non-UTC database
 * session would shift `read` off `orig` by the zone offset.  Reuses the `time`
 * value via timeToTimestamptz / timestamptzToTime. *)
table t : { Id : int, Ts : timestamptz, Opt : option timestamptz }
    PRIMARY KEY Id

fun optSecs (r : option timestamptz) : int =
    case r of
        None => -1
      | Some x => toSeconds (timestamptzToTime x)

fun main () : transaction page =
    n <- now;
    let
        val ts : timestamptz = timeToTimestamptz n
    in
        dml (DELETE FROM t WHERE t.Id = 1);
        dml (INSERT INTO t (Id, Ts, Opt) VALUES (1, {[ts]}, {[Some ts]}));
        rows <- queryX1 (SELECT t.Ts, t.Opt FROM t WHERE t.Id = 1)
                        (fn r => <xml>{[toSeconds (timestamptzToTime r.Ts)]},opt={[optSecs r.Opt]}</xml>);
        return <xml><body>TZ_ROUNDTRIP:orig={[toSeconds n]},read={rows}</body></xml>
    end
