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
      Position point;

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
      List<Position> get history=>_history;
      List<Position> _history;

      Node(this.point, this.under, this.path_cost, this.estimate,List<Position> history){ //#:nodoc:
        //_point, _under, _path_cost, _estimate = point, under, path_cost, estimate
        _history = history;
        cost = path_cost + estimate;
      }

     int compareTo(Node other){
          return cost.compareTo(other.cost);
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
      List<List<int>> _visits;

      Astar(Maze maze/*, a=maze.start, b=maze.finish*/):super(maze,maze.start,maze.finish){ //#:nodoc:
        _open = new Node(_a, false, 0, _estimate(_a), []);
        _visits = new List.generate(_maze.height,(_)=>new List.generate(_maze.width,(_)=> 0));
      }

      List<Position> current_solution(){ //#:nodoc:
        return new List.from(_open.history)..add(_open.point);
      }

      @override
      Position step(){ //#:nodoc:
        if (_open ==null ){//!_open
          return null;
        }

        Node current = _open;

        if (current.point == _b){
          _open = null;
          _solution = new List.from(current.history)..add(_b);
        }else{
          _open = _open.next;

          _visits[current.point.y][current.point.x] |= current.under ? 2 : 1;

          var cell = _maze[current.point];

          List<int> directions = _maze.potential_exits_at(current.point.x, current.point.y);
          directions.forEach((dir){
            var _try = current.under ? (dir << Maze.UNDER_SHIFT) : dir;
            if (cell & _try != 0){
             Position point = _move(current.point, dir);
              //next unless _maze.valid?(point[0], point[1])
              if (!_maze.valid(point.x, point.y)){
               return;
              }
              var under = ((_maze[point] >> Maze.UNDER_SHIFT) & _maze.opposite(dir) != 0);
              _add_node(point, under, current.path_cost+1,new List.from(current.history)..add(current.point));
            }
          });
        }

        return current.point; //current
      }

      //private

      _estimate(Position pt){ //#:nodoc:
        Math.sqrt(Math.pow((_b.x - pt.x),2)/* **2 */ + Math.pow((_b.y - pt.y),2) /* **2 */);
      }

      _add_node(Position pt,bool under,int path_cost,List<Position> history){ //#:nodoc:
        if (_visits[pt.y][pt.x] & (under ? 2 : 1) != 0){
         return; 
        }

        var node = new Node(pt, under, path_cost, _estimate(pt), history);

        if (_open!=null){
          var p = null;
          Node n = _open;

          while (n!=null && n.compareTo(node)==-1 /*n< node*/){
            p = n;
            n = n.next;
          }

          if (p == null){
            node.next = _open;
            _open = node;
          }else{
            node.next = n;
            p.next = node;
          }

          //# remove duplicates
          while (node.next!=null && node.next.point == node.point){
            node.next = node.next.next;
          }
        }else{
          _open = node;
        }
      }

      Position _move(Position pt,int direction) {//#:nodoc:
        return new Position.xy(pt.x + _maze.dx(direction), pt.y + _maze.dy(direction));
      }
    }
