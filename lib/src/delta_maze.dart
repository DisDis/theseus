part of theseus;
//require 'theseus/maze'
//
//module Theseus
  //# A "delta" maze is one in which the field is tesselated into triangles. Thus,
  //# each cell has three potential exits: east, west, and either north or south
  //# (depending on the orientation of the cell).
  //#
  //#      __  __  __
  //#    /\  /\  /\  /
  //#   /__\/__\/__\/
  //#   \  /\  /\  /\ 
  //#    \/__\/__\/__\ 
  //#    /\  /\  /\  /
  //#   /__\/__\/__\/
  //#   \  /\  /\  /\ 
  //#    \/__\/__\/__\ 
  //#   
  //#
  //# Delta mazes in Theseus do not support either weaving, or symmetry.
  //#
  //#   maze = Theseus::DeltaMaze.generate(width: 10)
  //#   puts maze
  class DeltaMaze extends Maze{
    DeltaMaze(MazeOptions options) :super(options){//#:nodoc:
      if (_weave > 0){
       throw new ArgumentError("weaving is not supported for delta mazes");
      }
    }

    //# Returns +true+ if the cell at (x,y) is oriented so the vertex is "up", or
    //# north. Cells for which this returns +true+ may have exits on the south border,
    //# and cells for which it returns +false+ may have exits on the north.
    bool points_up/*?*/(int x,int y){
      return(x + y) % 2 == height % 2;
    }

    List<int> potential_exits_at(int x,int y){ //#:nodoc:
      int vertical = points_up/*?*/(x, y) ? Maze.S : Maze.N;

      //# list the vertical direction twice. Otherwise the horizontal direction (E/W)
      //# will be selected more often (66% of the time), resulting in mazes with a
      //# horizontal bias.
      return [vertical, vertical, Maze.E, Maze.W];
    }
  
    @override
    V to<V, P>(FormatType format, [P options]) {
        if (format == FormatType.ascii) {
            return new formatters.ASCIIDelta(this) as V;
        }
        else if (format == FormatType.png) {
            return new formatters.PNGDelta(this, options as formatters.PNGFormatterOptions) as V;
            //Formatters::PNG.const_get(type).new(self, options).to_blob
        }
        else {
            throw new ArgumentError("unknown format: $format");
        }
    }
}
