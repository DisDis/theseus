part of theseus.formatters;
////# encoding: UTF-8
//
//require 'theseus/formatters/ascii'
enum ASCIIMode{
  /**
   * Uses standard 7-bit ASCII characters. Width is 2x+1, height is
   * y+1. This mode cannot render weave mazes without significant
   * ambiguity.
   */
  plain,
  /**
   * Uses unicode characters to render cleaner lines. Width is
   * 3x, height is 2y. This mode has sufficient detail to correctly
   * render mazes with weave!
   */
  unicode,
  /**
   * Draws passages as lines, using unicode characters. Width is
   * x, height is y. This mode can render weave mazes, but with some
   * ambiguity.
   */
  lines
}


//module Theseus
//  module Formatters
    //class ASCII
      //# Renders an OrthogonalMaze to an ASCII representation.
      //#
      //# The ASCII formatter for the OrthogonalMaze actually supports three different
      //# output types:
      //#
      //# [:plain]    Uses standard 7-bit ASCII characters. Width is 2x+1, height is
      //#             y+1. This mode cannot render weave mazes without significant
      //#             ambiguity.
      //# [:unicode]  Uses unicode characters to render cleaner lines. Width is
      //#             3x, height is 2y. This mode has sufficient detail to correctly
      //#             render mazes with weave!
      //# [:lines]    Draws passages as lines, using unicode characters. Width is
      //#             x, height is y. This mode can render weave mazes, but with some
      //#             ambiguity.
      //#
      //# The :plain mode is the default, but you can specify a different one using
      //# the :mode option.
      //#
      //# You shouldn't ever need to instantiate this class directly. Rather, use
      //# OrthogonalMaze//#to(:ascii) (or OrthogonalMaze//#to_s to get the string directly).
      class ASCIIOrthogonal extends ASCII{
        //# Returns the dimensions of the given maze, rendered in the given mode.
        //# The +mode+ must be +:plain+, +:unicode+, or +:lines+.
        static Dimensions dimensions_for(Maze maze,[ASCIIMode mode]){
          if (mode == null){
            mode = ASCIIMode.plain;
          }
          switch (mode){
            case ASCIIMode.plain:
            return new Dimensions(maze.width * 2 + 1, maze.height + 1);
            case ASCIIMode.unicode:
              return new Dimensions(maze.width * 3, maze.height * 2);
            case ASCIIMode.lines:
              return new Dimensions(maze.width, maze.height);
            default:
            throw new Exception("unknown mode $mode");
          }
        }

        //# Create and return a fully initialized ASCII canvas. The +options+
        //# parameter may specify a +:mode+ parameter, as described in the documentation
        //# for this class.
        ASCIIOrthogonal(OrthogonalMaze maze, [ASCIIMode mode = ASCIIMode.plain]):super(dimensions_for(maze, mode).width,dimensions_for(maze, mode).height){
          if (mode == null){
                      mode = ASCIIMode.plain;
                    }

//          width, height = dimensions_for(maze, mode);
//          super(width, height)

          for (int y =0 ; y < maze.height; y++){
            var length = maze.row_length(y);
            for (int x =0 ; x < length; x++){
              switch (mode){
                case  ASCIIMode.plain : _draw_plain_cell(maze, x, y);break;
                case  ASCIIMode.unicode : _draw_unicode_cell(maze, x, y);break;
                case  ASCIIMode.lines : _draw_line_cell(maze, x, y);break;
              }
            }
          }
        }

        _draw_plain_cell(Maze maze,int x,int y){ //#:nodoc:
          var c = maze.getCell(x, y);
          if (c == 0){
            return ;
          };
          var px = x * 2;
          var py = y;

          var cnw = maze.valid(x-1,y-1) ? maze.getCell(x-1,y-1) : 0;
          var cn  = maze.valid(x,y-1) ? maze.getCell(x,y-1) : 0;
          var cne = maze.valid(x+1,y-1) ? maze.getCell(x+1,y-1) : 0;
          var cse = maze.valid(x+1,y+1) ? maze.getCell(x+1,y+1) : 0;
          var cs  = maze.valid(x,y+1) ? maze.getCell(x,y+1) : 0;
          var csw = maze.valid(x-1,y+1) ? maze.getCell(x-1,y+1) : 0;

          if (c & Maze.N == 0){
            if (y == 0 || (cn == 0 && cnw == 0) || cnw & (Maze.E | Maze.S) == Maze.E){
            setCell(px, py,"_"); 
            }
            setCell(px+1, py,"_");
            if (y == 0 || (cn == 0 && cne == 0) || cne & (Maze.W | Maze.S) == Maze.W){
            setCell(px+2, py,"_");
            }
          }

          if (c & Maze.S == 0){
            var bottom = y+1 == maze.height;
            if (bottom || (cs == 0 && csw == 0) || csw & (Maze.E | Maze.N) == Maze.E){
              setCell(px, py+1,"_");
            }
            setCell(px+1, py+1,"_");
            if (bottom || (cs == 0 && cse == 0) || cse & (Maze.W | Maze.N) == Maze.W){
            setCell(px+2, py+1,"_");
            }
          }

          if (c & Maze.W == 0){
          setCell(px, py+1,"|" );
          }
          if (c & Maze.E == 0){
          setCell(px+2, py+1,"|" );
          }
        }

        final List UTF8_SPRITES = [
          ["   ", "   "], //# " "
          ["│ │", "└─┘"], //# "╵"
          ["┌─┐", "│ │"], //# "╷"
          ["│ │", "│ │"], //# "│",
          ["┌──", "└──"], //# "╶" 
          ["│ └", "└──"], //# "└" 
          ["┌──", "│ ┌"], //# "┌"
          ["│ └", "│ ┌"], //# "├" 
          ["──┐", "──┘"], //# "╴"
          ["┘ │", "──┘"], //# "┘"
          ["──┐", "┐ │"], //# "┐"
          ["┘ │", "┐ │"], //# "┤"
          ["───", "───"], //# "─"
          ["┘ └", "───"], //# "┴"
          ["───", "┐ ┌"], //# "┬"
          ["┘ └", "┐ ┌"]  //# "┼"
        ];

        _draw_unicode_cell(Maze maze,int x,int y){ //#:nodoc:
          var cx = 3 * x, cy = 2 * y;
          var cell = maze.getCell(x, y);

          ruby.each_with_index(UTF8_SPRITES[cell & Maze.PRIMARY], (row, sy){
            for(int sx = 0 ; sx < row.length ; sx++){
              var char = row[sx];
              setCell(cx+sx, cy+sy,char);
            }
          });

          var under = cell >> Maze.UNDER_SHIFT;

          if (under & Maze.N != 0){
            setCell(cx,   cy,"┴");
            setCell(cx+2, cy,"┴");
          }

          if (under & Maze.S != 0){
            setCell(cx,   cy+1,"┬");
            setCell(cx+2, cy+1,"┬");
          }

          if (under & Maze.W != 0){
            setCell(cx, cy,"┤");
            setCell(cx, cy+1,"┤");
          }

          if (under & Maze.E != 0){
            setCell(cx+2, cy,"├");
            setCell(cx+2, cy+1,"├");
          }
        }

        final UTF8_LINES = [" ", "╵", "╷", "│", "╶", "└", "┌", "├", "╴", "┘", "┐", "┤", "─", "┴", "┬", "┼"];

        _draw_line_cell(maze, x, y){ //#:nodoc:
          setCell(x, y,UTF8_LINES[maze.getCell(x, y) & Maze.PRIMARY]);
        }
      }
