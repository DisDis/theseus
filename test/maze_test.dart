//require 'minitest/autorun'
//require 'theseus'
@TestOn("vm")
library theseus.test;
import 'package:theseus/theseus.dart';
import 'package:theseus/ruby_port.dart';
import 'package:test/test.dart';

main(){
  test("maze_without_explicit_height_uses_width",(){
    Maze maze = new OrthogonalMaze(new MazeOptions(width: 10));
    expect(10,equals(maze.width));
    expect(maze.width,equals(maze.height));
  });

  test("maze_without_explicit_width_uses_height",(){
    Maze maze = new OrthogonalMaze(new MazeOptions(height: 10));
    expect(10,equals(maze.height));
    expect(maze.height,equals(maze.width));
  });

  test("maze_is_initially_blank",(){
    Maze maze = new OrthogonalMaze(new MazeOptions(width: 10));
    expect(true,equals(!maze.generated()));//    assert !maze.generated();

    var zeros = 0;
    for (int y = 0 ; y< maze.height ; y++){
      for (int x = 0 ; x< maze.width ; x++){
        if (maze.getCell(x, y) == 0){
          zeros += 1;
        }
      }
    }

    expect(100,equals(zeros));
  });

  test("maze_created_with_generate_is_identical_to_maze_created_with_step",(){
    srand(14);
    Maze maze1 = OrthogonalMaze.generateStatic(new MazeOptions(width: 10));
    expect(true,equals( maze1.generated()));

    srand(14);
    Maze maze2 = new OrthogonalMaze(new MazeOptions(width: 10));
    while(!maze2.generated()){
      maze2.step();
    }

    expect(maze1.width,equals(maze2.width));
    expect(maze1.height,equals(maze2.height));
    var differences = 0;

    for (int x = 0 ; x< maze1.width ; x++){
    for (int y = 0 ; y< maze1.height ; y++){
      var p = new Position.xy(x,y);
       if (! (maze1[p] == maze2[p])){
        differences += 1;
       }
      }
    }

    expect(0,equals(differences));
  });

  test("apply_move_at_should_combine_direction_with_existing_directions",(){
    Maze maze = /*Theseus::*/new OrthogonalMaze(new MazeOptions(width: 10));

    maze.setCell(5,5,/*Theseus::*/Maze.E);
    maze.apply_move_at(5, 5, /*Theseus::*/Maze.N);
    expect((/*Theseus::*/Maze.N | /*Theseus::*/Maze.E),equals(maze.getCell(5,5)));
  });

  test("apply_move_at_with_under_should_move_existing_directions_to_under_plane",(){
    Maze maze = /*Theseus::*/new OrthogonalMaze(new MazeOptions(width: 10));

    maze.setCell(5,5,/*Theseus::*/Maze.E);
    maze.apply_move_at(5, 5, Maze.direction_under);
    expect((/*Theseus::*/Maze.E << /*Theseus::*/Maze.UNDER_SHIFT),equals(maze.getCell(5,5)));
  });

  test("apply_move_at_with_x_symmetry_should_populate_x_mirror",(){
    Maze maze = /*Theseus::*/new OrthogonalMaze(new MazeOptions(width: 10, symmetry: SymmetryType.x));

    maze.apply_move_at(1, 2, /*Theseus::*/Maze.E);
    expect(/*Theseus::*/Maze.W,equals(maze.getCell(8, 2)));

    maze.apply_move_at(2, 1, /*Theseus::*/Maze.NE);
    expect(/*Theseus::*/Maze.NW,equals(maze.getCell(7, 1)));

    maze.apply_move_at(2, 3, /*Theseus::*/Maze.N);
    expect(/*Theseus::*/Maze.N,equals(maze.getCell(7, 3)));
  });

  test("apply_move_at_with_y_symmetry_should_populate_y_mirror",(){
    Maze maze = /*Theseus::*/new OrthogonalMaze(new MazeOptions(width: 10, symmetry: SymmetryType.y));

    maze.apply_move_at(1, 2, /*Theseus::*/Maze.S);
    expect(/*Theseus::*/Maze.N,equals(maze.getCell(1, 7)));

    maze.apply_move_at(2, 1, /*Theseus::*/Maze.SW);
    expect(/*Theseus::*/Maze.NW,equals(maze.getCell(2, 8)));

    maze.apply_move_at(2, 3, /*Theseus::*/Maze.W);
    expect(/*Theseus::*/Maze.W,equals(maze.getCell(2, 6)));
  });

  test("apply_move_at_with_xy_symmetry_should_populate_xy_mirror",(){
    Maze maze = /*Theseus::*/new OrthogonalMaze(new MazeOptions(width: 10, symmetry: SymmetryType.xy));

    maze.apply_move_at(1, 2, /*Theseus::*/Maze.S);
    expect(/*Theseus::*/Maze.N,equals(maze.getCell(1, 7)));
    expect(/*Theseus::*/Maze.S,equals(maze.getCell(8, 2)));
    expect(/*Theseus::*/Maze.N,equals(maze.getCell(8, 7)));

    maze.apply_move_at(2, 1, /*Theseus::*/Maze.SW);
    expect(/*Theseus::*/Maze.NW,equals(maze.getCell(2, 8)));
    expect(/*Theseus::*/Maze.SE,equals(maze.getCell(7, 1)));
    expect(/*Theseus::*/Maze.NE,equals(maze.getCell(7, 8)));

    maze.apply_move_at(2, 3, /*Theseus::*/Maze.W);
    expect(/*Theseus::*/Maze.W,equals(maze.getCell(2, 6)));
    expect(/*Theseus::*/Maze.E,equals(maze.getCell(7, 3)));
    expect(/*Theseus::*/Maze.E,equals(maze.getCell(7, 6)));
  });

  test("apply_move_at_with_radial_symmetry_should_populate_radial_mirror",(){
    Maze maze = /*Theseus::*/new OrthogonalMaze(new MazeOptions(width: 10, symmetry: SymmetryType.radial));

    maze.apply_move_at(1, 2, /*Theseus::*/Maze.S);
    expect(/*Theseus::*/Maze.E,equals(maze.getCell(2, 8)));
    expect(/*Theseus::*/Maze.W,equals(maze.getCell(7, 1)));
    expect(/*Theseus::*/Maze.N,equals(maze.getCell(8, 7)));

    maze.apply_move_at(2, 1, /*Theseus::*/Maze.SW);
    expect(/*Theseus::*/Maze.SE,equals(maze.getCell(1, 7)));
    expect(/*Theseus::*/Maze.NW,equals(maze.getCell(8, 2)));
    expect(/*Theseus::*/Maze.NE,equals(maze.getCell(7, 8)));

    maze.apply_move_at(2, 3, /*Theseus::*/Maze.W);
    expect(/*Theseus::*/Maze.S,equals(maze.getCell(3, 7)));
    expect(/*Theseus::*/Maze.N,equals(maze.getCell(6, 2)));
    expect(/*Theseus::*/Maze.E,equals(maze.getCell(7, 6)));
  });

  test("dx_east_should_increase",(){
    Maze maze = /*Theseus::*/new OrthogonalMaze(new MazeOptions(width: 10));
    expect(1,equals(maze.dx(/*Theseus::*/Maze.E)));
    expect(1,equals(maze.dx(/*Theseus::*/Maze.NE)));
    expect(1,equals(maze.dx(/*Theseus::*/Maze.SE)));
  });

  test("dx_west_should_decrease",(){
    Maze maze = /*Theseus::*/new OrthogonalMaze(new MazeOptions(width: 10));
    expect(-1,equals(maze.dx(/*Theseus::*/Maze.W)));
    expect(-1,equals(maze.dx(/*Theseus::*/Maze.NW)));
    expect(-1,equals(maze.dx(/*Theseus::*/Maze.SW)));
  });

  test("dy_south_should_increase",(){
    Maze maze = /*Theseus::*/new OrthogonalMaze(new MazeOptions(width: 10));
    expect(1,equals(maze.dy(/*Theseus::*/Maze.S)));
    expect(1,equals(maze.dy(/*Theseus::*/Maze.SE)));
    expect(1,equals(maze.dy(/*Theseus::*/Maze.SW)));
  });

  test("dy_north_should_decrease",(){
    Maze maze = /*Theseus::*/new OrthogonalMaze(new MazeOptions(width: 10));
    expect(-1,equals(maze.dy(/*Theseus::*/Maze.N)));
    expect(-1,equals(maze.dy(/*Theseus::*/Maze.NE)));
    expect(-1,equals(maze.dy(/*Theseus::*/Maze.NW)));
  });

  test("opposite_should_report_inverse_direction",(){
    Maze maze = /*Theseus::*/new OrthogonalMaze(new MazeOptions(width: 10));
    expect(/*Theseus::*/Maze.N,equals(maze.opposite(/*Theseus::*/Maze.S)));
    expect(/*Theseus::*/Maze.NE,equals(maze.opposite(/*Theseus::*/Maze.SW)));
    expect(/*Theseus::*/Maze.E,equals(maze.opposite(/*Theseus::*/Maze.W)));
    expect(/*Theseus::*/Maze.SE,equals(maze.opposite(/*Theseus::*/Maze.NW)));
    expect(/*Theseus::*/Maze.S,equals(maze.opposite(/*Theseus::*/Maze.N)));
    expect(/*Theseus::*/Maze.SW,equals(maze.opposite(/*Theseus::*/Maze.NE)));
    expect(/*Theseus::*/Maze.W,equals(maze.opposite(/*Theseus::*/Maze.E)));
    expect(/*Theseus::*/Maze.NW,equals(maze.opposite(/*Theseus::*/Maze.SE)));
  });

  test("step_should_populate_current_cell_and_next_cell",(){
    OrthogonalMaze maze = /*Theseus::*/new OrthogonalMaze(new MazeOptions(width: 10));

    var cx = maze.x;
    var cy = maze.y;
    expect(true,equals(cx >= 0 && cx < maze.width));
    expect(true,equals(cy >= 0 && cy < maze.height));
    expect(0,equals(maze.getCell(cx, cy)));

    expect(true,equals(maze.step()));

    var direction = maze.getCell(cx, cy);
    expect(0,isNot(equals(direction)));

    var movePos = maze.move(cx, cy, direction);
    var nx = movePos.x, ny = movePos.y;
    expect([nx, ny],isNot(equals([cx, cy])));
    expect([nx,ny], equals([maze.x, maze.y]));

    expect(maze.opposite(direction),equals(maze.getCell(nx, ny)));
  });
}