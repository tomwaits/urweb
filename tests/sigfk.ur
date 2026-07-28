(* Regression: a table with a PRIMARY KEY and a second table whose FOREIGN KEY
 * references it, both declared inside an ascribed signature, must typecheck.
 * On buggy compilers the signature's SgiTable elaboration fails to assert the
 * primary table's constraint disjointness into the environment, so the FK's
 * obligation "[#Pkey] ~ tb1_hidden_constraints" cannot be discharged and
 * elaboration errors out. See urweb/urweb#267. Verbatim from the issue,
 * trimmed to a page. Compiling this file at all is the test. *)
structure MyStruct : sig
   type ty
   table tb1 : {B : string} PRIMARY KEY B
   table tb2 : {A : ty, B : string} PRIMARY KEY A, CONSTRAINT FK_B FOREIGN KEY B REFERENCES tb1(B)
   val toHtml : ty -> xbody
end = struct
   type ty = int
   table tb1 : {B : string} PRIMARY KEY B
   table tb2 : {A : ty, B : string} PRIMARY KEY A, CONSTRAINT FK_B FOREIGN KEY B REFERENCES tb1(B)
   fun toHtml a = <xml>{[a]}</xml>
end

val main : transaction page = return <xml></xml>
