INTFS = Unifier.cmi 
OBJS=DomainTypes.cmo Unifier.cmo Heap.cmo AStar.cmo Domain.cmo Planner.cmo BoxPlanner.cmo
NAME=BoxPlanner
OCAMLC=ocamlfind ocamlc -package js_of_ocaml -package js_of_ocaml.syntax -syntax camlp4o

$(NAME).byte: $(INTFS) $(OBJS)
	$(OCAMLC) -linkpkg -o $@ $(OBJS)

$(NAME).js: $(NAME).byte
	js_of_ocaml -pretty $<

%.cmo: %.ml
	$(OCAMLC) -c $<

%.cmi: %.mli
	$(OCAMLC) -c $<

clean:
	rm -f *.cm[io]

Unifier.cmi: DomainTypes.cmo
