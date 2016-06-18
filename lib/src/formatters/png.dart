part of theseus.formatters;

abstract class PNGCanvas{
    int get width;
    int get height;

  void line(num x1, num y1, num x2, num y2,num color);

  void fillRect(num x0, num y0, num x1, num y1,num color);

  void point(num x, num y,num color);

  void setBackground(num background);

  void setSize(num width, num height);

  dynamic to_blob();
}


class PNGFormatterOptions{
  //# The +options+ must be a hash of any of the following options:
  //#
  //# [:cell_size]      The number of pixels on a side that each cell
  //#                   should occupy. Different maze types will use that
  //#                   space differently. Also, the cell padding is applied
  //#                   inside the cell, and so consumes some of the area.
  //#                   The default is 10.
  //# [:wall_width]     How thick the walls should be drawn. The default is 1.
  //#                   Note that not all PNG formatters will honor this value
  //#                   (yet).
  //# [:wall_color]     The color to use when drawing the wall. Defaults to black.
  //# [:cell_color]     The color to use when drawing the cell. Defaults to white.
  //# [:solution_color] The color to use when drawing the solution path. This is
  //#                   only used when the :solution option is given.
  //# [:background]     The color to use for the background of the maze. Defaults
  //#                   to transparent.
  //# [:outer_padding]  The extra padding (in pixels) to add around the outside
  //#                   edge of the maze. Defaults to 2.
  //# [:cell_padding]   The padding (in pixels) to add around the inside of each
  //#                   cell. This has the effect of separating the cells. The
  //#                   default cell padding is 1.
  //# [:solution]       A boolean value indicating whether or not to draw the
  //#                   solution path as well. The default is false.

  //# The default options. Note that not all PNG formatters honor all of these options;
  //# specifically, +:wall_width+ is not consistently supported across all formatters.
    int cell_size      = 10;
    int wall_width     = 1;
    int wall_color     = 0x000000FF;
    int cell_color     = 0xFFFFFFFF;
    int solution_color = 0xFFAFAFFF;
    int background     = 0x00000000;
    int outer_padding  = 2;
    int cell_padding   = 1;
    solvers.Base solution      = null;

    PNGCanvas canvas;
  List paths = [];
}
//require 'chunky_png'
//
//module Theseus
//  module Formatters
    //# This is an abstract superclass for PNG formatters. It simply provides some common
    //# utility and drawing methods that subclasses can take advantage of, to render
    //# mazes to a PNG canvas.
    //#
    //# Colors are given as 32-bit integers, with each RGBA component occupying 1 byte.
    //# R is the highest byte, A is the lowest byte. In other words, 0xFF0000FF is an
    //# opaque red, and 0x7f7f7f7f is a semi-transparent gray. 0x0 is fully transparent.
    //#
    //# You may also provide the colors as hexadecimal string values, and they will be
    //# converted to the corresponding integers.
    class PNG {


        //# North, whether in the under or primary plane
        final int ANY_N = Maze.N | (Maze.N << Maze.UNDER_SHIFT);

        //# South, whether in the under or primary plane
        final int ANY_S = Maze.S | (Maze.S << Maze.UNDER_SHIFT);

        //# West, whether in the under or primary plane
        final int ANY_W = Maze.W | (Maze.W << Maze.UNDER_SHIFT);

        //# East, whether in the under or primary plane
        final int ANY_E = Maze.E | (Maze.E << Maze.UNDER_SHIFT);

        //# The options to use for the formatter. These are the ones passed
        //# to the constructor, plus the ones from the DEFAULTS hash.
        PNGFormatterOptions get options => _options;
        PNGFormatterOptions _options;

        var _blob;
        List _paths;
        PNGCanvas canvas;


        PNG(Maze maze, PNGFormatterOptions options) {
            canvas = options.canvas;
//        _options = DEFAULTS.merge(options);

//        [#background, #wall_color, #cell_color, #solution_color].forEach((c){
//          if (String == _options[c]){
//             _options[c] = ChunkyPNG.Color.from_hex(_options[c]);
//          }
//        });

            _paths = _options.paths;

            if (_options.solution != null) {
                //TODO: Implement!
                throw new UnimplementedError("options.solution");
//          Path path = maze.new_solver(type: _options.solution.solve().to_path(color: _options.solution_color);
//          _paths = [path, *_paths];
            }
        }

        //# Returns the raw PNG data for the formatter.
        to_blob() {
            return _blob;
        }

        //# Returns the color at the given point by considering all provided paths. The
        //# +:color: metadata from the first path that is set at the given point is
        //# returned. If no path describes the given point, then the value of the
        //# +:cell_color+ option is returned.
        color_at(pt, [direction = null]) {
            _paths.forEach((path) {
                if (direction != null ? path.path(pt, direction) : path
                    .set /*set?*/(pt)) {
                    return path.color;
                }
            });

            return _options.cell_color;
        }

        //# Returns a new 2-tuple (x2,y2), where x2 is point[0] + dx, and y2 is point.y + dy.
        Position move(Position point, dx, dy) {
            return new Position.xy(point.x + dx, point.y + dy);
        }

        //# Clamps the value +x+ so that it lies between +low+ and +hi+. In other words,
        //# returns +low+ if +x+ is less than +low+, and +high+ if +x+ is greater than
        //# +high+, and returns +x+ otherwise.
        int clamp(int x, int low, int hi) {
            if (x < low) {
                x = low;
            }
            if (x > hi) {
                x = hi;
            }
            return x;
        }

        //# Draws a line from +p1+ to +p2+ on the given canvas object, in the given
        //# color. The coordinates of the given points are clamped (naively) to lie
        //# within the canvas' bounds.
        _line(PNGCanvas canvas,Position p1,Position p2, color) {
            canvas.line(
                clamp(p1.x.round(), 0, canvas.width - 1),
                clamp(p1.y.round(), 0, canvas.height - 1),
                clamp(p2.x.round(), 0, canvas.width - 1),
                clamp(p2.y.round(), 0, canvas.height - 1),
                color);
        }

        //# Fills the rectangle defined by the given coordinates with the given color.
        //# The coordinates are clamped to lie within the canvas' bounds.
        _fill_rect(PNGCanvas canvas, x0, y0, x1, y1, color) {
            x0 = clamp(x0, 0, canvas.width - 1);
            y0 = clamp(y0, 0, canvas.height - 1);
            x1 = clamp(x1, 0, canvas.width - 1);
            y1 = clamp(y1, 0, canvas.height - 1);
//            for (int x = math.min(x0, x1).ceil(); x < math.max(x0, x1).floor();x++) {
                // [x0, x1].min.ceil.upto([x0, x1].max.floor) do |x|{
//                for (int y = math.min(y0, y1).ceil(); y < math.max(y0, y1).floor(); y++) {
                    //   [y0, y1].min.ceil.upto([y0, y1].max.floor) do |y|{
                   // canvas.point(x, y, color);
//                }
//            }
            canvas.fillRect(x0,y0,x1,y1,color);
        }

        //# Fills the polygon defined by the +points+ array, with the given +color+.
        //# Each element of +points+ must be a 2-tuple describing a vertex of the
        //# polygon. It is assumed that the polygon is closed. All points are
        //# clamped (naively) to lie within the canvas' bounds.
        _fill_poly(PNGCanvas canvas, List<Position> points, color) {
            var min_y = 1000000;
            var max_y = -1000000;
            points.forEach((Position xy) {
                if (xy.y < min_y) {
                    min_y = xy.y;
                }
                if (xy.y > max_y) {
                    max_y = xy.y;
                }
            });

            min_y = clamp(min_y, 0, canvas.height - 1);
            max_y = clamp(max_y, 0, canvas.height - 1);

            for (int y = min_y.floor(); y < max_y.ceil(); y++) {
                //min_y.floor.upto(max_y.ceil) do |y|{

                List nodes = [];

                Position prev = points.last;
                points.forEach((Position point) {
                    if (point.y < y && prev.y >= y ||
                        prev.y < y && point.y >= y) {
                        nodes.add((point.x +
                            (y - point.y) /*.to_f*/ / (prev.y - point.y) *
                                (prev.x - point.x))); // <<
                    }
                    prev = point;
                });

                if (nodes.isEmpty) {
                    continue; //next
                }
                nodes.sort(); //sort!

                prev = null;
                for (int a = 0; a < nodes.length - 1; a += 2) {
                    //0.step(nodes.length-1, 2) do |a|{
                    var x1 = nodes[a];
                    var x2 = nodes[a + 1];
                    if (x1 > x2) {
                        var tmp = x1;
                        x1 = x2;
                        x2 = tmp;
                    }
                    if (x1 < 0 || x2 >= canvas.width) {
                        continue; // next
                    }
                    for (int x = x1.ceil(); x < x2.floor(); x++) {
                        //x1.ceil.upto(x2.floor) do |x|{
                        canvas.point(x, y, color);
                    }
                }
            }
        }
    }
