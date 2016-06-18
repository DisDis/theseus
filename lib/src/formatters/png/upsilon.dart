part of theseus.formatters;
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
      class PNGUpsilon extends PNG{
        //# Create and return a fully initialized PNG::Upsilon object, with the
        //# maze rendered. To get the maze data, call //#to_blob.
        //#
        //# See Theseus::Formatters::PNG for a list of all supported options.
        PNGUpsilon(UpsilonMaze maze,PNGFormatterOptions options):super(maze, options){

          var width = options.outer_padding * 2 + (3 * maze.width + 1) * options.cell_size / 4;
          var height = options.outer_padding * 2 + (3 * maze.height + 1) * options.cell_size / 4;

          canvas.setBackground(options.background);
          canvas.setSize(width, height);

          metrics = { size: options.cell_size - options.cell_padding * 2 };
          metrics[:s4] = metrics[:size] / 4.0;
          metrics[:inc] = 3 * options.cell_size / 4.0;

          for(int y = 0; y < maze.height; y++){
            py = options.outer_padding + y * metrics[:inc];
            for (int x = 0 ; x < maze.row_length(y); x++){
              cell = maze.getCell(x, y);
              if (cell == 0)  {continue;} //next

        px = options.outer_padding + x * metrics[:inc];

              if ((y + x) % 2 == 0){
              _draw_octogon_cell(canvas, [x, y], px, py, cell, metrics);
              }else {
                _draw_square_cell(canvas, [x, y], px, py, cell, metrics);
              }
            }
          }

          _blob = canvas.to_blob();
        }

        _draw_octogon_cell(PNGCanvas canvas, point, x, y, cell, metrics){ //#:nodoc:
          p1 = [x + options.cell_padding + metrics[:s4], y + options.cell_padding;
          p2 = [x + options.cell_size - options.cell_padding - metrics[:s4], p1[1]];
          p3 = [x + options.cell_size - options.cell_padding, y + options.cell_padding + metrics[:s4]];
          p4 = [p3[0], y + options.cell_size - options.cell_padding - metrics[:s4]];
          p5 = [p2[0], y + options.cell_size - options.cell_padding;
          p6 = [p1[0], p5[1]];
          p7 = [x + options.cell_padding, p4[1]];
          p8 = [p7[0], p3[1]];

          _fill_poly(canvas, [p1, p2, p3, p4, p5, p6, p7, p8], color_at(point));

          any = proc { |x| x | (x << Maze.UNDER_SHIFT) };

          if (cell & any[Maze.NE] != 0){
            far_p6 = move(p6, metrics[:inc], -metrics[:inc]);
            far_p7 = move(p7, metrics[:inc], -metrics[:inc]);
            _fill_poly(canvas, [p2, far_p7, far_p6, p3], color_at(point, any[Maze.NE]));
            _line(canvas, p2, far_p7, options.wall_color);
            _line(canvas, p3, far_p6, options.wall_color);
          }

          if (cell & any[Maze.E] != 0){
            edge = (x + options.cell_size + options.cell_padding > canvas.width);
            r1, r2 = p3, edge ? move(p4, options.cell_padding, 0) : move(p7, options.cell_size, 0);
            _fill_rect(canvas, r1[0], r1[1], r2[0], r2[1], color_at(point, any[Maze.E]));
            _line(canvas, r1, [r2[0], r1[1]], options.wall_color);
            _line(canvas, r2, [r1[0], r2[1]], options.wall_color);
          }

          if (cell & any[Maze.SE] != 0){
            far_p1 = move(p1, metrics[:inc], metrics[:inc]);
            far_p8 = move(p8, metrics[:inc], metrics[:inc]);
            _fill_poly(canvas, [p4, far_p1, far_p8, p5], color_at(point, any[Maze.SE]));
            _line(canvas, p4, far_p1, options.wall_color);
            _line(canvas, p5, far_p8, options.wall_color);
          }

          if (cell & any[Maze.S] != 0){
            r1, r2 = p6, move(p2, 0, options.cell_size);
            _fill_rect(canvas, r1[0], r1[1], r2[0], r2[1], color_at(point, any[Maze.S]));
            _line(canvas, r1, [r1[0], r2[1]], options.wall_color);
            _line(canvas, r2, [r2[0], r1[1]], options.wall_color);
          }

        if (cell & Maze.N == 0) {_line(canvas, p1, p2, options.wall_color);}
           if (cell & Maze.NE == 0) {_line(canvas, p2, p3, options.wall_color);}
        if (cell & Maze.E == 0)_line(canvas, p3, p4, options.wall_color);}
if (cell & Maze.SE == 0){ _line(canvas, p4, p5, options.wall_color) ;}
if (cell & Maze.S == 0){  _line(canvas, p5, p6, options.wall_color) ;}
if (cell & Maze.SW == 0){     _line(canvas, p6, p7, options.wall_color) ;}
if (cell & Maze.W == 0){   _line(canvas, p7, p8, options.wall_color) ;}
if (cell & Maze.NW == 0){  _line(canvas, p8, p1, options.wall_color) ;}


        _draw_square_cell(PNGCanvas canvas, point, x, y, cell, metrics) {//#:nodoc:
          v = options.cell_padding + metrics[:s4]
          p1 = [x + v, y + v];
          p2 = [x + options.cell_size - v, y + options.cell_size - v];

          _fill_rect(canvas, p1[0], p1[1], p2[0], p2[1], color_at(point));

          any = proc { |x| x | (x << Maze.UNDER_SHIFT) };

          if (cell & any[Maze.E] != 0){
            r1 = [p2[0], p1[1]];
            r2 = [x + metrics[:inc] + v, p2[1]];
            _fill_rect(canvas, r1[0], r1[1], r2[0], r2[1], color_at(point, any[Maze.E]));
            _line(canvas, r1, [r2[0], r1[1]], options.wall_color);
            _line(canvas, [r1[0], r2[1]], r2, options.wall_color);
          }

          if (cell & any[Maze.S] != 0){
            r1 = [p1[0], p2[1]];
            r2 = [p2[0], y + metrics[:inc] + v];
            _fill_rect(canvas, r1[0], r1[1], r2[0], r2[1], color_at(point, any[Maze.S]));
            _line(canvas, r1, [r1[0], r2[1]], options.wall_color);
            _line(canvas, [r2[0], r1[1]], r2, options.wall_color);
          }

if (cell & Maze.N == 0){_line(canvas, p1, [p2[0], p1[1]], options.wall_color)};
if (cell & Maze.E == 0){      _line(canvas, [p2[0], p1[1]], p2, options.wall_color) ;}
if (cell & Maze.S == 0){       _line(canvas, [p1[0], p2[1]], p2, options.wall_color);}
if (cell & Maze.W == 0){     _line(canvas, p1, [p1[0], p2[1]], options.wall_color);}
        }
      }
