part of theseus;

enum LinkType{
  over,under
}
//module Theseus
  //# The Path class is used to represent paths (and, generally, regions) within
  //# a maze. Arbitrary metadata can be associated with these paths, as well.
  //#
  //# Although a Path can be instantiated directly, it is generally more convenient
  //# (and less error-prone) to instantiate them via Maze//#new_path.
  class Path{
    //# Represents the exit paths from each cell in the Path. This is a Hash of bitfields,
    //# and should be treated as read-only.
    Map get paths=>_paths;
    Map _paths;

    //# Represents the cells within the Path. This is a Hash of bitfields, with bit 1
    //# meaning the primary plane for the cell is set for this Path, and bit 2 meaning
    //# the under plane for the cell is set.
    Map get cells=>_cells;
    Map _cells;

    //# Instantiates a new plane for the given +maze+ instance, and with the given +meta+
    //# data. Initially, the path is empty.
    Path(Maze maze, meta/*={}*/){
      _maze = maze;
      _paths = new Map();
      _cells = new Map();
      _meta = meta;
    }
    
    Maze _maze;
    dynamic _meta;

    //# Returns the metadata for the given +key+.
    operator [](key){
      return _meta[key];
    }

    //# Marks the given +point+ as occupied in this path. If +how+ is +:over+, the
    //# point is set in the primary plane. Otherwise, it is set in the under plane.
    //#
    //# The +how+ parameter is usually used in conjunction with the return value of
    //# the //#link method:
    //#
    //#   how = path.link(from, to)
    //#   path.set(to, how)
    void set(point,[LinkType how = LinkType.over]) {
      _cells[point] |= (how == LinkType.over ? 1 : 2);
    }
    //# Returns true if the given point is occuped in the path, for the given plane.
    //# If +how+ is +:over+, the primary plane is queried. Otherwise, the under
    //# plane is queried.
//    bool set(point,LinkType how = LinkType.over){
//      return _cells[point] & (how == LinkType.over ? 1 : 2) != 0;
//    }

    //# Creates a link between the two given points. The points must be adjacent.
    //# If the corresponding passage in the maze moves into the under plane as it
    //# enters +to+, this method returns +:under+. Otherwise, it returns +:over+.
    //#
    //# If the two points are not adjacent, no link is created.
    LinkType link(from, to){
      var direction = _maze.relative_direction(from, to);
      if (direction != null){
        var opposite = _maze.opposite(direction);

        if (_maze.valid(from[0], from[1])){
          if (_maze[new Position.xy(from[0], from[1])] & direction == 0){
            direction <<= Maze.UNDER_SHIFT ;
          }
          _paths[from] |= direction;
        }

        if (_maze[new Position.xy(to[0], to[1])] & opposite == 0){
          opposite <<= Maze.UNDER_SHIFT;
        }
        _paths[to] |= opposite;

        return (opposite & Maze.UNDER == 0) ? LinkType.over : LinkType.under;
      }

      return LinkType.over;
    }

    //# Adds all path and cell information from the parameter (which must be a
    //# Path instance) to the current Path object. The metadata from the parameter
    //# is not copied.
    add_path(Path path){
      path.paths.forEach((pt, value) {
        _paths[pt] |= value;
      });

      path.cells.forEach((pt, value) {
        _cells[pt] |= value;
      });
    }

    //# Returns true if there is a path from the given point, in the given direction.
    bool path(point, direction){
      return _paths[point] & direction != 0;
    }
  }
//}
