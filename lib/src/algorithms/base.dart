part of theseus.algorithms;
    // A minimal abstract superclass for maze algorithms to descend
    // from, mostly as a helper to provide some basic, common
    // functionality.
   abstract class Base{
      // The maze object that the algorithm will operate on.
      Maze get maze=>_maze;
      Maze _maze;
      bool _pending = true;

      // Create a new algorithm object that will operate on the
      // given maze.
      Base(this._maze, MazeOptions options);

      // Returns true if the algorithm has not yet completed.
      bool get pending {
        return _pending;
      }

      // Execute a single step of the algorithm. Return true
      // if the algorithm is still pending, or false if it has
      // completed.
      bool step(){
        //return false unless pending?
        if (!pending){
          return false;
        }
        return do_step();
      }
      
      bool do_step();
    }
