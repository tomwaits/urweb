(* urweb/urweb#197: a guarded type "[a ~ b] => t" may also be written
 * "[a ~ b] -> t", matching the -> used everywhere else a =>-expression's type
 * is written. guardedNew uses the new -> form (a parse error on master);
 * guardedOld keeps the => form to prove backward compatibility. Both must
 * typecheck after the grammar addition. *)

con guardedNew = fn a :: {Type} => fn b :: {Type} => [a ~ b] -> $(a ++ b)
con guardedOld = fn a :: {Type} => fn b :: {Type} => [a ~ b] => $(a ++ b)
