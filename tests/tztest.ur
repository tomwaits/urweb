(* Native `timestamptz` SQL primitive (the proper fix for the #163 timezone
 * skew): a timezone-aware column stored/retrieved in UTC.  Round-trips a FIXED
 * instant WITH sub-second precision (so microseconds are exercised, not just
 * whole seconds -- catching any backend that truncates them) through both a NOT
 * NULL and a nullable `option timestamptz` column, and queries it back BY
 * timestamptz equality (exercising the WHERE-clause parameter path and that a
 * bound value compares equal to an inlined literal).  Asserts the exact instant
 * -- to the millisecond -- survives; under a non-UTC database session a plain
 * `time` would come back shifted.  Reuses the `time` value via
 * timeToTimestamptz / timestamptzToTime. *)
table t : { Id : int, Ts : timestamptz, Opt : option timestamptz }
    PRIMARY KEY Id

fun optMs (r : option timestamptz) : int =
    case r of
        None => -1
      | Some x => toMilliseconds (timestamptzToTime x)

fun main () : transaction page =
    let
        val n : time = fromMilliseconds 1785425679123
        val ts : timestamptz = timeToTimestamptz n
    in
        dml (DELETE FROM t WHERE t.Id = 1);
        dml (INSERT INTO t (Id, Ts, Opt) VALUES (1, {[ts]}, {[Some ts]}));
        rows <- queryX1 (SELECT t.Ts, t.Opt FROM t WHERE t.Ts = {[ts]})
                        (fn r => <xml>{[toMilliseconds (timestamptzToTime r.Ts)]},opt={[optMs r.Opt]}</xml>);
        return <xml><body>TZ_ROUNDTRIP:orig={[toMilliseconds n]},read={rows}</body></xml>
    end
