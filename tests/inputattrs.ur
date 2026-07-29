(* urweb/urweb#275 (+ #128): common HTML input validation / UX attributes on
 * form widgets. Exercises the newly-added inputAttrs fields so they must
 * typecheck on a real form input. These render via the generic attribute path
 * (monoize lowercaseFirst): Pattern -> pattern, Maxlength -> maxlength, etc. *)
(* The record type is annotated so the fixture typechecks under a standalone
 * `urweb -tc` (which pins down otherwise-undetermined form-row variables). *)
fun handler (r : {Fld : string}) : transaction page =
    return <xml><body>{[r.Fld]}</body></xml>

fun main () : transaction page = return <xml><body>
  <form>
    <textbox{#Fld}
      Required={True} Autofocus={True} Disabled={False} Readonly={False}
      Autocomplete={"off"} Pattern={"[0-9]+"} Minlength={2} Maxlength={5}/>
    <submit action={handler}/>
  </form>
</body></xml>
