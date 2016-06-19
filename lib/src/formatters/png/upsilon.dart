part of theseus.formatters;

class Metrics{
  final num size;
  num s4;
  num inc;
  Metrics({this.size});
}
//require 'theseus/formatters/png'
//
//module Theseus
//  module Formatters
//    class PNG
      //# Renders a UpsilonMaze to a PNG canvas. Does not currently support the
      //# +:wall_width+ option.
      //#
      //# You will almost never access this class directly. Instead, use
      //# UpsilonMaze//#to(:png, options) to return the raw PNG data directly.
      class PNGUpsilon extends PNG {
        //# Create and return a fully initialized PNG::Upsilon object, with the
        //# maze rendered. To get the maze data, call //#to_blob.
        //#
        //# See Theseus::Formatters::PNG for a list of all supported options.
        PNGUpsilon(UpsilonMaze maze, PNGFormatterOptions options)
            :super(maze, options) {
          var width = options.outer_padding * 2 +
              (3 * maze.width + 1) * options.cell_size / 4;
          var height = options.outer_padding * 2 +
              (3 * maze.height + 1) * options.cell_size / 4;

          canvas.setBackground(options.background);
          canvas.setSize(width, height);

          Metrics metrics = new Metrics(
              size: options.cell_size - options.cell_padding * 2);
          metrics.s4 = metrics.size / 4.0;
          metrics.inc = 3 * options.cell_size / 4.0;

          for (int y = 0; y < maze.height; y++) {
            var py = options.outer_padding + y * metrics.inc;
            for (int x = 0; x < maze.row_length(y); x++) {
              var cell = maze.getCell(x, y);
              if (cell == 0) {
                continue;
              }
              //next

              var px = options.outer_padding + x * metrics.inc;

              if ((y + x) % 2 == 0) {
                _draw_octogon_cell(
                    canvas, new Position.xy(x, y), px, py, cell, metrics);
              } else {
                _draw_square_cell(
                    canvas, new Position.xy(x, y), px, py, cell, metrics);
              }
            }
          }
        }

//        any = proc { |x| x | (x << Maze.UNDER_SHIFT) };
        int any(int x) => x | (x << Maze.UNDER_SHIFT);

        _draw_octogon_cell(PNGCanvas canvas, Position point, num x, num y,
            int cell, Metrics metrics) {
          //#:nodoc:
          var p1 = new Position.xy(
              x + options.cell_padding + metrics.s4, y + options.cell_padding);
          var p2 = new Position.xy(
              x + options.cell_size - options.cell_padding - metrics.s4, p1.y);
          var p3 = new Position.xy(x + options.cell_size - options.cell_padding,
              y + options.cell_padding + metrics.s4);
          var p4 = new Position.xy(
              p3.x, y + options.cell_size - options.cell_padding - metrics.s4);
          var p5 = new Position.xy(
              p2.x, y + options.cell_size - options.cell_padding);
          var p6 = new Position.xy(p1.x, p5.y);
          var p7 = new Position.xy(x + options.cell_padding, p4.y);
          var p8 = new Position.xy(p7.x, p3.y);

          _fill_poly(canvas, [p1, p2, p3, p4, p5, p6, p7, p8], color_at(point));


          if (cell & any(Maze.NE) != 0) {
            var far_p6 = move(p6, metrics.inc, -metrics.inc);
            var far_p7 = move(p7, metrics.inc, -metrics.inc);
            _fill_poly(canvas, [p2, far_p7, far_p6, p3],
                color_at(point, any(Maze.NE)));
            _line(canvas, p2, far_p7, options.wall_color);
            _line(canvas, p3, far_p6, options.wall_color);
          }

          if (cell & any(Maze.E) != 0) {
            var edge = (x + options.cell_size + options.cell_padding >
                canvas.width);
            var r1 = p3;
            var r2 = edge ? move(p4, options.cell_padding, 0) : move(
                p7, options.cell_size, 0);
            _fill_rect(
                canvas, r1.x, r1.y, r2.x, r2.y, color_at(point, any(Maze.E)));
            _line(canvas, r1, new Position.xy(r2.x, r1.y), options.wall_color);
            _line(canvas, r2, new Position.xy(r1.x, r2.y), options.wall_color);
          }

          if (cell & any(Maze.SE) != 0) {
            var far_p1 = move(p1, metrics.inc, metrics.inc);
            var far_p8 = move(p8, metrics.inc, metrics.inc);
            _fill_poly(canvas, [p4, far_p1, far_p8, p5],
                color_at(point, any(Maze.SE)));
            _line(canvas, p4, far_p1, options.wall_color);
            _line(canvas, p5, far_p8, options.wall_color);
          }

          if (cell & any(Maze.S) != 0) {
            var r1 = p6;
            var r2 = move(p2, 0, options.cell_size);
            _fill_rect(
                canvas, r1.x, r1.y, r2.x, r2.y, color_at(point, any(Maze.S)));
            _line(canvas, r1, new Position.xy(r1.x, r2.y), options.wall_color);
            _line(canvas, r2, new Position.xy(r2.x, r1.y), options.wall_color);
          }

          if (cell & Maze.N == 0) {
            _line(canvas, p1, p2, options.wall_color);
          }
          if (cell & Maze.NE == 0) {
            _line(canvas, p2, p3, options.wall_color);
          }
          if (cell & Maze.E == 0) {
            _line(canvas, p3, p4, options.wall_color);
          }
          if (cell & Maze.SE == 0) {
            _line(canvas, p4, p5, options.wall_color);
          }
          if (cell & Maze.S == 0) {
            _line(canvas, p5, p6, options.wall_color);
          }
          if (cell & Maze.SW == 0) {
            _line(canvas, p6, p7, options.wall_color);
          }
          if (cell & Maze.W == 0) {
            _line(canvas, p7, p8, options.wall_color);
          }
          if (cell & Maze.NW == 0) {
            _line(canvas, p8, p1, options.wall_color);
          }
        }

        _draw_square_cell(PNGCanvas canvas, Position point, num x, num y,
            int cell, Metrics metrics) {
          //#:nodoc:
          var v = options.cell_padding + metrics.s4;
          var p1 = new Position.xy(x + v, y + v);
          var p2 = new Position.xy(
              x + options.cell_size - v, y + options.cell_size - v);

          _fill_rect(canvas, p1.x, p1.y, p2.x, p2.y, color_at(point));

//          any = proc { |x| x | (x << Maze.UNDER_SHIFT) };

          if (cell & any(Maze.E) != 0) {
            var r1 = new Position.xy(p2.x, p1.y);
            var r2 = new Position.xy(x + metrics.inc + v, p2.y);
            _fill_rect(
                canvas, r1.x, r1.y, r2.x, r2.y, color_at(point, any(Maze.E)));
            _line(canvas, r1, new Position.xy(r2.x, r1.y), options.wall_color);
            _line(canvas, new Position.xy(r1.x, r2.y), r2, options.wall_color);
          }

          if (cell & any(Maze.S) != 0) {
            var r1 = new Position.xy(p1.x, p2.y);
            var r2 = new Position.xy(p2.x, y + metrics.inc + v);
            _fill_rect(
                canvas, r1.x, r1.y, r2.x, r2.y, color_at(point, any(Maze.S)));
            _line(canvas, r1, new Position.xy(r1.x, r2.y), options.wall_color);
            _line(canvas, new Position.xy(r2.x, r1.y), r2, options.wall_color);
          }

          if (cell & Maze.N == 0) {
            _line(canvas, p1, new Position.xy(p2.x, p1.y), options.wall_color);
          };
          if (cell & Maze.E == 0) {
            _line(canvas, new Position.xy(p2.x, p1.y), p2, options.wall_color);
          }
          if (cell & Maze.S == 0) {
            _line(canvas, new Position.xy(p1.x, p2.y), p2, options.wall_color);
          }
          if (cell & Maze.W == 0) {
            _line(canvas, p1, new Position.xy(p1.x, p2.y), options.wall_color);
          }
        }
      }
