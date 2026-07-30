val firstSome :
   a ::: Type ->
   b ::: Type ->
   (a -> option b) ->
   list a ->
   option b

val firstSomeEither :
   a ::: Type ->
   b ::: Type ->
   (a -> option b) ->
   list a ->
   option b
