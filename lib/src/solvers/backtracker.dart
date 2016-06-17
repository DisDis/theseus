part of theseus.solvers;
//require 'theseus/solvers/base'
//
//module Theseus
//  module Solvers
    //# An implementation of a recursive backtracker for solving a maze. Although it will
    //# work (eventually) for multiply-connected mazes, it will almost certainly not
    //# return an optimal solution in that case. Thus, this solver is best suited only
    //# for "perfect" mazes (those with no loops).
    //#
    //# For mazes that contain loops, see the Theseus::Solvers::Astar class.
class BacktrackerStackItem{
  final Position position;//[0]
  final List<int> directions;//[1]
  BacktrackerStackItem(this.position, this.directions);
}

    class Backtracker extends Base{
      List<List<int>> _visits;
      List<BacktrackerStackItem> _stack;
      Backtracker(Maze maze):super(maze,maze.start,maze.finish){ //#:nodoc:
        _visits = new List.generate(_maze.height,(_)=>new List.generate(_maze.width,(_)=> 0));
        _stack = [];
      }

     final Map VISIT_MASK = { false : 1, true : 2 };

      Iterable<Position> current_solution(){//#:nodoc:
        return _stack.map((item)=>item.position); //_stack[1..-1].map { |item| item[0] };
      }

      final BacktrackerStackItem FAIL_POSITION = new BacktrackerStackItem(null,null);
      
     bool step(){//#:nodoc:
        if (_stack.length ==1 && _stack[0] == FAIL_POSITION/*[:fail]*/){
          return false;
        }else if (_stack.isEmpty){
          _stack.add(FAIL_POSITION);
          _stack.add([_a, _maze.potential_exits_at(_a.x, _a.y).dup()]);
          return _a != null;
        }else if (_stack.last.position == _b){
          _solution = _stack.map((item)=>item.position);//_stack[1..-1].map { |pt, tries| pt };
          return false;
        }else{
          Position xy = _stack.last.position;//_stack.last[0];
          var cell = _maze.getCell(x, y);
          while (true){
            var _try = _stack.last.directions.pop;//[1].pop;

            if (_try == null /*.nil?*/){
              var spot = _stack.pop;
              xy = spot.position;//[0];
              return ":backtrack";
            }else if ((cell & _try) != 0){
              //# is the current path an "under" path for the current cell (x,y)?
              var is_under = (_try & Maze.UNDER != 0);

              var dir = is_under ? (_try >> Maze.UNDER_SHIFT) : _try;
              var opposite = _maze.opposite(dir);

              var nxny = _maze.move(x, y, dir);

              //# is the new path an "under" path for the next cell (nx,ny)?
              bool going_under = _maze[nxny] & (opposite << Maze.UNDER_SHIFT) != 0;

              //# might be out of bounds, due to the entrance/exit passages
              //next if !_maze.valid?(nx, ny) || (_visits[ny][nx] & VISIT_MASK[going_under] != 0)
                  if (!_maze.valid(nxny.x, nxny.y) || (_visits[nxny.y][nxny.x] & VISIT_MASK[going_under] != 0)){
                    continue;
                  }

              _visits[nxny.y][nxny.x] |= VISIT_MASK[going_under];
              var ncell = _maze[nxny];
              var p = nxny.dup();//[nx, ny];

              if (ncell & (opposite << Maze.UNDER_SHIFT) != 0){ //# underpass
                unders = (ncell & Maze.UNDER) >> Maze.UNDER_SHIFT;
                exit_dir = unders & ~opposite;
                directions = [exit_dir << Maze.UNDER_SHIFT];
              }else{
                directions = _maze.potential_exits_at(nxny.x, nxny.y) - [_maze.opposite(dir)];
              }

              _stack.add(new BacktrackerStackItem(p, directions));
              return p.dup;
            }
          }
        }
      }
    }
