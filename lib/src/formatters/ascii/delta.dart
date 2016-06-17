part of theseus.formatters;
//require 'theseus/formatters/ascii'
//
//module Theseus
//  module Formatters
//    class ASCII
//# Renders a DeltaMaze to an ASCII representation, using 4 characters
//# horizontally and 2 characters vertically to represent a single cell.
//#
//#          __
//#        /\  /
//#       /__\/
//#      /\  /\
//#     /__\/__\
//#    /\  /\  /\
//#   /__\/__\/__\
//#
//# You shouldn't ever need to instantiate this class directly. Rather, use
//# DeltaMaze//#to(:ascii) (or DeltaMaze//#to_s to get the string directly).
class ASCIIDelta extends ASCII {
  //# Returns a new Delta canvas for the given maze (which should be an
  //# instance of DeltaMaze). The +options+ parameter is not used.
  //#
  //# The returned object will be fully initialized, containing an ASCII
  //# representation of the given DeltaMaze.
  ASCIIDelta(DeltaMaze maze, _)
      : super((maze.width + 1) * 2, maze.height * 2 + 1) {
    for (int y = 0; y < maze.height; y++) {
      var py = y * 2;
      for (int x = 0; x < maze.row_length(y); x++) {
        var cell = maze.getCell(x, y);
        if (cell == 0) {
          continue;
        }

        var px = x * 2;

        if (maze.points_up(x, y)) {
          if (cell & Maze.W == 0) {
            setCell(px + 1, py + 1, "/");
            setCell(px, py + 2, "/");
          } else if (y < 1) {
            setCell(px + 1, py, "_");
          }

          if (cell & Maze.E == 0) {
            setCell(px + 2, py + 1, "\\");
            setCell(px + 3, py + 2, "\\");
          } else if (y < 1) {
            setCell(px + 2, py, "_");
          }

          if (cell & Maze.S == 0) {
            setCell(px + 1, py + 2, "_");
            setCell(px + 2, py + 2, "_");
          }
        } else {
          if (cell & Maze.W == 0) {
            setCell(px, py + 1, "\\");
            setCell(px + 1, py + 2, "\\");
          } else if (x > 0 && maze.getCell(x - 1, y) & Maze.S == 0) {
            setCell(px + 1, py + 2, "_");
          }

          if (cell & Maze.E == 0) {
            setCell(px + 3, py + 1, "/");
            setCell(px + 2, py + 2, "/");
          } else if (x < maze.row_length(y) &&
              maze.getCell(x + 1, y) & Maze.S == 0) {
            setCell(px + 2, py + 2, "_");
          }

          if (cell & Maze.N == 0) {
            setCell(px + 1, py, "_");
            setCell(px + 2, py, "_");
          }
        }
      }
    }
  }
}
