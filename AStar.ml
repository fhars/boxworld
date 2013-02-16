module type GraphWithHeuristic =
sig
  type node
  type problem
  type edge
  val compare_nodes : node -> node -> int
  val edges : node -> problem -> (int * node * edge) list
  val solved : node -> problem -> bool
  val heuristic : node -> problem -> int
end

module Make(G: GraphWithHeuristic) : sig
  val solve : G.node -> G.problem ->
    (int * G.node * G.edge list * int) option
end = struct

  module Seen = Set.Make(struct
    type t = G.node
    let compare = G.compare_nodes
  end)

  let rec solve_rec fringe seen problem =
    match Heap.head fringe with
      | Some(heuristic, cost, node, path) ->
          if G.solved node problem then
            Some(cost, node, List.rev path, Seen.cardinal seen)
          else
            let fringe' = Heap.remhead fringe in
            let fringe'', seen' =
              if not (Seen.mem node seen) then
                let seen' = Seen.add node seen
                and edges = G.edges node problem in
                let fringe'' =
                  List.fold_left
                    (fun fringe (c, n, e) ->
                      if Seen.mem n seen' then
                        fringe
                      else
                        if Seen.mem n seen' then
                          fringe'
                        else
                          let cost' = cost + c in
                          let estimate = cost' + G.heuristic n problem in
                          Heap.add fringe (estimate, cost', n, e::path)
                    ) fringe' edges in
                fringe'', seen'
              else
                fringe', seen
            in
            solve_rec fringe'' seen' problem
      | None ->
          None

  let solve state problem =
    let estimate = G.heuristic state problem in
    let fringe = Heap.singleton (estimate, 0, state, [])
    and seen = Seen.empty in
    solve_rec fringe seen problem
end
