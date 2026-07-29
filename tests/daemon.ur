(* Verifies the standalone HTTP server's `-d <logfile>` daemon flag: with -d the
 * server forks BEFORE spawning any app thread, the child calls setsid() to
 * detach from the controlling terminal and redirects stdout/stderr to the log
 * file, and the PARENT prints "Daemonized: pid <n>" and exits so the shell
 * returns immediately. This trivial page is what the backgrounded child serves;
 * the harness curls it to prove the detached daemon is alive.
 *
 * The `task periodic` is the regression guard for the fork ordering: its thread
 * is spawned by uw_request_init, so its marker (PERIODIC_FIRED, written by the
 * FIRST immediate run of periodic_loop) reaches the child's redirected log ONLY
 * if uw_request_init runs in the daemon child -- i.e. only if the fork happens
 * before it. A large period keeps it to a single startup marker (no log spam). *)
task periodic 3600 = fn () => debug "PERIODIC_FIRED"

fun main () : transaction page =
    return <xml><body>DAEMON_ALIVE</body></xml>
