(* Verifies the standalone HTTP server's `-d <logfile>` daemon flag: with -d the
 * server forks BEFORE spawning any worker/pruner thread, the child calls
 * setsid() to detach from the controlling terminal and redirects stdout/stderr
 * to the log file, and the PARENT prints "Daemonized: pid <n>" and exits so the
 * shell returns immediately. This trivial page is what the backgrounded child
 * serves; the harness curls it to prove the detached daemon is alive. *)
fun main () : transaction page =
    return <xml><body>DAEMON_ALIVE</body></xml>
