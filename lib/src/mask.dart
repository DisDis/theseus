part of theseus;


abstract class BaseMask{
  int get height;
  int get width;
  bool getCell(int x,int y);
}
//require 'chunky_png'
//
//module Theseus
  //# A "mask" is, conceptually, a grid of true/false values that corresponds,
  //# one-to-one, with the cells of a maze object. For every mask cell that is true,
  //# the corresponding cell in a maze may contain passages. For every mask cell that
  //# is false, the corresponding maze cell must be blank.
  //#
  //# Any object may be used as a mask as long as it responds to //#height, //#width, and
  //# //#[].
  class Mask extends BaseMask{
    List _grid;
    //# Given a string, treat each line as rows and each character as a cell. Every
    //# period character (".") will be mapped to +true+, and everything else to +false+.
    //# This lets you define simple masks as ASCII art:
    //#
    //#   mask_string = <<MASK
    //#   ..........
    //#   .X....XXX.
    //#   ..X....XX.
    //#   ...X....X.
    //#   ....X.....
    //#   .....X....
    //#   .X....X...
    //#   .XX....X..
    //#   .XXX....X.
    //#   ..........
    //#   MASK
    //#
    //#   mask = Theseus::Mask.from_text(mask_string)
    //#
    static Mask from_text(String text){
      //new(text.strip.split(/\n/).map { |line| line.split().map { |c| c == '.' } }) /* TODO: check line.split(//) */
      throw new UnimplementedError();
    }

    //# Given a PNG file with the given +file_name+, read the file and create a new
    //# mask where transparent pixels will be considered +true+, and all others +false+.
    //# Note that a pixel with any transparency at all will be considered +true+.
    //#
    //# The resulting mask will have the same dimensions as the image file.
    static Mask from_png(String file_name){
//      image = ChunkyPNG::Image.from_file(file_name)
//      _grid = new List.generator(image.height,(y){
//          return new List.generator( image.width,(x){return (image[x, y] & 0xff) == 0;}); 
//        });
//      return new Mask(grid);
      throw new UnimplementedError();
    }

    //# The number of rows in the mask.
    int get height=>_height;
    int _height;

    //# the length of the longest row in the mask.
    int get width=>_width;
    int _width;

    //# Instantiate a new mask from the given grid, which must be an Array of rows, and each
    //# row must be an Array of true/false values for each column in the row.
    Mask(List grid){
      _grid = grid;
      _height = _grid.length;
      _width = 0; //_grid.map((row)=> row.length).max
      _grid.map((row)=> row.length).forEach((item){
        if (_width<item){
          _width = item;
        }
      });
    }

    //# Returns the +true+/+false+ value for the corresponding cell in the grid.
    bool getCell(int x,int y){ //operator []
      return _grid[y][x];
    }
  }

  //# This is a specialized mask, intended for use with DeltaMaze instances (although
  //# it will work with any maze). This lets you easily create triangular delta mazes.
  //#
  //#   mask = Theseus::TriangleMask.new(10)
  //#   maze = Theseus::DeltaMaze.generate(mask: mask)
  class TriangleMask extends BaseMask{
    int get height=>_height;
    int _height;

    int get width=>_width;
    int _width;
    List _grid;

    //# Returns a new TriangleMask instance with the given height. The width will
    //# always be <code>2h+1</code> (where +h+ is the height).
    TriangleMask(height){
      _height = height;
      _width = _height * 2 + 1;
      _grid = new List.generate(_height,(y){
        var run = y * 2 + 1;
        var from = _height - y;
        var to = from + run - 1;
        return new List.generate(_width,(x){
          return (x >= from && x <= to) ? true : false;
        });
      });
    }

    //# Returns the +true+/+false+ value for the corresponding cell in the grid.
   bool getCell(x,y){//operator []
      return _grid[y][x];
    }
  }

  //# This is the default mask used by a maze when an explicit mask is not given.
  //# It simply reports every cell as available.
  //#
  //#   mask = Theseus::TransparentMask.new(20, 20)
  //#   maze = Theseus::OrthogonalMaze.new(mask: mask)
  class TransparentMask extends BaseMask{
    int get height=>_height;
        int _height;

        int get width=>_width;
        int _width;

    TransparentMask([width=0, height=0]){
      _width = width;
      _height = height;
    }

    //# Always returns +true+.
    bool getCell(x,y){
      return true;
    }
  }
