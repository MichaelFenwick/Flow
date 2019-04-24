import 'package:stagexl/stagexl.dart';
import 'package:voronoi/voronoi.dart';
import 'cell.dart';


class VoronoiNet extends Shape implements Animatable {
  List<Cell> cells = [];

  VoronoiNet(List<Cell> this.cells) : super();

  @override
  bool advanceTime(num time) {
    Voronoi voronoi = new Voronoi(cells.map((Cell cell) => new Point(cell.location.x, cell.location.y)).toList(), null, new Rectangle(0, 0, stage.width, stage.height));

    List<LineSegment> edges = voronoi.voronoiDiagram();

    graphics.clear();

    //TODO: These lines need to end at the edge of the circle. They can be mapped to not exceed the bounds, or, perhaps more performant, can just be masked by a border.
    for (LineSegment edge in edges) {
      graphics
        ..strokeColor(Color.DarkSlateBlue)
        ..beginPath()
        ..moveTo(edge.p0.x, edge.p0.y)
        ..lineTo(edge.p1.x, edge.p1.y)
        ..closePath();
    }

    return true;
  }
}