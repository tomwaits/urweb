(* urweb/urweb#275 (+ #128): common HTML input validation / UX attributes on
 * form widgets. Exercises the newly-added inputAttrs fields so they must
 * typecheck on a real form input. These render via the generic attribute path
 * (monoize lowercaseFirst): Pattern -> pattern, Maxlength -> maxlength, etc. *)
fun handler r = return <xml><body>{[r.Fld]}</body></xml>

fun main () = return <xml><body>
  <form>
    <textbox{#Fld}
      Required={True} Autofocus={True} Disabled={False} Readonly={False}
      Autocomplete={"off"} Pattern={"[0-9]+"} Minlength={2} Maxlength={5}/>
    <submit action={handler}/>
  </form>
</body></xml>
