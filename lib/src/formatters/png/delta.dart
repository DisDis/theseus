part of theseus.formatters;
//require 'theseus/formatters/png'
//
//module Theseus
//  module Formatters
//    class PNG
      //# Renders a DeltaMaze to a PNG canvas. Does not currently support the
      //# +:wall_width+ option.
      //#
      //# You will almost never access this class directly. Instead, use
      //# DeltaMaze//#to(:png, options) to return the raw PNG data directly.
      class PNGDelta extends PNG {
          //# Create and return a fully initialized PNG::Delta object, with the
          //# maze rendered. To get the maze data, call //#to_blob.
          //#
          //# See Theseus::Formatters::PNG for a list of all supported options.
          PNGDelta(DeltaMaze maze, PNGFormatterOptions options)
              :super(maze, options) {
              var height = options.outer_padding * 2 +
                  maze.height * options.cell_size;
              var width = options.outer_padding * 2 +
                  (maze.width + 1) * options.cell_size / 2;

              canvas.setBackground(options.background);
              canvas.setSize(width, height);

              for (int y = 0; y < maze.height; y++) {
                  num py = options.outer_padding + y * options.cell_size;
                  for (int x = 0; x < maze.row_length(y); x++) {
                      num px = options.outer_padding +
                          x * options.cell_size / 2.0;
                      _draw_cell(canvas, new Position.xy(x, y), maze.points_up(x, y), px, py,
                          maze.getCell(x, y));
                  }
              }
          }


          void _draw_cell(PNGCanvas canvas,Position point,bool up,num x,num y,int cell) {
              //#:nodoc:
              if (cell == 0) {
                  return;
              }
              var p1 = new Position<num>.xy(x + options.cell_size / 2.0,
                  up ? (y + options.cell_padding) : (y + options.cell_size -
                      options.cell_padding));
              var p2 = new Position.xy(x + options.cell_padding,
                  up ? (y + options.cell_size - options.cell_padding) : (y +
                      options.cell_padding));
              var p3 = new Position.xy(
                  x + options.cell_size - options.cell_padding, p2.y);

              _fill_poly(canvas, [p1, p2, p3], color_at(point));

              if (cell & (Maze.N | Maze.S) != 0) {
                  var clr = color_at(point, (Maze.N | Maze.S));
                  var dy = options.cell_padding;
                  var sign = (cell & Maze.N != 0) ? -1 : 1;
                  //r1, r2 = p2, move(p3, 0, sign*dy);
                  var r1 = p2;
                  var r2 = move(p3, 0, sign * dy);
                  _fill_rect(canvas, r1.x.round(), r1.y.round(), r2.x.round(),
                      r2.y.round(), clr!);
                  _line(canvas, r1, new Position.xy(r1.x, r2.y),
                      options.wall_color);
                  _line(canvas, r2, new Position.xy(r2.x, r1.y),
                      options.wall_color);
              } else {
                  _line(canvas, p2, p3, options.wall_color);
              }

              var dx = options.cell_padding;
              if (cell & ANY_W != 0) {
                  //r1, r2, r3, r4 = p1, move(p1,-dx,0), move(p2,-dx,0), p2;
                  var r1 = p1;
                  var r2 = move(p1, -dx, 0);
                  var r3 = move(p2, -dx, 0);
                  var r4 = p2;
                  _fill_poly(canvas, [r1, r2, r3, r4], color_at(point, ANY_W)!.toInt());
                  _line(canvas, r1, r2, options.wall_color);
                  _line(canvas, r3, r4, options.wall_color);
              }

              if (cell & Maze.W == 0) {
                  _line(canvas, p1, p2, options.wall_color);
              }

              if (cell & ANY_E != 0) {
                  //r1, r2, r3, r4 = p1, move(p1,dx,0), move(p3,dx,0), p3;
                  var r1 = p1;
                  var r2 = move(p1, dx, 0);
                  var r3 = move(p3, dx, 0);
                  var r4 = p3;
                  _fill_poly(canvas, [r1, r2, r3, r4], color_at(point, ANY_E)!.toInt());
                  _line(canvas, r1, r2, options.wall_color);
                  _line(canvas, r3, r4, options.wall_color);
              }

              if (cell & Maze.E == 0) {
                  _line(canvas, p3, p1, options.wall_color);
              }
          }
      }
