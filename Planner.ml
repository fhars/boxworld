module AS = AStar.Make(Domain)

let make_plan actions initial_state goal =
  AS.solve initial_state (actions, goal)
