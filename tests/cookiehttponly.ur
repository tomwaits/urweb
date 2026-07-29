(* Verifies PR#279: a cookie set with HttpOnly = True emits the `httponly`
 * attribute in the Set-Cookie response header. The harness serves this and
 * greps the response header. safeGet whitelists the side-effecting GET. *)
cookie c : int

fun main () : transaction page =
    setCookie c {Value = 42,
                 Expires = None,
                 Secure = False,
                 HttpOnly = True};
    return <xml><body>cookie set</body></xml>
