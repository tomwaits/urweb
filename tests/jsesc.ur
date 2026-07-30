(* urweb/urweb#121 (verify-then-close): control characters in string literals
 * must never reach the emitted client JavaScript raw. The Ur lexer has no \b
 * escape (only \n \r \t \\ \" \' \OOO \xHH -- src/urweb.lex), so a REAL
 * backspace enters via \x08. Compile-time literals are encoded by jscomp.sml's
 * jsChar: quote/backslash/\n\r\t named escapes, every other non-printable as
 * 3-digit octal (0x08 -> \010); the nested closure-serialization layer then
 * doubles backslashes, so the wire form in app.js is A\\010B\\nC\\ttail --
 * decoded twice client-side back to the original bytes. (The dynamic path is
 * covered separately by jsifyChar in src/c/urweb.c, which \u-escapes
 * non-printables.) `make test` fetches the served app.js and (a) asserts NO raw
 * 0x08 byte anywhere in it, (b) pins the exact wire encoding of this literal. *)
fun main () : transaction page =
let
  fun go () : transaction unit =
    alert "A\x08B\nC\ttail"
in
return <xml><body><button onclick={fn _ => go ()}>esc</button></body></xml>
end
