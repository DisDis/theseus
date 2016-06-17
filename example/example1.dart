import 'package:theseus/theseus.dart';
import 'package:theseus/src/formatters/formatters.dart' as formatters;
import 'package:theseus/ruby_port.dart';

main(){
    //srand(14);
    Maze maze = new OrthogonalMaze(new MazeOptions(width: 5, height: 5));
    print("generating the maze...");
    maze.generate();
    formatters.ASCIIOrthogonalMode.values.forEach((formatters.ASCIIOrthogonalMode mode){
        print("mode: $mode");
        var out = maze.to(FormatType.ascii,mode) as formatters.ASCII;
        print(out.toString());
    });
}