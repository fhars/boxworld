open DomainTypes

let actions = [
  { name = "pick";
    arity = 3; (* crane, from, box *)
    preconditions = [
      Pattern("Free", [1]);
      Pattern("Top", [3]);
      Pattern("On", [2; 3])
    ];
    adds = [
      Pattern("Top", [2]);
      Pattern("Holding", [1; 3])
    ];
    dels = [
      Pattern("Free", [1]);
      Pattern("Top", [3]);
      Pattern("On", [2; 3])
    ];
  };
  { name = "pickbot";
    arity = 2; (* crane, box *)
    preconditions = [
      Pattern("Free", [1]);
      Pattern("Top", [2]);
      Pattern("Bot", [2])
    ];
    adds = [
      Pattern("Holding", [1; 2])
    ];
    dels = [
      Pattern("Free", [1]);
      Pattern("Top", [2]);
      Pattern("Bot", [2])
    ];
  };
  { name = "drop";
    arity = 2; (* crane, box *)
    preconditions = [
      Pattern("Holding", [1; 2]);
    ];
    adds = [
      Pattern("Free", [1]);
      Pattern("Top", [2]);
      Pattern("Bot", [2])
    ];
    dels = [
      Pattern("Holding", [1; 2]);
    ];
  };
  { name = "stack";
    arity = 3; (* crane, from, box *)
    preconditions = [
      Pattern("Top", [2]);
      Pattern("Holding", [1; 3])
    ];
    adds = [
      Pattern("Free", [1]);
      Pattern("Top", [3]);
      Pattern("On", [2; 3])
    ];
    dels = [
      Pattern("Top", [2]);
      Pattern("Holding", [1; 3])
    ];
  };
]

let goal =   List.fold_right State.add [
  Bound("On", ["Rect1"; "Rect2"]);
  Bound("On", ["Rect2"; "Rect3"]);
  Bound("On", ["Rect3"; "Rect4"]);
] State.empty

let debug f = Printf.ksprintf (fun s -> Firebug.console##log(Js.string s)) f

let name_to_ix : (string, int) Hashtbl.t = Hashtbl.create 10
let expected_state = ref State.empty
let next_actions = ref []

module S = Set.Make(struct type t = string let compare = compare end)
let all_objs = ref S.empty

let initialize_planner labels =
  let arr = Js.str_array labels in
  for i = 0 to arr##length - 1 do
    ignore(Js.Optdef.map (Js.array_get arr i)
             (fun s -> let s = Js.to_string s in
                       debug "Defined object %s" s;
                       all_objs := S.add s !all_objs;
                       Hashtbl.add name_to_ix s i))
  done

let reconstruct_state observed_state =
  let obs =  Array.map (fun fact ->
   Array.map Js.to_string (Js.to_array (Js.str_array fact))
  ) (Js.to_array (Js.Unsafe.coerce observed_state)) in
  let state =  ref State.empty
  and holding = ref false
  and tops = ref !all_objs
  and bottoms = ref !all_objs in
  Array.iter (fun fact ->
    match fact.(0) with
      | "holding" ->
          holding := true;
          state := State.add (Bound("Holding", ["Crane"; fact.(1)])) !state;
          tops := S.remove fact.(1) !tops;
          bottoms := S.remove fact.(1) !bottoms;
      | "on" ->
          state := State.add (Bound("On", [fact.(1); fact.(2)])) !state;
          tops := S.remove fact.(1) !tops;
          bottoms := S.remove fact.(2) !bottoms;
      | _ -> ()
  ) obs;
  if not !holding then
    state := State.add (Bound("Free", ["Crane"])) !state;
  S.iter (fun s ->
    state := State.add (Bound("Top", [s])) !state;
  ) !tops;
  S.iter (fun s ->
    state := State.add (Bound("Bot", [s])) !state;
  ) !bottoms;
  !state

let replan state =
  debug "Replanning";
  match try Planner.make_plan actions state goal with _ -> None with
    | Some(_cost, _target, actions, _visited) ->
        debug "Found new plan";
        next_actions := actions
    | None ->
        debug "Found no plan";
        next_actions := []


let perform state (action, binding) =
  let pick nr = (4, (1, Hashtbl.find name_to_ix (Binding.find nr binding))) in
  expected_state := Domain.apply_action state action binding;
  debug "Performing action %s" action.name;
  match action.name with
    | "pick" -> pick 3
    | "pickbot" -> pick 2
    | "stack" ->
        (4, (1, Hashtbl.find name_to_ix (Binding.find 2 binding)))
    | "drop" ->
        (4, (1, -1))
    | _ ->
        failwith "Internal Error"

let run_planner observed_state =
  let state = reconstruct_state observed_state in
  if State.subset goal state then
    (3, (0,0))
  else (
    if not (State.equal state !expected_state) then
      replan state;
    match !next_actions with
      | [] ->
          debug "No plan going forward";
          (3, (0,0))
      | act::acts ->
          next_actions := acts;
          perform state act

  )

let _ =
  (Js.Unsafe.coerce Dom_html.window)##initializePlanner <- Js.wrap_callback initialize_planner;
  (Js.Unsafe.coerce Dom_html.window)##runPlanner <- Js.wrap_callback run_planner
