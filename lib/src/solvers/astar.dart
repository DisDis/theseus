part of theseus.solvers;


//# This is the data structure used by the Astar solver to keep track of the
    //# current cost of each examined cell and its associated history (path back
    //# to the start).
    //#
    //# Although you will rarely need to use this class, it is documented because
    //# applications that wish to visualize the A* algorithm can use the open set
    //# of Node instances to draw paths through the maze as the algorithm runs.
    class Node{
      //include Comparable

      //# The point in the maze associated with this node.
      var point;

      //# Whether the node is on the primary plane (+false+) or the under plane (+true+)
      bool under;

      //# The path cost of this node (the distance from the start to this cell,
      //# through the maze)
      int path_cost;
      
      //# The (optimistic) estimate for how much further the exit is from this node.
      int estimate;
      
      //# The total cost associated with this node (path_cost + estimate)
      int cost;
      
      //# The next node in the linked list for the set that this node belongs to.
      Node next;

      //# The array of points leading from the starting point, to this node.
      List get history=>_history;
      List _history;

      Node(this.point, this.under, this.path_cost, this.estimate, history){ //#:nodoc:
        //_point, _under, _path_cost, _estimate = point, under, path_cost, estimate
        _history = history;
        cost = path_cost + estimate;
      }

      // TODO:Comparable
//      def <=>(node) //#:nodoc:
//        cost <=> node.cost
//      }
    }

//require 'theseus/solvers/base'
//
//module Theseus
//  module Solvers
    //# An implementation of the A* search algorithm. Although this can be used to
    //# search "perfect" mazes (those without loops), the recursive backtracker is
    //# more efficient in that case.
    //#
    //# The A* algorithm really shines, though, with multiply-connected mazes
    //# (those with non-zero braid values, or some symmetrical mazes). In this case,
    //# it is guaranteed to return the shortest path through the maze between the
    //# two points.
    class Astar extends Base{

      

      //# The open set. This is a linked list of Node instances, used by the A*
      //# algorithm to determine which nodes remain to be considered. It is always
      //# in sorted order, with the most likely candidate at the head of the list.
      Node get open=>_open;
      Node _open;

      Astar(Maze maze/*, a=maze.start, b=maze.finish*/):super(maze,maze.start,maze.finish){ //#:nodoc:
        _open = new Node(_a, false, 0, _estimate(_a), []);
        _visits = new List.generator(_maze.height,(_)=>new List.generator(_maze.width,(_)=> 0));
      }

      current_solution(){ //#:nodoc:
        return _open.history + [_open.point];
      }

      @override
      bool step(){ //#:nodoc:
        if (!_open){
          return false;
        }

        bool current = _open;

        if (current.point == _b){
          _open = null;
          _solution = current.history + [_b];
        }else{
          _open = _open.next;

          _visits[current.point[1]][current.point[0]] |= current.under ? 2 : 1;

          cell = _maze[current.point];

          directions = _maze.potential_exits_at(current.point[0], current.point[1]);
          directions.forEach((dir){
            var _try = current.under ? (dir << Maze.UNDER_SHIFT) : dir;
            if (cell & _try != 0){
              point = _move(current.point, dir);
              //next unless _maze.valid?(point[0], point[1])
              if (!_maze.valid(point.x, point.y)){
               return;
              }
              var under = ((_maze[point] >> Maze.UNDER_SHIFT) & _maze.opposite(dir) != 0);
              _add_node(point, under, current.path_cost+1, current.history + [current.point]);
            }
          });
        }

        return current;
      }

      //private

      _estimate(Position pt){ //#:nodoc:
        Math.sqrt(Math.pow((_b[0] - pt.x),2)/* **2 */ + Math.pow((_b[1] - pt.y),2) /* **2 */);
      }

      _add_node(pt, under, path_cost, history){ //#:nodoc:
        if (_visits[pt[1]][pt[0]] & (under ? 2 : 1) != 0){
         return; 
        }

        var node = new Node(pt, under, path_cost, _estimate(pt), history);

        if (_open){
          var p = null , n = _open;

          while (n && n < node){
            p = n;
            n = n.next();
          }

          if (p == null){
            node.next = _open;
            _open = node;
          }else{
            node.next = n;
            p.next = node;
          }

          //# remove duplicates
          while (node.next && node.next.point == node.point){
            node.next = node.next.next;
          }
        }else{
          _open = node;
        }
      }

      _move(pt, direction) {//#:nodoc:
        return [pt[0] + _maze.dx(direction), pt[1] + _maze.dy(direction)];
      }
    }
