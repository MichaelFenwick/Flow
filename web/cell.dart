import 'dart:math' as Math;
import 'package:color/color.dart';
import 'package:stagexl/stagexl.dart' hide Color;

class Cell extends Sprite implements Animatable {
  Point location;
  num size;
  Point potential = Point(0, 0);
  Point stageCenter = Point(0, 0);
  num stageRadius = 0;
  num get charge => size * size * size / 100; //TODO: Find a proper function for size:charge that gives the ideal output.
  Color color = RgbColor.name("white");

  Cell(Point this.location, num this.size) : super();

  void addToStage(Point stageCenter, num stageRadius) {
    this.stageCenter = stageCenter;
    this.stageRadius = stageRadius;
  }

  void calculatePotential(List<Cell> cells) {
    potential = Point(0, 0);
    cells.forEach((Cell cell) {
      if (cell != this) {
        double distance = location.distanceTo(cell.location);
        potential += (location - cell.location) * (cell.charge / Math.pow(distance, 3));
      }
    });

    //
    num edgeCharge = charge * 2;
    Point<num> edgeLocation = getNearestEdge();
    double distance = location.distanceTo(edgeLocation);
    potential += (location - edgeLocation) * (edgeCharge / Math.pow(distance, 3));
  }

  @override
  bool advanceTime(num time) {
    double movementScale = 30; //TODO: Find a better place to put this and make it scale with expected range of charge values
    Point newLocation = location + potential * (charge * movementScale);

    // Set a hard bound to prevent things from getting off the field.
    if (newLocation.distanceTo(stageCenter) < stageRadius - size) {
      location = newLocation;
    } else {
      // If the cell would move off the field, we need to move it to the edge instead (basically do as much of the requested movement as possible in the direction attempted, stopping when it hits the "wall." To do this we get the nearest edge (in absolute window coords), transform into stage coords, rescale to be the stage radius minus the cell size, and then transform back into window coords.
      location = stageCenter + ((getNearestEdge() - stageCenter) * (1 - (size) / stageRadius));
    }

//    graphics
//      ..clear()
//      ..circle(location.x, location.y, size)
//      ..fillColor(stagexlColor);

    return true;
  }

  Point<num> getNearestEdge() {
    Point centerToCell = location - stageCenter;
    return stageCenter + centerToCell * (stageRadius / centerToCell.magnitude);
  }

  String toString() {
    return "Size: ${size.toStringAsFixed(2)}, X: ${location.x.toStringAsFixed(1)}, Y: ${location.y.toStringAsFixed(1)}";
  }

  int get stagexlColor {
    RgbColor rgbColor = color.toRgbColor();
    return 0xFF000000 + 0x10000 * rgbColor.r + 0x100 * rgbColor.g + rgbColor.b;
  }
}