(* DIAG: probe ofUnicode directly on astral codepoints (constants) plus the
 * surrogate arithmetic, to locate where U+1F600 turns into "U". *)
val a1 = ofUnicode 0x1F600
val a3 = ofUnicode (0x10000 + (0xD83D - 0xD800) * 0x400 + (0xDE00 - 0xDC00))
val a4 = ofUnicode 0x55
val decoded : string = Json.fromJson "\"\\uD83D\\uDE00\""

fun main () : transaction page =
    return <xml><body>
      <p>a1={[strlenUtf8 a1]}/{[strlen a1]} a3={[strlenUtf8 a3]}/{[strlen a3]} a4={[strlenUtf8 a4]}/{[strlen a4]}</p>
      <p>dec={[strlenUtf8 decoded]}/{[strlen decoded]} raw=[{[decoded]}]</p>
    </body></xml>
