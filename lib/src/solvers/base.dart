part of theseus.solvers;
//require 'theseus/maze'
//
//module Theseus
//  module Solvers
    //# The abstract superclass for solver implementations. It simply provides
    //# some helper methods that implementations would otherwise have to duplicate.
    abstract class Base{
      //# The maze object that this solver will provide a solution for.
      Maze get maze=>_maze;
      Maze _maze;

      //# The point (2-tuple array) at which the solution path should begin.
      Position get a=>_a;
      Position _a;

      //# The point (2-tuple array) at which the solution path should end.
      Position get b=>_b;
      Position _b;

      List<Position> _solution;

      //# Create a new solver instance for the given maze, using the given
      //# start (+a+) and finish (+b+) points. The solution will not be immediately
      //# generated; to do so, use the //#step or //#solve methods.
      Base(Maze maze, [a, b]){
        _maze = maze;
        if (a == null){
          a = maze.start();
        }
        if (b == null){
                  b = maze.finish();
                }
        _a = a;
        _b = b;
        _solution = null;
      }

      //# Returns +true+ if the solution has been generated.
      bool get solved/*?*/{
        return solution != null;
      }

      //# Returns the solution path as an array of 2-tuples, beginning with //#a and
      //# ending with //#b. If the solution has not yet been generated, this will
      //# generate the solution first, and then return it.
      List<Position> solution(){
        if (!solved) {solve();}//solve unless solved?
        return _solution;
      }

      //# Generates the solution to the maze, and returns +self+. If the solution
      //# has already been generated, this does nothing.
      Base solve(){
        while (!solved/*?*/){
          step();
        }

        return this;//self
      }

      //# If the maze is solved, this yields each point in the solution, in order.
      //#
      //# If the maze has not yet been solved, this yields the result of calling
      //# //#step, until the maze has been solved.
     Iterable<bool> each() sync*{
        if (solved/*?*/){
          solution().forEach((s){ yield s; });
        }else{
          //yield s while s = step()
          var s;
          while (s = step()){
            yield s;
          }

        }
      }

      //# Returns the solution (or, if the solution is not yet fully generated,
      //# the current_solution) as a Theseus::Path object.
      Path to_path(options/*={}*/){
        var path = _maze.new_path(options);
        var prev = _maze.entrance;

        var how;
        (_solution!=null?_solution: current_solution()).forEach((pt){
          how = path.link(prev, pt);
          path.set(pt, how);
          prev = pt;
        });

        how = path.link(prev, _maze.exit);
        path.set(_maze.exit, how);

        return path;
      }

      //# Returns the current (potentially partial) solution to the maze. This
      //# is for use while the algorithm is running, so that the current best-solution
      //# may be inspected (or displayed).
      List current_solution()
      {
        throw new UnimplementedError("solver subclasses must implement 'current_solution'");
      }

      //# Runs a single iteration of the solution algorithm. Returns +false+ if the
      //# algorithm has completed, and non-nil otherwise. The return value is
      //# algorithm-dependent.
      bool step()
      {
        throw new UnimplementedError("solver subclasses must implement 'step'");
      }
    }
