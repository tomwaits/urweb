(* urweb/urweb#259 (svg/path half): inline SVG must render with CORRECT SVG
 * attribute names -- interior capitals preserved (ViewBox -> viewBox) and
 * underscores as dashes (Fill_rule -> fill-rule). Served + curled by `make
 * test`, which greps the emitted HTML for the exact attribute spellings, so a
 * regression in attribute-name rendering (not just elaboration) fails loudly. *)
fun main () : transaction page =
    return <xml><body>
      <svg width="24" height="24" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
        <path fill_rule="evenodd" d="M9 12l2 2 4-4" fill="none" stroke="black" stroke_width="2"/>
      </svg>
    </body></xml>
