(* Regression (urweb/urweb#228 / #261): a composite PRIMARY KEY / UNIQUE must
 * emit its columns in SOURCE order, not reversed. Column names are chosen so
 * source order (Bb, Aa) differs from any alphabetical reordering, making the
 * order observable in the emitted DDL. The harness compiles this with
 * -dbms postgres -sql and asserts the key column order. *)
table t : {Aa : int, Bb : string, Cc : int}
    PRIMARY KEY (Bb, Aa)
    CONSTRAINT U UNIQUE (Cc, Aa),
    (* A 3-column key in reverse-alpha order: with 2+ non-pivot columns this
     * distinguishes "source order preserved + append" (Cc, Bb, Aa) from a
     * sorted-then-appended list (Bb, Cc, Aa) -- the crux the 2-column keys
     * above cannot exercise. Constraints after the first are comma-separated
     * (urweb.grm: csts COMMA csts). *)
    CONSTRAINT V UNIQUE (Cc, Bb, Aa)

fun main () : transaction page = return <xml><body>ok</body></xml>
