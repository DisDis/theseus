part of theseus.formatters;
//require 'theseus/formatters/ascii'
//
//module Theseus
//  module Formatters
//    class ASCII
//# Renders a SigmaMaze to an ASCII representation, using 3 characters
//# horizontally and 3 characters vertically to represent a single cell.
//#    _   _   _
//#   / \_/ \_/ \_
//#   \_/ \_/ \_/ \
//#   / \_/ \_/ \_/
//#   \_/ \_/ \_/ \
//#   / \_/ \_/ \_/
//#   \_/ \_/ \_/ \
//#   / \_/ \_/ \_/
//#   \_/ \_/ \_/ \
//#
//# You shouldn't ever need to instantiate this class directly. Rather, use
//# SigmaMaze//#to(:ascii) (or SigmaMaze//#to_s to get the string directly).
class ASCIISigma extends ASCII {
  //# Returns a new Sigma canvas for the given maze (which should be an
  //# instance of SigmaMaze). The +options+ parameter is not used.
  //#
  //# The returned object will be fully initialized, containing an ASCII
  //# representation of the given SigmaMaze.
  ASCIISigma(SigmaMaze maze) : super(maze.width * 2 + 2, maze.height * 2 + 2) {
    for (int y = 0; y < maze.height; y++) {
      var py = y * 2;
      for (int x = 0; x < maze.row_length(y); x++) {
        var cell = maze.getCell(x, y);
        if (cell == 0) {
          continue;
        }

        var px = x * 2;

        var shifted = x % 2 != 0;
        var ry = shifted ? py + 1 : py;

        var nw = shifted ? Maze.W : Maze.NW;
        var ne = shifted ? Maze.E : Maze.NE;
        var sw = shifted ? Maze.SW : Maze.W;
        var se = shifted ? Maze.SE : Maze.E;

        if (cell & Maze.N == 0) {
          setCell(px + 1, ry, "_");
        }
        if (cell & nw == 0) {
          setCell(px, ry + 1, "/");
        }
        if (cell & ne == 0) {
          setCell(px + 2, ry + 1, "\\");
        }
        if (cell & sw == 0) {
          setCell(px, ry + 2, "\\");
        }
        if (cell & Maze.S == 0) {
          setCell(px + 1, ry + 2, "_");
        }
        if (cell & se == 0) {
          setCell(px + 2, ry + 2, "/");
        }
      }
    }
  }
}
