part of theseus;

//require 'theseus/maze'
//
//module Theseus
//# An orthogonal maze is one in which the field is tesselated into squares. This is
//# probably the type of maze that most people think of, when they think of mazes.
//#
//# The orthogonal maze implementation in Theseus is the most complete, supporting
//# weaving as well as all four symmetry types. You can even convert any "perfect"
//# (no loops) orthogonal maze to a "unicursal" maze. (Unicursal means "one course",
//# and refers to a maze that has no junctions, only a single path that takes you
//# through every cell in the maze exactly once.)
//#
//#   maze = Theseus::OrthogonalMaze.generate(width: 10)
//#   puts maze
class OrthogonalMaze extends Maze {
  OrthogonalMaze(MazeOptions options) : super(options);

  List<int> potential_exits_at(x, y) {
    //#:nodoc:
    return [Maze.N, Maze.S, Maze.E, Maze.W];
  }

  //# Extends Maze//#finish! to make sure symmetrical mazes are properly closed.
  //#--
  //# Eventually, this would be good to generalize somehow, and make available to
  //# the other maze types.
  //#++
  Position finish /*!*/ () {
    //#:nodoc:
    //# for symmetrical mazes, if the size of the maze in the direction of reflection is
    //# even, then we have two distinct halves that need to be joined in order for the
    //# maze to be fully connected.

    var available_width = _width;
    var available_height = _height;

    switch (_symmetry) {
      case SymmetryType.x:
        available_width = available_width ~/ 2;
        break;
      case SymmetryType.y:
        available_height = available_height ~/ 2;
        break;
      case SymmetryType.xy:
      case SymmetryType.radial:
        available_width = available_width ~/ 2;
        available_height = available_height ~/ 2;
        break;
    }

    Position? connector(int x, int y, int ix, int iy, int dir) {
      var start_x = x;
      var start_y = y;
      while (_cells[y][x] == 0) {
        y = (y + iy) % available_height;
        x = (x + ix) % available_width;
        if (start_x == x || start_y == y) {
          break;
        }
      }

      if (_cells[y][x] == 0) {
        print("maze cannot be fully connected");
        return null;
      } else {
        _cells[y][x] |= dir;
        var movePos = move(x, y, dir);
        var nx = movePos.x.toInt();
        var ny = movePos.y.toInt();
        _cells[ny][nx] |= opposite(dir);
        return new Position.xy(x, y);
      }
    }

    bool even(int x) => x % 2 == 0; //even = lambda { |x| x % 2 == 0 }

    switch (_symmetry) {
      case SymmetryType.x:
        if (even(_width)) {
          connector(available_width - 1, ruby.rand(available_height), 0, 1, Maze.E);
        }
        break;
      case SymmetryType.y:
        if (even(_height)) {
          connector(ruby.rand(available_width), available_height - 1, 1, 0, Maze.S);
        }
        break;
      case SymmetryType.xy:
        if (even(_width)) {
          var xy = connector(available_width - 1, ruby.rand(available_height), 0, 1, Maze.E)!;
          _cells[_height - xy.y.toInt() - 1][xy.x.toInt()] |= Maze.E;
          _cells[_height - xy.y.toInt() - 1][xy.x.toInt() + 1] |= Maze.W;
        }

        if (even(_height)) {
          var xy = connector(ruby.rand(available_width), available_height - 1, 1, 0, Maze.S)!;
          _cells[xy.y.toInt()][_width - xy.x.toInt() - 1] |= Maze.S;
          _cells[xy.y.toInt() + 1][_width - xy.x.toInt() - 1] |= Maze.N;
        }
        break;
      case SymmetryType.radial:
        if (even(_width)) {
          _cells[available_height - 1][available_width - 1] |= Maze.E | Maze.S;
          _cells[available_height - 1][available_width] |= Maze.W | Maze.S;
          _cells[available_height][available_width - 1] |= Maze.E | Maze.N;
          _cells[available_height][available_width] |= Maze.W | Maze.N;
        }
        break;
    }

    return super.finish();
  }

  //# Takes the current orthogonal maze and converts it into a unicursal maze. A unicursal
  //# maze is one with only a single path, and no dead-ends or junctions. Such mazes are
  //# more properly called "labyrinths". Note that although this method will always return
  //# a new OrthogonalMaze instance, it is not guaranteed to be a valid maze unless the
  //# current maze is "perfect" (not braided, containing no loops).
  //#
  //# The resulting unicursal maze will be twice as wide and twice as high as the original
  //# maze.
  //#
  //# The +options+ hash can be used to specify the <code>:entrance</code> and
  //# <code>:exit</code> points for the resulting maze. Currently, both the entrance and
  //# the exit must be adjacent.
  //#
  //# The process of converting an orthogonal maze to a unicursal maze is straightforward;
  //# take the maze, and divide all passages in half down the middle, making two passages.
  //# Dead-ends become a u-turn, etc. This is why the maze increases in size.
  Maze to_unicursal(MazeOptions options/*={}*/) {
    options.width = (_width * 2).toInt();
    options.height = (_height * 2).toInt();
    options.prebuilt = true;

    Maze unicursal = new OrthogonalMaze(options);

    set(int x, int y, int direction, [bool recip = false]) {
      //lambda do |x, y, direction, *recip|
      var movePos = move(x, y, direction);
      var nx = movePos.x;
      var ny = movePos.y;
      unicursal[new Position.xy(x, y)] |= direction;
      if (recip) {
        unicursal[new Position.xy(nx, ny)] |= opposite(direction);
      }
    }

    ruby.each_with_index<List<int>>(_cells, (row, y) {
      ruby.each_with_index<int>(row, (cell, x) {
        var x2 = x * 2;
        var y2 = y * 2;

        if (cell & Maze.N != 0) {
          set(x2, y2, Maze.N);
          set(x2 + 1, y2, Maze.N);
          if (cell & Maze.W == 0) {
            set(x2, y2 + 1, Maze.N, true);
          }
          if (cell & Maze.E == 0) {
            set(x2 + 1, y2 + 1, Maze.N, true);
          }
          if ((cell & Maze.PRIMARY) == Maze.N) {
            set(x2, y2 + 1, Maze.E, true);
          }
        }

        if (cell & Maze.S != 0) {
          set(x2, y2 + 1, Maze.S);
          set(x2 + 1, y2 + 1, Maze.S);
          if (cell & Maze.W == 0) {
            set(x2, y2, Maze.S, true);
          }
          if (cell & Maze.E == 0) {
            set(x2 + 1, y2, Maze.S, true);
          }
          if ((cell & Maze.PRIMARY) == Maze.S) {
            set(x2, y2, Maze.E, true);
          }
        }

        if (cell & Maze.W != 0) {
          set(x2, y2, Maze.W);
          set(x2, y2 + 1, Maze.W);
          if (cell & Maze.N == 0) {
            set(x2 + 1, y2, Maze.W, true);
          }
          if (cell & Maze.S == 0) {
            set(x2 + 1, y2 + 1, Maze.W, true);
          }
          if ((cell & Maze.PRIMARY) == Maze.W) {
            set(x2 + 1, y2, Maze.S, true);
          }
        }

        if (cell & Maze.E != 0) {
          set(x2 + 1, y2, Maze.E);
          set(x2 + 1, y2 + 1, Maze.E);
          if (cell & Maze.N == 0) {
            set(x2, y2, Maze.E, true);
          }
          if (cell & Maze.S == 0) {
            set(x2, y2 + 1, Maze.E, true);
          }
          if ((cell & Maze.PRIMARY) == Maze.E) {
            set(x2, y2, Maze.S, true);
          }
        }

        if (cell & (Maze.N << Maze.UNDER_SHIFT) != 0) {
          unicursal[new Position.xy(x2, y2)] |= (Maze.N | Maze.S) << Maze.UNDER_SHIFT;
          unicursal[new Position.xy(x2 + 1, y2)] |= (Maze.N | Maze.S) << Maze.UNDER_SHIFT;
          unicursal[new Position.xy(x2, y2 + 1)] |= (Maze.N | Maze.S) << Maze.UNDER_SHIFT;
          unicursal[new Position.xy(x2 + 1, y2 + 1)] |= (Maze.N | Maze.S) << Maze.UNDER_SHIFT;
        } else if (cell & (Maze.W << Maze.UNDER_SHIFT) != 0) {
          unicursal[new Position.xy(x2, y2)] |= (Maze.E | Maze.W) << Maze.UNDER_SHIFT;
          unicursal[new Position.xy(x2 + 1, y2)] |= (Maze.E | Maze.W) << Maze.UNDER_SHIFT;
          unicursal[new Position.xy(x2, y2 + 1)] |= (Maze.E | Maze.W) << Maze.UNDER_SHIFT;
          unicursal[new Position.xy(x2 + 1, y2 + 1)] |= (Maze.E | Maze.W) << Maze.UNDER_SHIFT;
        }

        return false;
      });
      return false;
    });

    Position enter_at = unicursal.adjacent_point(unicursal.entrance);
    Position exit_at = unicursal.adjacent_point(unicursal.exit);

    unicursal.add_opening_from(unicursal.entrance);
    unicursal.add_opening_from(unicursal.exit);

    if (enter_at.x < exit_at.x) {
      //enter_at[0] < exit_at[0]
      unicursal[new Position.xy(enter_at.x, enter_at.y)] &= ~Maze.E;
      unicursal[new Position.xy(enter_at.x + 1, enter_at.y)] &= ~Maze.W;
    } else if (enter_at.y < exit_at.y) {
      unicursal[new Position.xy(enter_at.x, enter_at.y)] &= ~Maze.S;
      unicursal[new Position.xy(enter_at.x, enter_at.y + 1)] &= ~Maze.N;
    }

    return unicursal;
  }

  _configure_symmetry() {
    //#:nodoc:
    if (_symmetry == SymmetryType.radial && _width != _height) {
      throw new ArgumentError("radial symmetrial is only possible for mazes where width == height");
    }
  }

//# Returns the maze rendered to a particular format. Supported
  //# formats are currently :ascii and :png. The +options+ hash is passed
  //# through to the formatter.
  V to<V, P>(FormatType format, [P? options] /*={}*/) {
    if (format == FormatType.ascii) {
      return new formatters.ASCIIOrthogonal(this) as V;
    } else if (format == FormatType.png) {
      return new formatters.PNGOrthogonal(this, options as formatters.PNGFormatterOptions) as V;
      //Formatters::PNG.const_get(type).new(self, options).to_blob
    } else {
      throw new ArgumentError("unknown format: $format");
    }
  }

  static Maze generateStatic(MazeOptions options) {
    return new OrthogonalMaze(options).generate();
  }
}
