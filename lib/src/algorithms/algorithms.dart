library theseus.algorithms;

import "../../theseus.dart";
import '../../ruby_port.dart' as ruby;

part 'recursive_backtracker.dart';
part 'base.dart';

Base resolveAlgorithms(Type algorithmType,Maze maze,MazeOptions options){
  switch (algorithmType){
    case RecursiveBacktracker:
      return new RecursiveBacktracker(maze,options);
    default:
      throw new UnimplementedError("Unknown $algorithmType");
  }
}