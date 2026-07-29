(* Regression for urweb/urweb#211: decode UTF-16 surrogate pairs. A character
 * outside the BMP is JSON-encoded as a surrogate pair; U+1F600 GRINNING FACE
 * is "😀". Correct decoding yields one scalar value = 4 UTF-8 bytes
 * (F0 9F 98 80). Before the fix, unescape emitted each surrogate as 3-byte
 * WTF-8 (2 codepoints / 6 bytes of malformed UTF-8).
 *
 * strlen counts codepoints, strlenUtf8 counts bytes (src/c/urweb.c), so a
 * correct decode is uniquely strlen=1 AND strlenUtf8=4 for this input.
 *
 * The JSON string is built at RUNTIME (an always-"" prefix the optimizer
 * cannot fold away) ON PURPOSE: urweb constant-folds `Json.fromJson` of a
 * string LITERAL at compile time, and that fold path mishandles astral
 * codepoints (turns U+1F600 into "U") -- a separate, pre-existing compiler bug
 * tracked as its own fork issue. Forcing a runtime decode exercises the C
 * runtime, where this fix is exact. *)
fun main () : transaction page =
    t <- now;
    let
        val pfx = if toSeconds t < 0 then "x" else ""
        val decoded : string = Json.fromJson (pfx ^ "\"\\uD83D\\uDE00\"")
    in
        return <xml><body>
          <p>{[if strlenUtf8 decoded = 4 && strlen decoded = 1 then
                  "SURROGATE_PAIR_OK"
              else
                  "SURROGATE_PAIR_BAD"]}</p>
          <p>bytes={[strlenUtf8 decoded]} codepoints={[strlen decoded]}</p>
          <p>raw=[{[decoded]}]</p>
        </body></xml>
    end
