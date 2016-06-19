part of theseus.formatters;

//require 'theseus/formatters/png'
//
//module Theseus
//  module Formatters
//    class PNG


      //# Renders an OrthogonalMaze to a PNG canvas.
      //#
      //# You will almost never access this class directly. Instead, use
      //# OrthogonalMaze//#to(:png, options) to return the raw PNG data directly.
      class PNGOrthogonal extends PNG {
        int d1;
        int d2;
        int w1;
        int w2;
        int width;
        int height;

        //# Create and return a fully initialized PNG::Orthogonal object, with the
        //# maze rendered. To get the maze data, call //#to_blob.
        //#
        //# See Theseus::Formatters::PNG for a list of all supported options.
        PNGOrthogonal(OrthogonalMaze maze, PNGFormatterOptions options)
            :super(maze, options) {
          width = options.outer_padding * 2 + maze.width * options.cell_size;
          height = options.outer_padding * 2 + maze.height * options.cell_size;

          canvas.setBackground(options.background);
          canvas.setSize(width, height);

          d1 = options.cell_padding;
          d2 = options.cell_size;
          -options.cell_padding;
          w1 = (options.wall_width / 2.0).floor();
          w2 = ((options.wall_width - 1) / 2.0).floor();

          for (int y = 0; y < maze.height; y++) {
            //maze.height.times do |y|
            var py = options.outer_padding + y * options.cell_size;
            for (int x = 0; x < maze.width; x++) {
              //maze.width.times do |x|
              var px = options.outer_padding + x * options.cell_size;
              _draw_cell(
                  canvas, new Position.xy(x, y), px, py, maze.getCell(x, y));
            }
          }
        }

        _draw_cell(PNGCanvas canvas, Position point, num x, num y, cell) {
          //#:nodoc:
          if (cell == 0) {
            return;
          }

          _fill_rect(canvas, x + d1, y + d1, x + d2, y + d2, color_at(point));

          bool north = cell & Maze.N == Maze.N;
          bool north_under = (cell >> Maze.UNDER_SHIFT) & Maze.N == Maze.N;
          bool south = cell & Maze.S == Maze.S;
          bool south_under = (cell >> Maze.UNDER_SHIFT) & Maze.S == Maze.S;
          bool west = cell & Maze.W == Maze.W;
          bool west_under = (cell >> Maze.UNDER_SHIFT) & Maze.W == Maze.W;
          bool east = cell & Maze.E == Maze.E;
          bool east_under = (cell >> Maze.UNDER_SHIFT) & Maze.E == Maze.E;

          _draw_vertical(
              canvas,
              x,
              y,
              1,
              north || north_under,
              !north || north_under,
              color_at(point, ANY_N));
          _draw_vertical(
              canvas,
              x,
              y + options.cell_size,
              -1,
              south || south_under,
              !south || south_under,
              color_at(point, ANY_S));
          _draw_horizontal(
              canvas,
              x,
              y,
              1,
              west || west_under,
              !west || west_under,
              color_at(point, ANY_W));
          _draw_horizontal(
              canvas,
              x + options.cell_size,
              y,
              -1,
              east || east_under,
              !east || east_under,
              color_at(point, ANY_E));
        }

        _draw_vertical(PNGCanvas canvas, num x, num y, direction, bool corridor,
            bool wall, color) {
          //#:nodoc:
          if (corridor) {
            _fill_rect(canvas, x + d1, y, x + d2, y + d1 * direction, color);
            _fill_rect(canvas, x + d1 - w1, y - (w1 * direction), x + d1 + w2,
                y + (d1 + w2) * direction, options.wall_color);
            _fill_rect(canvas, x + d2 - w2, y - (w1 * direction), x + d2 + w1,
                y + (d1 + w2) * direction, options.wall_color);
          }

          if (wall) {
            _fill_rect(
                canvas, x + d1 - w1, y + (d1 - w1) * direction, x + d2 + w2,
                y + (d1 + w2) * direction, options.wall_color);
          }
        }

        _draw_horizontal(PNGCanvas canvas, num x, num y, num direction,
            bool corridor, bool wall, color) {
          //#:nodoc:
          if (corridor) {
            _fill_rect(canvas, x, y + d1, x + d1 * direction, y + d2, color);
            _fill_rect(canvas, x - (w1 * direction), y + d1 - w1,
                x + (d1 + w2) * direction, y + d1 + w2, options.wall_color);
            _fill_rect(canvas, x - (w1 * direction), y + d2 - w2,
                x + (d1 + w2) * direction, y + d2 + w1, options.wall_color);
          }

          if (wall) {
            _fill_rect(canvas, x + (d1 - w1) * direction, y + d1 - w1,
                x + (d1 + w2) * direction, y + d2 + w2, options.wall_color);
          }
        }
      }
