//require 'theseus/algorithms/base'
part of theseus.algorithms;

//module Theseus
//  module Algorithms
//# The recursive backtracking algorithm is a quick, flexible algorithm
//# for generating mazes. It tends to produce mazes with fewer dead-ends
//# than algorithms like Kruskal's or Prim's.
class RecursiveBacktracker extends Base {
  //# The x-coordinate that the generation algorithm will consider next.
  int get x => _x;
  late int _x;

  //# The y-coordinate that the generation algorithm will consider next.
  int get y => _y;
  late int _y;

  late List<List<dynamic>> _stack;
  List<int>? get tries => _tries;
  List<int>? _tries;

  RecursiveBacktracker(Maze maze,MazeOptions options):super(maze, options) { //#:nodoc:
    while (true) {
      _y = ruby.rand(_maze.height);
      _x = ruby.rand(_maze.row_length(_y));
      if (_maze.valid(_x, _y)) {
        break;
      }
    }


    _tries = new List.from(_maze.potential_exits_at(_x, _y))..shuffle(ruby.getRandom());
    _stack = <List<dynamic>>[];
  }

  bool do_step() { //#:nodoc:
    int? direction = _next_direction();
    if (direction == null) {
      return false;
    }
    var movePos = _maze.move(_x, _y, direction);
    var nx = movePos.x.toInt();
    var ny = movePos.y.toInt();

    _maze.apply_move_at(_x, _y, direction);

    //# if (nx,ny) is already visited, then we're weaving (moving either over
    //# or under the existing passage).
    if (_maze.getCell(nx.toInt(), ny.toInt()) != 0) {
      var _tmp = _maze.perform_weave(_x, _y, nx, ny, direction);
      nx = _tmp[0];
      ny = _tmp[1];
      direction = _tmp[2];
    }
    _maze.apply_move_at(nx, ny, _maze.opposite(direction));

    _stack.add(<dynamic>[_x, _y, _tries]);
    _tries = new List.from(_maze.potential_exits_at(nx, ny))..shuffle(ruby.getRandom());
    //TODO: Check syntax
    if (!(ruby.rand(100) < _maze.randomness) && _tries!.contains(direction)) { //_tries.include?(direction) unless rand(100) < _maze.randomness
      _tries!.add(direction);
    }
    _x = nx;
    _y = ny;

    return true;
  }

  //private

  //# Returns the next direction that ought to be attempted by the recursive
  //# backtracker. This will also handle the backtracking. If there are no
  //# more directions to attempt, and the stack is empty, this will return +nil+.
  int? _next_direction() {// #:nodoc:
    while (true) {
      int? direction = _tries!.removeLast();
      var movePos = _maze.move(_x, _y, direction);
      var nx = movePos.x.toInt();
      var ny = movePos.y.toInt();

      if (_maze.valid(nx, ny) && (_maze.getCell(_x, _y) & (direction | (direction << Maze.UNDER_SHIFT)) == 0)) {
        if (_maze.getCell(nx, ny) == 0) {
          return direction;
        } else if (!_maze.dead(_maze.getCell(nx, ny)) && _maze.weave> 0 && ruby.rand(100) < _maze.weave) {
          //# see if we can weave over/under the cell at (nx,ny)
          if (_maze.weave_allowed(_x, _y, nx, ny, direction)) {
            return direction;
          }
        }
      }

      while (_tries!.isEmpty) {
        if (_stack.isEmpty) {
          _pending = false;
          return null;
        } else {
          var _tmp = _stack.removeLast();
          _x = _tmp[0] as int;
          _y = _tmp[1] as int;
          _tries = _tmp[2] as List<int>?;
        }
      }
    }
  }

}
