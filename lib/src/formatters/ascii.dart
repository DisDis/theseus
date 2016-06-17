part of theseus.formatters;
class Dimensions{
  final int width;
  final int height;
  Dimensions(this.width, this.height);
}

//module Theseus
//  module Formatters
    //# ASCII formatters render a maze as ASCII art. The ASCII representation
    //# is intended mostly to give you a "quick look" at the maze, and will
    //# rarely suffice for showing more than an overview of the maze's shape.
    //#
    //# This is the abstract superclass of the ASCII formatters, and provides
    //# helpers for writing to a textual "canvas".
    abstract class ASCII{
      //# The width of the canvas. This corresponds to, but is not necessarily the
      //# same as, the width of the maze.
      final int width;

      //# The height of the canvas. This corresponds to, but is not necessarily the
      //# same as, the height of the maze.
      final int height;

      List<List<String>> _chars;
      //# Create a new ASCII canvas with the given width and height. The canvas is
      //# initially blank (set to whitespace).
      ASCII(this.width,this.height){
        _chars = new List.generate(height,(_)=>new List.generate(width, (_)=>" ") );
      }

      //# Returns the character at the given coordinates.
      String getCell(int x,int y){
        return _chars[y][x];
      }

      //# Sets the character at the given coordinates.
      setCell (int x,int y,String char){
          _chars[y][x] = char;
      }

      //# Returns the canvas as a multiline string, suitable for displaying.
      toString(){
        return _chars.map((row)=>row.join()).join("\n");
      }
    }
