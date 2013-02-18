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
let initialize_planner labels =
  let arr = Js.str_array labels in
  for i = 0 to arr##length - 1 do
    ignore(Js.Optdef.map (Js.array_get arr i)
             (fun s -> let s = Js.to_string s in
                       debug "Defined object %s" s;
                       Hashtbl.add name_to_ix s i))
  done

let run_planner observed_state =
  (4, (1,0))

let _ =
  (Js.Unsafe.coerce Dom_html.window)##initializePlanner <- Js.wrap_callback initialize_planner;
  (Js.Unsafe.coerce Dom_html.window)##runPlanner <- Js.wrap_callback run_planner
