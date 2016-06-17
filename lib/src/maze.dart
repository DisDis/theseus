part of theseus;

class Position{
  int x;
  int y;
  Position();
  Position.xy(this.x,this.y);
}

enum SymmetryType {
  x ,y,xy,radial
}

enum WrapType{
  x ,y,xy
}
enum FormatType{
  ascii
}

class MazeOptions{
  /**The number of columns in the maze. Note that different
      //#                maze types count columns and rows differently; you'll
      //#                want to see individual maze types for more info.
       
       */
  final int width;
      //# [:]      The number of rows in the maze.
  final int height;
      //# [:]   The maze algorithm to use. This should be a class,
      //#                adhering to the interface described by Theseus::Algorithms::Base.
      //#                It defaults to Theseus::Algorithms::RecursiveBacktracker.
  final Type algorithm;
      //# [:]    The symmetry to be used when generating the maze. This
      //#                defaults to +:none+, but may also be +:x+ (to have the
      //#                maze mirrored across the x-axis), +:y+ (to mirror the
      //#                maze across the y-axis), +:xy+ (to mirror across both
      //#                axes simultaneously), and +:radial+ (to mirror the maze
      //#                radially about the center). Some symmetry types may
      //#                result in loops being added to the maze, regardless of
      //#                the braid value (see the +:braid+ parameter).
      //#                (NOTE: not all maze types support symmetry equally.)
  final SymmetryType symmetry;
      //# [:randomness]  An integer between 0 and 100 (inclusive) indicating how
      //#                randomly the maze is generated. A 0 means that the maze
      //#                passages will prefer to go straight whenever possible.
      //#                A 100 means the passages will choose random directions
      //#                as often as possible.
  final int randomness;
      //# [:mask]        An instance of Theseus::Mask (or something that acts
      //#                similarly). This can be used to constrain the maze so that
      //#                it fills or avoids specific areas, so that shapes and
      //#                patterns can be made. (NOTE: not all algorithms support
      //#                masks.)
  final  BaseMask mask;
      //# [:weave]       An integer between 0 and 100 (inclusive) indicating how
      //#                frequently passages move under or over other passages.
      //#                A 0 means the passages will never move over/under other
      //#                passages, while a 100 means they will do so as often
      //#                as possible. (NOTE: not all maze types and algorithms
      //#                support weaving.)
  final int weave;
      //# [:braid]       An integer between 0 and 100 (inclusive) representing
      //#                the percentage of dead-ends that should be removed after
      //#                the maze has been generated. Dead-ends are removed by
      //#                extending them in some direction until they join with
      //#                another passage. This will introduce loops into the maze,
      //#                making it "multiply-connected". A braid value of 0 will
      //#                always result in a "perfect" maze (with no loops), while
      //#                a value of 100 will result in a maze with no dead-ends.
  final int braid;
      //# [:wrap]        Indicates which edges of the maze should wrap around.
      //#                +:x+ will cause the left and right edges to wrap, and
      //#                +:y+ will cause the top and bottom edges to wrap. You
      //#                can specify +:xy+ to wrap both left-to-right and
      //#                top-to-bottom. The default is +:none+ (for no wrapping).
  final WrapType wrap;
      //# [:entrance]    A 2-tuple indicating from where the maze is entered.
      //#                By default, the maze's entrance will be the upper-left-most
      //#                point. Note that it may lie outside the bounds of the maze
      //#                by one cell (e.g. [-1,0]), indicating that the entrance
      //#                is on the very edge of the maze.
  final Position entrance;
      //# [:exit]        A 2-tuple indicating from where the maze is exited.
      //#                By default, the maze's entrance will be the lower-right-most
      //#                point. Note that it may lie outside the bounds of the maze
      //#                by one cell (e.g. [width,height-1]), indicating that the
      //#                exit is on the very edge of the maze.
  final Position exit;
      //# [:prebuilt] Sometimes, you may want the new maze to be considered to be
  //#                generated, but not actually have anything generated into it.
  //#                You can set the +:prebuilt+ parameter to +true+ in this case,
  //#                allowing you to then set the contents of the maze by hand,
  //#                using the //#[]= method.
  final bool prebuilt;
  MazeOptions({this.algorithm,this.braid,this.entrance, this.exit,this.height, this.mask, this.prebuilt:false, this.randomness, this.symmetry, this.weave, this.width, this.wrap});
}

//import 'mask.dart';
//import 'path.dart';
//import 'algorithms/recursive_backtracker.dart';

//module Theseus
  ////# Theseus::Maze is an abstract class, intended to act solely as a superclass
  ////# for specific maze types. Subclasses include OrthogonalMaze, DeltaMaze,
  ////# SigmaMaze, and UpsilonMaze.
  ////#
  ////# Each cell in the maze is a bitfield. The bits that are set indicate which
  ////# passages exist leading AWAY from this cell. Bits in the low byte (corresponding
  ////# to the PRIMARY bitmask) represent passages on the normal plane. Bits
  ////# in the high byte (corresponding to the UNDER bitmask) represent passages
  ////# that are passing under this cell. (Under/over passages are controlled via the
  ////# //#weave setting, and are not supported by all maze types.)
  abstract class Maze{
    static const int N  = 0x01; //# North
    static const int S  = 0x02; //# South
  static const int E  = 0x04; //# East
  static const int W  = 0x08; //# West
  static const int NW = 0x10; //# Northwest
  static const int NE = 0x20; //# Northeast
  static const int SW = 0x40; //# Southwest
  static const int SE = 0x80; //# Southeast
  

    //# bitmask identifying directional bits on the primary plane
  static const int PRIMARY  = 0x000000FF;

    //# bitmask identifying directional bits under the primary plane
  static const int UNDER    = 0x0000FF00;

    //# bits reserved for use by individual algorithm implementations
      static const int RESERVED = 0xFFFF0000;

    //# The size of the PRIMARY bitmask (e.g. how far to the left the
    //# UNDER bitmask is shifted).
     static const int UNDER_SHIFT = 8;
     
     bool _generated = false;

    //# The algorithm object used to generate this maze. Defaults to
    //# an instance of Algorithms::RecursiveBacktracker.
     RecursiveBacktracker/*attr_reader :*/ get algorithm=>_algorithm;
     RecursiveBacktracker/*attr_reader :*/ _algorithm;

    //# The width of the maze (number of columns).
    //#
    //# In general, it is safest to use the //#row_length method for a particular
    //# row, since it is theoretically possible for a maze subclass to describe
    //# a different width for each row.
    int get width=>_width;
    int _width;

    //# The height of the maze (number of rows).
    int get height=>_height;
    int _height;

    //# An integer between 0 and 100 (inclusive). 0 means passages will only
    //# change direction when they encounter a barrier they cannot move through
    //# (or under). 100 means that as passages are built, a new direction will
    //# always be randomly chosen for each step of the algorithm.
    int get randomness=>_randomness;
    int _randomness;

    //# An integer between 0 and 100 (inclusive). 0 means passages will never
    //# move over or under existing passages. 100 means whenever possible,
    //# passages will move over or under existing passages. Note that not all
    //# maze types support weaving.
    int get weave=>_weave;
    int _weave;

    //# An integer between 0 and 100 (inclusive), signifying the percentage
    //# of deadends in the maze that will be extended in some direction until
    //# they join with an existing passage. This will create loops in the
    //# graph. Thus, 0 is a "perfect" maze (with no loops), and 100 is a
    //# maze that is totally multiply-connected, with no dead-ends.
    int get braid=>_braid;
        int _braid;

    //# One of :none, :x, :y, or :xy, indicating which boundaries the maze
    //# should wrap around. The default is :none, indicating no wrapping.
    //# If :x, the maze will wrap around the left and right edges. If
    //# :y, the maze will wrap around the top and bottom edges. If :xy, the
    //# maze will wrap around both edges.
    //#
    //# A maze that wraps in a single direction may be mapped onto a cylinder.
    //# A maze that wraps in both x and y may be mapped onto a torus.
    WrapType get wrap=>_wrap;
    WrapType _wrap;
   

    //# A Theseus::Mask (or similar) instance, that is used by the algorithm to
    //# determine which cells in the space are allowed. This lets you create
    //# mazes that fill shapes, or flow around patterns.
    BaseMask get mask => _mask;
    BaseMask _mask;

    //# One of :none, :x, :y, :xy, or :radial. Note that not all maze types
    //# support symmetry. The :x symmetry means the maze will be mirrored
    //# across the x axis. Similarly, :y symmetry means the maze will be
    //# mirrored across the y axis. :xy symmetry causes the maze to be
    //# mirrored across both axes, and :radial symmetry causes the maze to
    //# be mirrored radially about the center of the maze.
    SymmetryType get symmetry=>_symmetry;
    SymmetryType _symmetry;

    //# A 2-tuple (array) indicating the x and y coordinates where the maze
    //# should be entered. This is used primarly when generating the solution
    //# to the maze, and generally defaults to the upper-left corner.
    Position get entrance=>_entrance;
    Position _entrance;
    
    List<Position> _deadends;

    //# A 2-tuple (array) indicating the x and y coordinates where the maze
    //# should be exited. This is used primarly when generating the solution
    //# to the maze, and generally defaults to the lower-right corner.
    Position get exit=>_exit;
    Position _exit;

    List<List> _cells;
    
    //# A short-hand method for creating a new maze object and causing it to
    //# be generated, in one step. Returns the newly generated maze.
//    static /*self.*/generate(options/*={}*/){
//     throw new UnimplementedError("Maze.generate");
      // new(options).generate!;
//   }

    //# Creates and returns a new maze object. Note that the maze will _not_
    //# be generated; the maze is initially blank.
    //#
    //# Many options are supported:
    //#
    //# [:width]       The number of columns in the maze. Note that different
    //#                maze types count columns and rows differently; you'll
    //#                want to see individual maze types for more info.
    //# [:height]      The number of rows in the maze.
    //# [:algorithm]   The maze algorithm to use. This should be a class,
    //#                adhering to the interface described by Theseus::Algorithms::Base.
    //#                It defaults to Theseus::Algorithms::RecursiveBacktracker.
    //# [:symmetry]    The symmetry to be used when generating the maze. This
    //#                defaults to +:none+, but may also be +:x+ (to have the
    //#                maze mirrored across the x-axis), +:y+ (to mirror the
    //#                maze across the y-axis), +:xy+ (to mirror across both
    //#                axes simultaneously), and +:radial+ (to mirror the maze
    //#                radially about the center). Some symmetry types may
    //#                result in loops being added to the maze, regardless of
    //#                the braid value (see the +:braid+ parameter).
    //#                (NOTE: not all maze types support symmetry equally.)
    //# [:randomness]  An integer between 0 and 100 (inclusive) indicating how
    //#                randomly the maze is generated. A 0 means that the maze
    //#                passages will prefer to go straight whenever possible.
    //#                A 100 means the passages will choose random directions
    //#                as often as possible.
    //# [:mask]        An instance of Theseus::Mask (or something that acts
    //#                similarly). This can be used to constrain the maze so that
    //#                it fills or avoids specific areas, so that shapes and
    //#                patterns can be made. (NOTE: not all algorithms support
    //#                masks.)
    //# [:weave]       An integer between 0 and 100 (inclusive) indicating how
    //#                frequently passages move under or over other passages.
    //#                A 0 means the passages will never move over/under other
    //#                passages, while a 100 means they will do so as often
    //#                as possible. (NOTE: not all maze types and algorithms
    //#                support weaving.)
    //# [:braid]       An integer between 0 and 100 (inclusive) representing
    //#                the percentage of dead-ends that should be removed after
    //#                the maze has been generated. Dead-ends are removed by
    //#                extending them in some direction until they join with
    //#                another passage. This will introduce loops into the maze,
    //#                making it "multiply-connected". A braid value of 0 will
    //#                always result in a "perfect" maze (with no loops), while
    //#                a value of 100 will result in a maze with no dead-ends.
    //# [:wrap]        Indicates which edges of the maze should wrap around.
    //#                +:x+ will cause the left and right edges to wrap, and
    //#                +:y+ will cause the top and bottom edges to wrap. You
    //#                can specify +:xy+ to wrap both left-to-right and
    //#                top-to-bottom. The default is +:none+ (for no wrapping).
    //# [:entrance]    A 2-tuple indicating from where the maze is entered.
    //#                By default, the maze's entrance will be the upper-left-most
    //#                point. Note that it may lie outside the bounds of the maze
    //#                by one cell (e.g. [-1,0]), indicating that the entrance
    //#                is on the very edge of the maze.
    //# [:exit]        A 2-tuple indicating from where the maze is exited.
    //#                By default, the maze's entrance will be the lower-right-most
    //#                point. Note that it may lie outside the bounds of the maze
    //#                by one cell (e.g. [width,height-1]), indicating that the
    //#                exit is on the very edge of the maze.
    //# [:prebuilt]    Sometimes, you may want the new maze to be considered to be
    //#                generated, but not actually have anything generated into it.
    //#                You can set the +:prebuilt+ parameter to +true+ in this case,
    //#                allowing you to then set the contents of the maze by hand,
    //#                using the //#[]= method.
    Maze(MazeOptions options/*={}*/){
      _width = options.width !=null ?options.width : 10;
      _height = options.height !=null ? options.height : 10;

      _symmetry = options.symmetry != null ? options.symmetry : /*none*/null; //).to_sym
      _configure_symmetry();

      _randomness = options.randomness!=null ?options.randomness: 100;
      _mask = options.mask!=null?options.mask: new TransparentMask();
      _weave = options.weave!=null?options.weave:0;
      _braid = options.braid!=null?options.braid:0;
      _wrap = options.wrap != null? options.wrap: /*none*/null;

      _cells = _setup_grid();
      if (_cells == null){
        throw new Exception("expected #setup_grid to return the new grid");
      }

      _entrance = options.entrance != null?options.entrance: _default_entrance();
      _exit = options.exit != null? options.exit : _default_exit();

      var algorithm_class = options.algorithm!=null?options.algorithm: RecursiveBacktracker;
      _algorithm = resolveAlgorithms(algorithm_class,this, options);

      _generated = options.prebuilt;
   }

    //# Generates the maze if it has not already been generated. This is
    //# essentially the same as calling //#step repeatedly. If a block is given,
    //# it will be called after each step.
   Maze generate(){//!
      //yield if block_given? while step unless generated?
     while (!_generated) {
       step();
     }
      return this;//self
   }

    //# Creates a new Theseus::Path object based on this maze instance. This can
    //# be used to (for instance) create special areas of the maze or routes through
    //# the maze that you want to color specially. The following demonstrates setting
    //# a particular cell in the maze to a light-purple color:
    //#
    //#   path = maze.new_path(color: 0xff7fffff)
    //#   path.set([5,5])
    //#   maze.to(:png, paths: [path])
   Path new_path(meta/*={}*/){
      return new Path(this, meta);
   }

    //# Instantiates and returns a new solver instance which encapsulates a
    //# solution algorithm. The options may contain the following keys:
    //#
    //# [:type] This defaults to +:backtracker+ (for the Theseus::Solvers::Backtracker
    //#         solver), but may also be set to +:astar+ (for the Theseus::Solvers::Astar
    //#         solver).
    //# [:a]    A 2-tuple (defaulting to //#start) that says where in the maze the
    //#         solution should begin.
    //# [:b]    A 2-tuple (defaulting to //#finish) that says where in the maze the
    //#         solution should finish.
    //#
    //# The returned solver will not yet have generated the solution. Use
    //# Theseus::Solvers::Base//#solve or Theseus::Solvers::Base//#step to generate the
    //# solution.
   solvers.Base new_solver(options/*={}*/){
//      type = options.type!=null? options.type ? backtracker();
//
//      require "theseus/solvers///#{type}"
//      klass = Theseus::Solvers.const_get(type.to_s.capitalize)
//
//      var a = options.a!=null?options.a : start();
//      var b = options.b!=null?options.b : finish();
//
//         return new klass(self, a, b);
      throw new UnimplementedError("new_solver");
      //TODO: fix
   }

    //# Returns the solution for the maze as an array of 2-tuples, each indicating
    //# a cell (in sequence) leading from the start to the finish.
    //#
    //# See //#new_solver for a description of the supported options.
    solvers.Base solve(options){
      return new_solver(options).solution;
   }

    //# Returns the bitfield for the cell at the given (+x+,+y+) coordinate.
    getCell(int x,int y){//operator [](x,y){
      return _cells[y][x];
   }
   operator [](Position xy){
     return getCell(xy.x,xy.y);
   }
   operator []=(Position xy,value){
     return setCell(xy.x,xy.y,value);
   }

    //# Sets the bitfield for the cell at the given (+x+,+y+) coordinate.
    setCell(int x,int y, value){//operator []=(x,y,value){
      return _cells[y][x] = value;
   }

    //# Completes a single iteration of the maze generation algorithm. Returns
    //# +false+ if the method should not be called again (e.g., the maze has
    //# been completed), and +true+ otherwise.
    bool step(){
      if (_generated){
      return false;
      };

      if (_deadends!=null && _deadends.isNotEmpty/*.any?*/) {
        var dead_end = _deadends.removeLast();// .pop
        _braidMethod(dead_end.x, dead_end.y);
        
        _generated = _deadends.isEmpty;// .empty?
        return !_generated;
      }

      if (_algorithm.step()) {
        return true;
      }else{
        return _finish_not();/*!*/
      }
    }

    //# Returns +true+ if the maze has been generated.
    bool generated(){//?
      return _generated;
    }

    //# Since //#entrance may be external to the maze, //#start returns the cell adjacent to
    //# //#entrance that lies within the maze. If //#entrance is already internal to the
    //# maze, this method returns //#entrance. If //#entrance is _not_ adjacent to any
    //# internal cell, this method returns +nil+.
    start(){
      return adjacent_point(_entrance);
    }

    //# Since //#exit may be external to the maze, //#finish returns the cell adjacent to
    //# //#exit that lies within the maze. If //#exit is already internal to the
    //# maze, this method returns //#exit. If //#exit is _not_ adjacent to any
    //# internal cell, this method returns +nil+.
    finish(){
      adjacent_point(_exit);
    }

    //# Returns an array of the possible exits for the cell at the given coordinates.
    //# Note that this does not take into account boundary conditions: a move in any
    //# of the returned directions may not actually be valid, and should be verified
    //# before being applied.
    //#
    //# This is used primarily by subclasses to allow for different shaped cells
    //# (e.g. hexagonal cells for SigmaMaze, octagonal cells for UpsilonMaze).
    List<int> potential_exits_at(int x,int y){
      throw new UnimplementedError("subclasses must implement //#potential_exits_at");
    }

    //# Returns true if the maze may be wrapped in the x direction (left-to-right).
    bool get wrap_x{//?
      return _wrap == WrapType.x || _wrap == WrapType.xy;
    }

    //# Returns true if the maze may be wrapped in the y direction (top-to-bottom).
    bool get wrap_y{//?
      return _wrap == WrapType.y || _wrap == WrapType.xy;
    }

    //# Returns true if the given coordinates are valid within the maze. This will
    //# be the case if:
    //#
    //# 1. The coordinates lie within the maze's bounds, and
    //# 2. The current mask for the maze does not restrict the location.
    //#
    //# If the maze wraps in x, the x coordinate is unconstrained and will be 
    //# mapped (via modulo) to the bounds. Similarly, if the maze wraps in y,
    //# the y coordinate will be unconstrained.
    bool valid(int x,int y){//?
      if (!wrap_y && (y < 0 || y >= height)) {
        return false;
      };
      y %= height;
      if (!wrap_x && (x < 0 || x >= row_length(y))){
        return false; 
      }
      x %= row_length(y);
      return _mask.getCell(x, y);
    }

    //# Moves the given (+x+,+y+) coordinates a single step in the given
    //# +direction+. If wrapping in either x or y is active, the result will
    //# be mapped to the maze's current bounds via modulo arithmetic. The
    //# resulting coordinates are returned as a 2-tuple.
    //#
    //# Example:
    //#
    //#   x2, y2 = maze.move(x, y, Maze::W)
   Position move(int x,int y,int direction){
      var nx = x + dx(direction);
      var ny = y + dy(direction);

      if (wrap_y){
        ny %= height;
      }
      if (wrap_x && ny > 0 && ny < height){
        nx %= row_length(ny); 
      }

      return new Position.xy(nx, ny);
    }

    //# Returns a array of all dead-ends in the maze. Each element of the array
    //# is a 2-tuple containing the coordinates of a dead-end.
    List<Position> dead_ends(){//
      List<Position> dead_ends = [];

      ruby.each_with_index(_cells, /*_cells.each_with_index do |row, y|*/
      (row, y) {
        ruby.each_with_index(row,(cell,x) { /*row.each_with_index do |cell, x|*/
          if (dead(cell)){
            dead_ends.add(new Position.xy(x, y));
          }
        });
      });

      return dead_ends;
    }

    //# Removes one cell from all dead-ends in the maze. Each call to this method
    //# removes another level of dead-ends, making the maze increasingly sparse.
    sparsify(){//!
      dead_ends().forEach((pos) {
        var x = pos.x;
        var y = pos.y;
        var cell = _cells[y][x];
        int direction = cell & PRIMARY;
        var movePos = move(x, y, direction);
        var nx = movePos.x;
        var ny = movePos.y;

        //# if the cell includes UNDER codes, shifting it all UNDER_SHIFT bits to the right
        //# will convert those UNDER codes to PRIMARY codes. Otherwise, it will
        //# simply zero the cell, resulting in a blank spot.
        _cells[y][x] >>= UNDER_SHIFT;

        //# if it's a weave cell (that moves over or under another corridor),
        //# nix it and move back one more, so we don't wind up with dead-ends
        //# underneath another corridor.
        if (_cells[ny][nx] & (opposite(direction) << UNDER_SHIFT) != 0) {
          _cells[ny][nx] &= ~((direction | opposite(direction)) << UNDER_SHIFT);
          var movePos = move(nx, ny, direction);
          nx = movePos.x;
          ny = movePos.y; 
        }

        _cells[ny][nx] &= ~opposite(direction);
      });
    }

    //# Returns the direction opposite to the given +direction+. This will work
    //# even if the +direction+ value is in the UNDER bitmask.
   int opposite(int direction){
      if (direction & UNDER != 0){
        return opposite(direction >> UNDER_SHIFT) << UNDER_SHIFT;
      }else{
        switch (direction){
        case N : return S;
        case S : return N;
        case E : return W;
        case W  :return E;
        case NE: return SW;
        case NW: return SE;
        case SE :return NW;
        case SW :return NE;
        default:
          //TODO: check original code
                  throw new UnimplementedError();
        }
      }
    }

    //# Returns the direction that is the horizontal mirror to the given +direction+.
    //# This will work even if the +direction+ value is in the UNDER bitmask.
    int hmirror(direction){
      if (direction & UNDER != 0 ){
        return hmirror(direction >> UNDER_SHIFT) << UNDER_SHIFT;
      }else{
        switch (direction){
        case E  : return W;
        case W  : return E;
        case NW : return NE;
        case NE : return NW;
        case SW : return SE;
        case SE : return SW;
        default: return direction;
        }
      }
    }

    //# Returns the direction that is the vertical mirror to the given +direction+.
    //# This will work even if the +direction+ value is in the UNDER bitmask.
    int vmirror(direction){
      if (direction & UNDER != 0){
        return vmirror(direction >> UNDER_SHIFT) << UNDER_SHIFT;
    }else{
        switch (direction){
        case N  : return S;
        case S  : return N;
        case NE : return SE;
        case NW : return SW;
        case SE : return NE;
        case SW : return NW;
        default: return  direction;
        }
      }
    }

    //# Returns the direction that results by rotating the given +direction+
    //# 90 degrees in the clockwise direction. This will work even if the +direction+
    //# value is in the UNDER bitmask.
    int clockwise(direction){
      if (direction & UNDER != 0){
        return clockwise(direction >> UNDER_SHIFT) << UNDER_SHIFT;
      }else{
        switch (direction){
        case N  : return E;
        case E  : return S;
        case S  : return W;
        case W  : return N;
        case NW : return NE;
        case NE : return SE;
        case SE : return SW;
        case SW : return NW;
        default:
          throw new UnimplementedError();
        }
      }
    }

    //# Returns the direction that results by rotating the given +direction+
    //# 90 degrees in the counter-clockwise direction. This will work even if
    //# the +direction+ value is in the UNDER bitmask.
    int counter_clockwise(direction){
      if (direction & UNDER != 0){
        return counter_clockwise(direction >> UNDER_SHIFT) << UNDER_SHIFT;
      }else{
        switch (direction){
        case N  : return W;
        case W  : return S;
        case S  : return E;
        case E  : return N;
        case NW : return SW;
        case SW : return SE;
        case SE : return NE;
        case NE : return NW;
        default:
                 throw new UnimplementedError();
        }
      }
    }

    //# Returns the change in x implied by the given +direction+.
    int dx(direction){
      switch (direction){
      case E:
      case NE:
      case SE : return 1;
      case W:
      case NW:
      case SW : return -1;
      default: return 0;
      }
    }

    //# Returns the change in y implied by the given +direction+.
    int dy(direction){
      switch (direction){
      case S:
      case SE:
      case SW : return 1;
      case N:
      case NE:
      case NW : return -1;
      default: return 0;
      }
    }

    //# Returns the number of cells in the given row. This is generally safer
    //# than relying the //#width method, since it is theoretically possible for
    //# a maze to have a different number of cells for each of its rows.
    int row_length(row){
      return _cells[row].length;
    }

    //# Returns +true+ if the given cell is a dead-end. This considers only
    //# passages on the PRIMARY plane (the UNDER bits are ignored, because the
    //# current algorithm for generating mazes will never result in a dead-end
    //# that is underneath another passage).
    bool dead/*?*/(cell){
      var raw = cell & PRIMARY;
      return raw == N || raw == S || raw == E || raw == W ||
        raw == NE || raw == NW || raw == SE || raw == SW;
    }

    //# If +point+ is already located at a valid point within the maze, this
    //# does nothing. Otherwise, it examines the potential exits from the
    //# given point and looks for the first one that leads immediately to a
    //# valid point internal to the maze. When it finds one, it adds a passage
    //# to that cell leading to +point+. If no such adjacent cell exists, this
    //# method silently does nothing.
    add_opening_from(Position point){
      var x = point.x;
      var y = point.y;
      if (valid/*?*/(x, y)){
        //# nothing to be done
      }else{
        potential_exits_at(x, y).any((direction){
           var movePos = move(x, y, direction);
           var nx = movePos.x;
           var ny = movePos.y;
          if (valid/*?*/(nx, ny)){
            _cells[ny][nx] |= opposite(direction);
            return true;
          }
          return false;
        });
      }
    }

    //# If +point+ is already located at a valid point withint he maze, this
    //# simply returns +point+. Otherwise, it examines the potential exits
    //# from the given point and looks for the first one that leads immediately
    //# to a valid point internal to the maze. When it finds one, it returns
    //# that point. If no such point exists, it returns +nil+.
    Position adjacent_point(Position point){
       var x = point.x;
      var y = point.y;
      if (valid/*?*/(x, y)){
        return point;
      }else{
        potential_exits_at(x, y).any((direction){ //potential_exits_at(x, y).each do |direction|
          var movePos = move(x, y, direction);
              var nx = movePos.x;
          var ny = movePos.y; 
          if (valid(nx, ny)){
            point = new Position.xy(nx, ny); 
            return true;
          }
          return false;
        });
        return point;
      }
    }

    //# Returns the direction of +to+ relative to +from+. +to+ and +from+
    //# are both points (2-tuples).
    int relative_direction(from, to){
      //# first, look for the case where the maze wraps, and from and to
      //# are on opposite sites of the grid.
      if (wrap_x && from[1] == to[1] && (from[0] == 0 || to[0] == 0) && (from[0] == _width-1 || to[0] == _width-1)){
        if (from[0] < to[0]){
          return W;
        }else{
          return E;
        }
      }else if (wrap_y && from[0] == to[0] && (from[1] == 0 || to[1] == 0) && (from[1] == _height-1 || to[1] == _height-1)){
        if (from[1] < to[1]){
          return N;
        }else{
          return S;
        }
      }else if (from[0] < to[0]){
        if (from[1] < to[1]){
          return SE;
        }else if (from[1] > to[1]){
          return NE;
        }else{
          return E;
        }
      }else if (from[0] > to[0]) {
        if (from[1] < to[1]){
          return SW;
        }else if (from[1] > to[1]){
          return NW;
        }else{
          return W;
        }
      }else if (from[1] < to[1]){
        return S;
      }else if (from[1] > to[1]){
        return N;
      }else{
        //# same point!
        return null;//nil
      }
    }

    //# Applies a move in the given direction to the cell at (x,y). The +direction+
    //# parameter may also be :under, in which case the cell is left-shifted so as
    //# to move the existing passages to the UNDER plane.
    //#
    //# This method also handles the application of symmetrical moves, in the case
    //# where //#symmetry has been specified.
    //#
    //# You'll generally never call this method directly, except to construct grids
    //# yourself.
    apply_move_at(int x,int y, direction){
      if (direction == direction_under){
        _cells[y][x] <<= UNDER_SHIFT;
      }else{
        _cells[y][x] |= direction;
      }

      switch (_symmetry){
        case SymmetryType.x      : _move_symmetrically_in_x(x, y, direction);break;
        case SymmetryType.y      : _move_symmetrically_in_y(x, y, direction);break;
        case SymmetryType.xy     : _move_symmetrically_in_xy(x, y, direction);break;
        case SymmetryType.radial : _move_symmetrically_radially(x, y, direction);break;
      }
    }
    
    static final direction_under = null; /* :under */

    //# Returns the type of the maze as a string. OrthogonalMaze, for
    //# instance, is reported as "orthogonal".
//    type(){
//     // self.class.name[/::(.*?)Maze$/, 1];
//      throw new UnimplementedError("type");
//    }

    //# Returns the maze rendered to a particular format. Supported
    //# formats are currently :ascii and :png. The +options+ hash is passed
    //# through to the formatter.
    to(FormatType format, [options]/*={}*/);

    //# Returns the maze rendered to a string.
    String to_s(options){
      return to(FormatType.ascii, options).toString();
    }

    inspect(){ //# :nodoc:
//      "//#<//#{self.class.name}:0x%X %dx%d %s>" % [
//        object_id, _width, _height,
//        generated? ? "generated" : "not generated"]
      throw new UnimplementedError('inspect');
    }

    //# Returns +true+ if a weave may be applied at (thru_x,thru_y) when moving
    //# from (from_x,from_y) in +direction+. This will be true if the thru cell
    //# does not already have anything in its UNDER plane, and if the cell
    //# on the far side of thru is valid and blank.
    //#
    //# Subclasses may need to override this method if special interpretations
    //# for +direction+ need to be considered (see SigmaMaze).
    bool weave_allowed/*?*/(int from_x,int from_y,int thru_x,int thru_y,int direction){ //#:nodoc:
    var movePos = move(thru_x, thru_y, direction);      
      var nx2 = movePos.x;
      var ny2 = movePos.y; 
      return (_cells[thru_y][thru_x] & UNDER == 0) && valid(nx2, ny2) && _cells[ny2][nx2] == 0;
    }

    List perform_weave(int from_x,int from_y,int to_x,int to_y,int direction){ //#:nodoc:
      if ( ruby.rand(2) == 0) {//# move under existing passage
        apply_move_at(to_x, to_y, direction << UNDER_SHIFT);
        apply_move_at(to_x, to_y, opposite(direction) << UNDER_SHIFT);
      }else{ //# move over existing passage
        apply_move_at(to_x, to_y, direction_under);
        apply_move_at(to_x, to_y, direction);
        apply_move_at(to_x, to_y, opposite(direction));
      }
      
      var movePos = move(to_x, to_y, direction);
      var nx = movePos.x;
      var ny = movePos.y; 
      return [nx, ny, direction];
    }

    //# Not all maze types support symmetry. If a subclass supports any of the
    //# symmetry types (or wants to implement its own), it should override this
    //# method.
    _configure_symmetry(){ //#:nodoc:
      if (_symmetry != /*none*/null) {
        throw new UnimplementedError("only :none symmetry is implemented by default");
      }
    }

    //# The default grid should suffice for most maze types, but if a subclass
    //# wants a custom grid, it must override this method. Note that the method
    //# MUST always return an Array of rows, with each row being an Array of cells.
    List _setup_grid(){ //#:nodoc:
      return new List.generate(height,(_)=>new List.generate(width, (_)=>0));
    }

    //# Returns an array of deadends that ought to be braided (removed), based on
    //# the value of the //#braid setting.
    List _deadends_to_braid(){ //#:nodoc:
      if (_braid == 0/*.zero?*/){
        return [];
      }

      List<Position> ends = dead_ends();

      int count = (ends.length * _braid ~/ 100);
      if (count < 1){
        count = 1 ;
      }
      return ends.take(count).toList()..shuffle(ruby.getRandom());// ends.shuffle[0,count];
    }

    //# Calculate the default entrance, by looking for the upper-leftmost point.
    Position _default_entrance(){ //#:nodoc:
      Position result = new Position.xy(0, 0); //# if every cell is masked, then 0,0 is as good as any!
      ruby.each_with_index(_cells, (row, y){ //_cells.each_with_index do |row, y|
        return ruby.each_with_index(row,(cell, x){//row.each_with_index do |cell, x|
          if (_mask.getCell(x, y)) {
            result = new Position.xy(x-1, y);
            return true;
            }
          
    });
      });
      return result;//[0, 0]; //# if every cell is masked, then 0,0 is as good as any!
    }

    //# Calculate the default exit, by looking for the lower-rightmost point.
    Position _default_exit(){ //#:nodoc:
      Position result = new Position.xy(0, 0); //# if every cell is masked, then 0,0 is as good as any!
     ruby.each_with_index(_cells.reversed, (List row, y){//_cells.reverse.each_with_index do |row, y|
        var ry = _cells.length - y - 1;
            return ruby.each_with_index(row.reversed ,(cell, x){ //row.reverse.each_with_index do |cell, x|{
          var rx = row.length - x - 1;
              if (_mask.getCell(rx, ry)) {
                result= new Position.xy(rx+1, ry) ;
              return true;  
              }
        });
      });
      return result;//[0, 0]; //# if every cell is masked, then 0,0 is as good as any!
    }

    _move_symmetrically_in_x(int x,int y,int direction){ //#:nodoc:
      var row_width = _cells[y].length;
      if (direction == direction_under){
        _cells[y][row_width - x - 1].add(UNDER_SHIFT); //<<= UNDER_SHIFT
      }else{
        _cells[y][row_width - x - 1] |= hmirror(direction);
      }
    }

    _move_symmetrically_in_y(int x,int y,int direction){ //#:nodoc:
      if (direction == direction_under){
        _cells[_cells.length - y - 1][x].add(UNDER_SHIFT); //<<= UNDER_SHIFT
      }else{
        _cells[_cells.length - y - 1][x] |= vmirror(direction);
      }
    }

    _move_symmetrically_in_xy(int x,int y,int direction){ //#:nodoc:
      var row_width = _cells[y].length;
      if (direction == direction_under){
        _cells[y][row_width - x - 1] <<= UNDER_SHIFT;
        _cells[_cells.length - y - 1][x] <<= UNDER_SHIFT;
        _cells[_cells.length - y - 1][row_width - x - 1] <<= UNDER_SHIFT;
      }else{
        _cells[y][row_width - x - 1] |= hmirror(direction);
        _cells[_cells.length - y - 1][x] |= vmirror(direction);
        _cells[_cells.length - y - 1][row_width - x - 1] |= opposite(direction);
      }
    }

    _move_symmetrically_radially(int x,int y,int direction){ //#:nodoc:
      var row_width = _cells[y].length;
      if (direction == direction_under){
        _cells[_cells.length - x - 1][y] <<= UNDER_SHIFT;
        _cells[x][row_width - y - 1] <<= UNDER_SHIFT;
        _cells[_cells.length - y - 1][row_width - x - 1] <<= UNDER_SHIFT;
      }else{
        _cells[_cells.length - x - 1][y] |= counter_clockwise(direction);
        _cells[x][row_width - y - 1] |= clockwise(direction);
        _cells[_cells.length - y - 1][row_width - x - 1] |= opposite(direction);
      }
    }

    //# Finishes the generation of the maze by adding openings for the entrance
    //# and exit, and determing which dead-ends to braid (if any).
    _finish_not()/*!*/{ //#:nodoc:
      add_opening_from(_entrance);
      add_opening_from(_exit);

      _deadends = _deadends_to_braid();
      _generated = _deadends.isEmpty;// empty/*?*/;

      return !_generated;
    }

    //# If (x,y) is not a dead-end, this does nothing. Otherwise, it extends the
    //# dead-end in some direction until it joins with another passage.
    //#
    //# TODO: look for the direction that results in the longest loop.
    //# might be kind of spendy, but worth trying, at least.
    _braidMethod(int x,int y){ //#:nodoc:
      if (!dead/*?*/(_cells[y][x])){
       return;
      }
      //return unless dead?(_cells[y][x])
      List<int> tries = potential_exits_at(x, y);
      var arr = [opposite(_cells[y][x])];//[opposite(_cells[y][x]), tries]
      arr.addAll(tries);
      arr.any((try1){
        if (try1 == _cells[y][x]) 
        {
          return false;//next
         }; 
        var movePos = move(x, y, try1);
        var nx = movePos.x, ny = movePos.y; 
        if (valid(nx, ny)){
          var opp = opposite(try1);
              if (_cells[ny][nx] & (opp << UNDER_SHIFT) != 0) {
                return false;//next();
              }
          _cells[y][x] |= try1;
          _cells[ny][nx] |= opp;
          return true;// break loop
        }
        return false;
      });
    }

  }
