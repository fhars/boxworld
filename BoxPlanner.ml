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


