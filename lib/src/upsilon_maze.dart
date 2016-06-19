part of theseus;
//require 'theseus/maze'
//
//module Theseus
  //# An upsilon maze is one in which the field is tesselated into octogons and
  //# squares:
  //#
  //#    _   _   _   _
  //#   / \_/ \_/ \_/ \
  //#   | |_| |_| |_| |
  //#   \_/ \_/ \_/ \_/
  //#   |_| |_| |_| |_|
  //#   / \_/ \_/ \_/ \
  //#   | |_| |_| |_| |
  //#   \_/ \_/ \_/ \_/
  //#
  //# Upsilon mazes in Theseus support weaving, but not symmetry (yet).
  //#
  //#   maze = Theseus::UpsilonMaze.generate(width: 10)
  //#   puts maze
  class UpsilonMaze extends Maze{
    UpsilonMaze(MazeOptions options) : super(options);

    List<int> potential_exits_at(int x,int y){ //#:nodoc:
      if ((x+y) % 2 == 0 ){//# octogon
        return [Maze.N, Maze.S, Maze.E, Maze.W, Maze.NW, Maze.NE, Maze.SW, Maze.SE];
      }else {//# square
       return [Maze.N, Maze.S, Maze.E, Maze.W];
      }
    }

    @override
    List<int> perform_weave(int from_x,int  from_y,int  to_x,int  to_y,int  direction){ //#:nodoc:
      apply_move_at(to_x, to_y, direction << Maze.UNDER_SHIFT);
      apply_move_at(to_x, to_y, opposite(direction) << Maze.UNDER_SHIFT);

      var movePos = move(to_x, to_y, direction);
      var nx = movePos.x;
      var ny = movePos.y;
      return [nx, ny, direction];
    }

  @override
  to(FormatType format, [options]) {
    if (format == FormatType.ascii) {
         return new formatters.ASCIIUpsilon(this, options);
       } 
      else if (format == FormatType.png) {
        return new formatters.PNGUpsilon(this, options);
         //Formatters::PNG.const_get(type).new(self, options).to_blob
      }
       else
       {
         throw new ArgumentError("unknown format: $format");
       }
  }
}
