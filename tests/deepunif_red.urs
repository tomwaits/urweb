val firstSome :
   a ::: Type ->
   b ::: Type ->
   (a -> option b) ->
   list a ->
   option b
