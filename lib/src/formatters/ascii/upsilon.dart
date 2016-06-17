part of theseus.formatters;
//require 'theseus/formatters/ascii'
//
//module Theseus
//  module Formatters
//    class ASCII
//# Renders an UpsilonMaze to an ASCII representation, using 3 characters
//# horizontally and 4 characters vertically to represent a single octagonal
//# cell, and 3 characters horizontally and 2 vertically to represent a square
//# cell.
//#    _   _   _
//#   / \_/ \_/ \
//#   | |_| |_| |
//#   \_/ \_/ \_/
//#   |_| |_| |_|
//#   / \_/ \_/ \
//#
//# You shouldn't ever need to instantiate this class directly. Rather, use
//# UpsilonMaze//#to(:ascii) (or UpsilonMaze//#to_s to get the string directly).
class ASCIIUpsilon extends ASCII {
  //# Returns a new Sigma canvas for the given maze (which should be an
  //# instance of SigmaMaze). The +options+ parameter is not used.
  //#
  //# The returned object will be fully initialized, containing an ASCII
  //# representation of the given SigmaMaze.
  ASCIIUpsilon(UpsilonMaze maze, _) : super(maze.width * 2 + 1, maze.height * 2 + 3) {
    for (int y = 0; y < maze.height; y++) {
      var py = y * 2;
      for (int x = 0; x < maze.row_length(y); x++) {
        var cell = maze.getCell(x, y);
        if (cell == 0) {
          continue;
        }

        var px = x * 2;

        if ((x + y) % 2 == 0) {
          _draw_octogon_cell(px, py, cell);
        } else {
          _draw_square_cell(px, py, cell);
        }
      }
    }
  }


  _draw_octogon_cell(px, py, cell) { //#:nodoc:
    if (cell & Maze.N == 0) {
      setCell(px + 1, py, "_");
    }
    if (cell & Maze.NW == 0) {
      setCell(px, py + 1, "/");
    }
    if (cell & Maze.NE == 0) {
      setCell(px + 2, py + 1, "\\");
    }
    if (cell & Maze.W == 0) {
      setCell(px, py + 2, "|");
    }
    if (cell & Maze.E == 0) {
      setCell(px + 2, py + 2, "|");
    }
    if (cell & Maze.SW == 0) {
      setCell(px, py + 3, "\\");
    }
    if (cell & Maze.S == 0) {
      setCell(px + 1, py + 3, "_");
    }
    if (cell & Maze.SE == 0) {
      setCell(px + 2, py + 3, "/");
    }
  }

  _draw_square_cell(px, py, cell) { //#:nodoc:
    if (cell & Maze.N == 0) {
      setCell(px + 1, py + 1, "_");
    }
    if (cell & Maze.W == 0) {
      setCell(px, py + 2, "|");
    }
    if (cell & Maze.S == 0) {
      setCell(px + 1, py + 2, "_");
    }
    if (cell & Maze.E == 0) {
      setCell(px + 2, py + 2, "|");
    }
  }
}
