INTFS = Unifier.cmi 
OBJS=DomainTypes.cmo Unifier.cmo AStar.cmo Domain.cmo Planner.cmo
NAME=boxworld
OCAMLC=ocamlfind ocamlc -package js_of_ocaml -package js_of_ocaml.syntax -syntax camlp4o

$(NAME).byte: $(INTFS) $(OBJS)
	$(OCAMLC) -linkpkg -o $@ $(OBJS)

$(NAME).js: $(NAME).
	js_of_ocaml $<

%.cmo: %.ml
	$(OCAMLC) -c $<

%.cmi: %.mli
	$(OCAMLC) -c $<

Unifier.cmi: DomainTypes.cmo