A Box Stacking Planner
======================

This code implements a simple STRIPS-like planner that tries to stack
some boxes in a [box2dweb](http://code.google.com/p/box2dweb/) world.
There are four rectangles and two squares in the world, and the
planner tries to sort the rectangles by size.  Since the planner
doesn't really understand the physics, it may sometimes get stuck or
do rather funny things. You can always use the mouse to help or
confuse it further.  Planning may also take some time, during which
the browser will block and maybe warn about a non-responsive
script. Just be patient and let it run to completion.

[View the code running on its github page.](http://fhars.github.com/boxworld/)

The simulation is based on the box2dweb demo code, the planner has
been written in [ocaml](http://www.ocaml.org) for the coursera
["Artificial Intellience Planning"
course](https://www.coursera.org/course/aiplan). In addition to an ocaml
compiler you also need [js_of_ocaml](http://ocsigen.org/js_of_ocaml/)
to compile it.

