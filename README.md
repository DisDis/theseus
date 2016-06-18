# Theseus

Theseus port https://github.com/jamis/theseus version 1.0.2

Theseus is a library for generating and solving mazes. It also includes
routines for rendering mazes (and their solutions) to both ASCII art,
and to PNG image files.

There is also an included utility for generating mazes from the command-line.

## Overview

Theseus supports the following types of mazes:

* **Orthogonal**. This is the traditional maze layout of rectangular passages.
* **Delta**. This maze type tesselates the field into triangles.
* **Sigma**. The field is tesselated into hexagons.
* **Upsilon**. The maze field consists of tiled octogons and squares.

Mazes may be generated using any of the following features:

* **Symmetry**. The maze may be reflected in x, y, x and y, or radially. (Not
  all maze types support symmetry yet.)
* **Randomness**.  A maze with low randomness will result in many long, straight
  corridors. Higher randomness gives a maze with more twists and turns.
* **Weave**. Mazes with high weave will frequently pass over or under existing
  passages. Low weave mazes will prefer to remain on the same plane.
* **Braid**. Mazes with high braid will trade dead-ends for circular loops in
  the maze. Thus, braided mazes will tend to have multiple possible solutions.
* **Wrap**. Mazes may wrap in x, y, or x and y together. A maze that wraps in
  any of its dimensions will allow the passages to go from one side
  of the maze to the other, by moving beyond the far edge of the
  maze. Another way to think of it is that a maze that wraps in one
  dimension may be mapped onto a cylinder, and a maze that wraps in
  both dimensions may be mapped onto a torus.
* **Masks**. Mazes may be constrained with masks, which are basically boolean
  grids that define where a passage is allowed to exist. With masks,
  you can create mazes that fit pre-defined geometry, or wrap around text.

Theseus supports the following output types:

* **ASCII**. Using the ASCII output, you can simply print a maze to the console
  to see what it looks like. Not all features can be displayed well
  in ASCII mode, but it works well enough to see what the maze will be like.
* **PNG or Canvas**. Mazes that are rendered to PNG may be highly customized, and even
  allow you to specify custom paths to be rendered.

Theseus supports the following solution algorithms:

* **Recursive Backtracking**. This is a fast, efficient algorithm for solving
  mazes that have no circular loops (e.g. unbraided mazes).
* **A star Search**. The A* search algorithm really shines with mazes that
  are highly braided, and is guaranteed to provide you with the shortest
  path through the maze.

Orthogonal mazes may be converted to their _unicursal_ equivalent. A unicursal
maze is one which has only a single path that covers every cell in the field
exactly once. This style is maze is often called a "labyrinth". See
Theseus::OrthogonalMaze#to_unicursal for more information.

Theseus is also designed to allow you to step through both the generation of
the maze, as well as the computation of the solution. This lets you (for instance)
animate the construction (and solution) of the maze by drawing individual PNG
frames for each step! And since Theseus includes an implementation of A* Search,
this gives you an interesting way to visualize (among other things) how that
algorithm works.

Lastly, Theseus can be used to manually build mazes (or any other grid-based
structure) by hand. See Theseus::Maze for more information.

## Usage

Theseus is designed to be super simple to use. See 'example' folder.


## License

Theseus is created by Jamis Buck. It is made available in the public domain,
completely unencumbered by rules, restrictions, or any other nonsense.

Please prefer good over evil.