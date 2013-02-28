open DomainTypes

let rec unify_values vars vals binding =
  match vars, vals with
    | [], [] -> EnvSet.singleton(binding)
    | n :: vars', l :: vals' -> (
        try
          let ll = Binding.find n binding in
          if ll = l then
            unify_values vars' vals' binding
          else
            EnvSet.empty
        with Not_found ->
          unify_values vars' vals' (Binding.add n l binding)
    )
    | _ -> failwith "inconsistent problem or world"

let unify_formula name vars binding (Bound(name', values)) res =
  if name <> name' then
    res
  else
    EnvSet.union (unify_values vars values binding) res

let unify_base state name vars binding init =
  State.fold (unify_formula name vars binding) state init

let rec unify state preconditions binding =
  let init = (EnvSet.singleton binding) in
  List.fold_left (unify_one_precondition state) init preconditions
and unify_one_precondition state bindings (Pattern(name, vars)) =
  EnvSet.fold
    (unify_base state name vars)
    bindings EnvSet.empty

let find_assignments state arity preconditions =
  EnvSet.filter
    (fun m -> Binding.cardinal m = arity)
    (unify state preconditions Binding.empty)

