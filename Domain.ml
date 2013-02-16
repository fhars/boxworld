open DomainTypes

(* A problem is defined by a list of available actions and a goal
   state *)
type problem = action list * State.t
type node = State.t
type edge = action * string Binding.t

let solved state (_, goal) =
  State.subset state goal

(* This heuristic is in general inadmissible, but we
   will construct our problems in a way that it isn't *)
let heuristic state (_, goal) = State.cardinal (State.diff goal state)

let substitute binding vars =
  List.map (fun v -> Binding.find v binding) vars
let instantiate_pattern binding state (Pattern(name, vars)) =
  State.add (Bound(name, substitute binding vars))  state
let instantiate_action action binding =
  let instantiate = instantiate_pattern binding in
  let adds = List.fold_left instantiate State.empty action.dels
  and dels = List.fold_left instantiate State.empty action.dels in
  (adds, dels)

let apply_action state action binding =
  let adds, dels = instantiate_action action binding in
  State.union adds (State.diff state dels)

let create_edge state action binding =
  let cost = 1
  and state' = apply_action state action binding
  and edge = (action, binding) in
  (cost, state', edge)

let applicable state action =
  let bindings =
    Unifier.find_assignments state action.arity action.preconditions in
  EnvSet.fold
    (fun binding l -> (create_edge state action binding) :: l)
    bindings []

let applicable_actions state actions =
  List.flatten (List.map (applicable state) actions)

let edges state (actions, _) =
  applicable_actions state actions

