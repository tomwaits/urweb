(* DIAG fixture: echo the raw INPUT bytes so we can see what the source string
 * literal actually produces, plus the decoded result. *)
val input : string = "\"\\uD83D\\uDE00\""
val decoded : string = Json.fromJson input

fun main () : transaction page =
    return <xml><body>
      <p>INPUT=[{[input]}] inbytes={[strlenUtf8 input]} incp={[strlen input]}</p>
      <p>{[if strlenUtf8 decoded = 4 && strlen decoded = 1 then
              "SURROGATE_PAIR_OK"
          else
              "SURROGATE_PAIR_BAD"]}</p>
      <p>bytes={[strlenUtf8 decoded]} codepoints={[strlen decoded]}</p>
      <p>raw=[{[decoded]}]</p>
    </body></xml>
