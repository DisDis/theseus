import 'package:theseus/theseus.dart';
import 'package:theseus/src/formatters/formatters.dart' as formatters;
import 'package:image/image.dart';
import 'dart:io' as Io;
import 'dart:math' as math;
import 'package:theseus/src/solvers/solvers.dart' as solvers;

main(){
    var mazeOption = new MazeOptions(width: 20, height: 20);
    //srand(14);
    Maze orthogonalMaze = new OrthogonalMaze(mazeOption);
    print("generating the maze...");
    orthogonalMaze.generate();
    printMaze(orthogonalMaze);

    ImageCanvas icanvas = new ImageCanvas();
    formatters.PNGFormatterOptions pngSetting = new formatters.PNGFormatterOptions();
    pngSetting.canvas = icanvas;
    pngSetting.cell_padding = 0;
    pngSetting.wall_width = 1;
    pngSetting.wall_color = 0XFF000000;
    pngSetting.background = 0XFFFFFFFF;
    pngSetting.cell_size = 30;
//    solvers.Astar solve = new solvers.Astar(orthogonalMaze);
//    solve.solve();
//    var path = solve.to_path(new PathOptions()..color=pngSetting.solution_color);
//    pngSetting.paths = [path];
    orthogonalMaze.to(FormatType.png,pngSetting);
    Image image = icanvas.image;
    List<int> png = new PngEncoder().encodeImage(image);
    new Io.File('output/maze.png').writeAsBytesSync(png);
}

void printMaze(Maze maze) {
    formatters.ASCIIMode mode = formatters.ASCIIMode.unicode;
    print("mode: $mode");
    var out = maze.to(FormatType.ascii,mode) as formatters.ASCII;
    print(out.toString());
}

class ImageCanvas extends formatters.PNGCanvas{
    Image image;
    @override
    int width = 0;

    @override
    int height = 0;
    num background = 0;


    @override
    void fillRect(num x0, num y0, num x1, num y1, num color) {
                    for (int x = math.min(x0, x1).ceil(); x <= math.max(x0, x1).floor();x++) {
        // [x0, x1].min.ceil.upto([x0, x1].max.floor) do |x|{
                for (int y = math.min(y0, y1).ceil(); y <= math.max(y0, y1).floor(); y++) {
        //   [y0, y1].min.ceil.upto([y0, y1].max.floor) do |y|{
                    point(x, y, color);
                }
            }
    }

    @override
    void line(num x1, num y1, num x2, num y2, num color) {
        // Only direct line!
        if (x1 != x2 && y1 != y2){
            throw new UnimplementedError("Only direct line");
        }
        for(num x = x1; x< x2 ; x++){
            point(x,y1,color);
        }
        for(num y = y1; y< y2 ; y++){
            point(x1,y,color);
        }
    }

    @override
    void point(num x, num y, num color) {
        image.setPixel(x,y, color);
    }

    @override
    void setBackground(num value) {
        background = value;
        if (image!=null){
            image.fill(background);
        }
    }

    @override
    void setSize(num w, num h) {
        this.width = w;
        this.height = h;
        image = new Image(width, height);
        image.fill(background);
    }
}
