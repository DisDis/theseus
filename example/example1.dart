import 'package:theseus/theseus.dart';
import 'package:theseus/src/formatters/formatters.dart' as formatters;
import 'package:theseus/ruby_port.dart';

main(){
    var mazeOption = new MazeOptions(width: 20, height: 20);
    //srand(14);
    Maze orthogonalMaze = new OrthogonalMaze(mazeOption);
    print("generating the maze...");
    orthogonalMaze.generate();
    printMaze(orthogonalMaze);

    Maze deltaMaze = new DeltaMaze(mazeOption);
    print("generating the maze...");
    deltaMaze.generate();
    printMaze(deltaMaze);

    Maze sigmaMaze = new SigmaMaze(mazeOption);
    print("generating the maze...");
    sigmaMaze.generate();
    printMaze(sigmaMaze);

    Maze upsilonMaze = new UpsilonMaze(mazeOption);
    print("generating the maze...");
    upsilonMaze.generate();
    printMaze(upsilonMaze);
}

void printMaze(Maze maze) {
//  formatters.ASCIIMode.values.forEach((formatters.ASCIIMode mode){
    formatters.ASCIIMode mode = formatters.ASCIIMode.unicode;
      print("mode: $mode");
      var out = maze.to(FormatType.ascii,mode) as formatters.ASCII;
      print(out.toString());
//  });
}