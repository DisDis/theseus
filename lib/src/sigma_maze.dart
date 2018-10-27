part of theseus;
//require 'theseus/maze'
//
//module Theseus
  //# A "sigma" maze is one in which the field is tesselated into hexagons.
  //# Trying to map such a field onto a two-dimensional grid is a little tricky;
  //# Theseus does so by treating a single row as the hexagon in the first
  //# column, then the hexagon below and to the right, then the next hexagon
  //# above and to the right (on a line with the first hexagon), and so forth.
  //# For example, the following grid consists of two rows of 8 cells each:
  //#
  //#    _   _   _   _
  //#   / \_/ \_/ \_/ \_
  //#   \_/ \_/ \_/ \_/ \ 
  //#   / \_/ \_/ \_/ \_/ 
  //#   \_/ \_/ \_/ \_/ \ 
  //#     \_/ \_/ \_/ \_/ 
  //#
  //# SigmaMaze supports weaving, but not symmetry (yet).
  //#
  //#   maze = Theseus::SigmaMaze.generate(width: 10)
  //#   puts maze
  class SigmaMaze extends Maze{
  SigmaMaze(MazeOptions options) : super(options);


    //# Because of how the cells are positioned relative to other cells in
    //# the same row, the definition of the diagonal walls changes depending
    //# on whether a cell is "shifted" (e.g. moved down a half-row) or not.
    //#
    //#    ____        ____
    //#   / N  \      /
    //#  /NW  NE\____/
    //#  \W    E/ N  \
    //#   \_S__/W    E\____
    //#        \SW  SE/
    //#         \_S__/
    //#
    //# Thus, if a cell is shifted, W/E are in the upper diagonals, otherwise
    //# they are in the lower diagonals. It is important that W/E always point
    //# to cells in the same row, so that the //#dx and //#dy methods do not need
    //# to be overridden.
    //#
    //# This change actually makes it fairly easy to generalize the other
    //# operations, although weaving needs special attention (see //#weave_allowed?
    //# and //#perform_weave).
    potential_exits_at(x, y){ //#:nodoc:
      var result = [Maze.N, Maze.S, Maze.E, Maze.W]; 
      result.addAll(((x % 2 == 0) ? [Maze.NW, Maze.NE] : [Maze.SW, Maze.SE]));
      return result;
    }

    //private

    //# This maps which axis the directions share, depending on whether a cell
    //# is shifted (+true+) or not (+false+). For example, in a non-shifted cell,
    //# E is on a line with NW, so AXIS_MAP[false][E] returns NW (and vice versa).
    //# This is used in the weaving algorithms to determine which direction an
    //# UNDER passage moves as it passes under a cell.
    static final Map<bool,Map<int,int>> AXIS_MAP = {
      false : <int,int>{
        Maze.N : Maze.S,
        Maze.S : Maze.N,
            Maze.E : Maze.NW,
            Maze.NW : Maze.E,
            Maze.W : Maze.NE,
            Maze.NE : Maze.W
      },

      true :  <int,int>{
        Maze.N : Maze.S,
        Maze.S : Maze.N,
        Maze.W : Maze.SE,
        Maze.SE : Maze.W,
        Maze.E : Maze.SW,
        Maze.SW : Maze.E
      }
    };

    //# given a path entering in +entrance_direction+, returns the side of the
    //# cell that it would exit if it passed in a straight line through the cell.
    int _exit_wound(int entrance_direction,bool shifted){ //#:nodoc:
      //# if moving W into the cell, then entrance_direction == W. To determine
      //# the axis within the new cell, we reverse it to find the wall within the
      //# cell that was penetrated (opposite(W) == E), and then
      //# look it up in the AXIS_MAP (E<->NW or E<->SW, depending on the cell position)
      var entrance_wall = opposite(entrance_direction);
      return AXIS_MAP[shifted][entrance_wall];
    }

    @override
    bool weave_allowed(from_x, from_y, thru_x, thru_y, direction){ //#:nodoc:
      //# disallow a weave if there is already a weave at this cell
      if (_cells[thru_y][thru_x] & Maze.UNDER != 0){
      return false ;
      }

      var pass_thru = _exit_wound(direction, thru_x % 2 != 0);
      var movePos = move(thru_x, thru_y, pass_thru);
      var out_x = movePos.x.toInt();
      var out_y = movePos.y.toInt();
      return valid(out_x, out_y) && _cells[out_y][out_x] == 0;
    }

    @override
    perform_weave(int from_x,int from_y,int to_x,int to_y,int direction){ //#:nodoc:
      bool shifted = to_x % 2 != 0;
      var pass_thru = _exit_wound(direction, shifted);

      apply_move_at(to_x, to_y, pass_thru << Maze.UNDER_SHIFT);
      apply_move_at(to_x, to_y, AXIS_MAP[shifted][pass_thru] << Maze.UNDER_SHIFT);

      var movePos = move(to_x, to_y, pass_thru);
      var nx = movePos.x.toInt();
      var ny = movePos.y.toInt();
      return [nx, ny, pass_thru];
    }
    
    @override
    V to<V, P>(FormatType format, [P options]) {
        if (format == FormatType.ascii) {
             return new formatters.ASCIISigma(this) as V;
           } 
      else if (format == FormatType.png) {
          return new formatters.PNGSigma(this, options as formatters.PNGFormatterOptions) as V;
             //Formatters::PNG.const_get(type).new(self, options).to_blob
      }
           else
           {
             throw new ArgumentError("unknown format: $format");
           }
      }
  }
