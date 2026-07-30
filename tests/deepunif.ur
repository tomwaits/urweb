(* urweb/urweb#266: the "too-deep unification variable" incompleteness and its
 * VERIFIED workarounds (see the manual's Type Inference section). Both forms
 * below must KEEP typechecking. The failing shapes are pinned RED separately
 * (tests/deepunif_red): with a ::: signature ascribed, recursing either with
 * explicit [a] [b] arguments or bare both still hit the too-deep error. *)

(* Workaround 1 (exported through the ::: signature): do the recursion in a
 * MONOMORPHIC inner helper whose type mentions only the enclosing function's
 * type parameters. *)
fun firstSome [a] [b] (f : a -> option b) (xs : list a) : option b =
    let
        fun go (xs : list a) : option b =
            case xs of
                [] => None
              | x :: xs' =>
                case f x of
                    None => go xs'
                  | Some y => Some y
    in
        go xs
    end

(* Workaround 2 (module-private, NOT exported in the .urs): with no signature
 * ascription constraining it, the annotated definition with an implicit
 * recursive call elaborates fine. *)
fun firstSomeLocal [a] [b] (f : a -> option b) (xs : list a) : option b =
   case xs of
     x :: xs' =>
      (case f x of
           None => firstSomeLocal f xs'
         | Some y => Some y)
   | [] => None

(* Use the private one so it isn't flagged unused, through the public API. *)
fun firstSomeEither [a] [b] (f : a -> option b) (xs : list a) : option b =
    case firstSome f xs of
        None => firstSomeLocal f xs
      | r => r
