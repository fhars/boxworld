(* A leftist heap, based on a mailing list post by
   Brian Hurt,
   http://tech.groups.yahoo.com/group/ocaml_beginners/message/6825
 *)
type 'a t =
  | Empty
  | Tree of int * 'a t * 'a * 'a t

let height = function
  | Empty -> 0 (* empty trees have a height of 0 *)
  | Tree(h, _, _, _) -> h

let make l e r =
  let h = max (height l) (height r) in
  Tree(h, l, e, r)

let rec join l r =
  match l, r with
    | Empty, Empty -> Empty
    | Empty, Tree(_) -> r
    | Tree(_), Empty -> l
    | Tree(_, l1, e1, r1), Tree(_, l2, e2, r2) ->
        if (compare e1 e2) <= 0 then
          (* promote l *)
          join3 e1 l1 r1 r
        else
          (* promote r *)
          join3 e2 l l2 r2
and join3 e a b c =
  if (height a) >= (height b) then
    if (height a) >= (height c) then
      (* a is the tallest child *)
      make a e (join b c)
    else
      (* c is the tallest child *)
      make c e (join a b)
  else
    if (height b) >= (height c) then
      (* b is the tallest child *)
      make b e (join a c)
    else
      (* c is the tallest child *)
      make c e (join a b)

let empty = Empty

let add queue elem = join queue (make Empty elem Empty)

let singleton elem = make Empty elem Empty

let head = function
  | Empty -> None
  | Tree(_, _, e, _) -> Some e

let remhead = function
  | Empty -> invalid_arg "remhead"
  | Tree(_, l, _, r) -> join l r
