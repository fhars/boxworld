type varname = int
type literal = string

(* States in the world and goals are always fully ground *)
type bound = Bound of string * literal list

module Bound = struct
  type t = bound
  let compare = compare
end
module State = Set.Make(Bound)

(* Formulas in a condition are always fully abtract *)
type pattern = Pattern of string * varname list

type action = {
  name : string;
  arity : int;
  preconditions : pattern list;
  adds : pattern list;
  dels : pattern list
}

module BindingKey = struct
  type t = varname
  let compare = compare
end
module Binding = Map.Make(BindingKey)


module Env = struct
  type t = literal Binding.t
  let compare = compare
end
module EnvSet = Set.Make(Env)
