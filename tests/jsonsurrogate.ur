(* Regression for urweb/urweb#211: a character outside the Basic Multilingual
 * Plane is JSON-encoded as a UTF-16 surrogate PAIR. Here U+1F600 GRINNING FACE
 * is "😀". Correct decoding yields ONE scalar value = 4 UTF-8 bytes
 * (F0 9F 98 80). Before the fix, unescape emitted each surrogate code unit
 * separately as 3-byte WTF-8, giving 2 codepoints / 6 bytes of malformed UTF-8.
 *
 * strlen counts codepoints, strlenUtf8 counts bytes (src/c/urweb.c), so a
 * correct decode is uniquely strlen=1 AND strlenUtf8=4 for this input. The
 * harness also hex-checks the raw response bytes. *)
val decoded : string = Json.fromJson "\"\\uD83D\\uDE00\""

fun main () : transaction page =
    return <xml><body>
      <p>{[if strlenUtf8 decoded = 4 && strlen decoded = 1 then
              "SURROGATE_PAIR_OK"
          else
              "SURROGATE_PAIR_BAD"]}</p>
      <p>bytes={[strlenUtf8 decoded]} codepoints={[strlen decoded]}</p>
      <p>raw=[{[decoded]}]</p>
    </body></xml>
