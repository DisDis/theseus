part of theseus.formatters;
//require 'theseus/formatters/png'
//
//module Theseus
//  module Formatters
//    class PNG
      //# Renders a SigmaMaze to a PNG canvas. Does not currently support the
      //# +:wall_width+ option.
      //#
      //# You will almost never access this class directly. Instead, use
      //# SigmaMaze//#to(:png, options) to return the raw PNG data directly.
      class PNGSigma extends PNG{
        //# Create and return a fully initialized PNG::Sigma object, with the
        //# maze rendered. To get the maze data, call //#to_blob.
        //#
        //# See Theseus::Formatters::PNG for a list of all supported options.
        PNGSigma(SigmaMaze maze,PNGFormatterOptions options):super(maze, options){

          var  width = options.outer_padding * 2 + (3 * maze.width + 1) * options.cell_size / 4;
          var height = options.outer_padding * 2 + maze.height * options.cell_size + options.cell_size / 2;

          canvas.setBackground(options.background);
          canvas.setSize(width, height);

          for(int y = 0 ; y< maze.height.times;y++){
            py = options.outer_padding + y * options.cell_size;
            for(int x= 0 ; x< maze.row_length(y);x++){
              px = options.outer_padding + x * 3 * options.cell_size / 4.0;
              shifted = (x % 2 != 0);
              dy = shifted ? (options.cell_size / 2.0) : 0;
              _draw_cell(canvas, [x, y], shifted, px, py+dy, maze.getCell(x, y));
            }
          }

        }

        //private

        _draw_cell(PNGCanvas canvas, point, shifted, x, y, cell){
          if (cell == 0){
return;
}

          size = options.cell_size - options.cell_padding * 2;
          s4 = size / 4.0;

          fs4 = options.cell_size / 4.0 //# fs == full-size, without padding

          p1 = [x + options.cell_padding + s4, y + options.cell_padding];
          p2 = [x + options.cell_size - options.cell_padding - s4, p1[1]];
          p3 = [x + options.cell_padding + size, y + options.cell_size / 2.0];
          p4 = [p2[0], y + options.cell_size - options.cell_padding];
          p5 = [p1[0], p4[1]];
          p6 = [x + options.cell_padding, p3[1]];

          fill_poly(canvas, [p1, p2, p3, p4, p5, p6], color_at(point));

          n  = Maze.N;
          s  = Maze.S;
          nw = shifted ? Maze.W : Maze.NW;
          ne = shifted ? Maze.E : Maze.NE;
          sw = shifted ? Maze.SW : Maze.W;
          se = shifted ? Maze.SE : Maze.E;

          any = proc { |x| x | (x << Maze.UNDER_SHIFT) };

          if (cell & any[s] != 0){
            r1, r2 = p5, move(p4, 0, options.cell_padding*2);
            _fill_rect(canvas, r1[0], r1[1], r2[0], r2[1], color_at(point, any[s]));
            _line(canvas, p5, move(p5, 0, options.cell_padding*2), options.wall_color);
            _line(canvas, p4, move(p4, 0, options.cell_padding*2), options.wall_color);
          }

          if (cell & any[ne] != 0){
            ne_x = x + 3 * options.cell_size / 4.0;
            ne_y = y - options.cell_size * 0.5;
            ne_p5 = [ne_x + options.cell_padding + s4, ne_y + options.cell_size - options.cell_padding];
            ne_p6 = [ne_x + options.cell_padding, ne_y + options.cell_size * 0.5];
            r1, r2, r3, r4 = p2, p3, ne_p5, ne_p6;
            _fill_poly(canvas, [r1, r2, r3, r4], color_at(point, any[ne]));
            _line(canvas, r1, r4, options.wall_color);
            _line(canvas, r2, r3, options.wall_color);
          }

          if (cell & any[se] != 0){
            se_x = x + 3 * options.cell_size / 4.0;
            se_y = y + options.cell_size * 0.5;
            se_p1 = [se_x + s4 + options.cell_padding, se_y + options.cell_padding];
            se_p6 = [se_x + options.cell_padding, se_y + options.cell_size * 0.5];
            r1, r2, r3, r4 = p3, p4, se_p6, se_p1;
            _fill_poly(canvas, [r1, r2, r3, r4], color_at(point, any[se]));
            _line(canvas, r1, r4, options.wall_color);
            _line(canvas, r2, r3, options.wall_color);
          }

if (cell & n == 0){_line(canvas, p1, p2, options.wall_color);}
if (cell & ne == 0){   _line(canvas, p2, p3, options.wall_color);}
if (cell & se == 0){     _line(canvas, p3, p4, options.wall_color);}
if (cell & s == 0){   _line(canvas, p4, p5, options.wall_color);}
if (cell & sw == 0){       _line(canvas, p5, p6, options.wall_color);}
if (cell & nw == 0){        _line(canvas, p6, p1, options.wall_color);}
        }
      }
