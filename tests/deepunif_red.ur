(* urweb/urweb#266's VERBATIM failing shape: the recursive call re-passes the
 * function's own constructor parameters explicitly. This is EXPECTED to fail
 * with "too-deep unification variable" -- make test asserts the failure, so
 * any change to this elaborator behavior (e.g. adopting upstream PR#226's
 * soundness-suspicious depth-guard relaxation) surfaces as a conscious,
 * reviewable event instead of drifting in silently. *)
fun firstSome [a] [b] f xs =
   case xs of
   | x :: xs =>
      (case f x of
       | None => firstSome [a] [b] f xs
       | Some y => Some y)
   | [] => None
