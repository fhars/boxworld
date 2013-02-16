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
    (float * G.node * G.edge list * int) option
end = struct

  let solve _ _ = failwith "Not implemented"

end
