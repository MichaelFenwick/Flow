import 'dart:html';
import 'dart:math' as Math;
import 'package:stagexl/stagexl.dart' as stagexl;

import 'cell.dart';

class Stage extends stagexl.Stage implements stagexl.Animatable {

  List<Cell> cells = [];
  Map<Cell, num> growingCells = {};
  List<Cell> shrinkingCells = [];
  stagexl.Point canvasCenter;
  num stageRadius;
  Math.Random rand = Math.Random();

  Stage(CanvasElement canvas, {int width, int height, stagexl.StageOptions options})  : super(canvas, width: width, height: height, options: options) {
    int canvasHeight = canvas.clientHeight;
    int canvasWidth = canvas.clientWidth;
    canvasCenter = stagexl.Point(canvasWidth / 2, canvasHeight / 2);
    stageRadius = Math.min(canvasCenter.x, canvasCenter.y);

    stagexl.Shape deepBackground = new stagexl.Shape();
    deepBackground.graphics
      ..rect(0, 0, canvasWidth, canvasHeight)
      ..fillColor(stagexl.Color.DarkSlateBlue);
    stage.addChild(deepBackground);


    //Draw a circular black background.
    stagexl.Shape background = new stagexl.Shape();
    background.graphics
      ..circle(canvasCenter.x, canvasCenter.y, stageRadius)
      ..fillColor(stagexl.Color.Black);
    stage.addChild(background);

    // Add some initial points
    for(int i = 0; i < 100; i++) {
      Cell cell = createNewCell();
      addCell(cell);
    }
  }

  void addCell(Cell cell) {
    cells.add(cell);
    cell.addToStage(canvasCenter, stageRadius);
    addChild(cell);
    juggler.add(cell);
  }

  @override
  bool advanceTime(num time) {
    updateGrowingCells(time);
    updateShrinkingCells(time);
    updateCellsPotential();
    return true;
  }

  void updateCellsPotential() {
    cells.forEach((Cell cell) {
      cell.calculatePotential(cells);
    });
  }

  void updateGrowingCells(num time) {
    // Just checking the mod will trigger for every frame that second, so we need to check that the last frame was on a previous second.
    if (juggler.elapsedTime.floor() % 2 == 0 && (juggler.elapsedTime - time).floor() % 2 != 0) { //Add a new cell every 2 seconds.
      Cell newCell = createNewCell();
      growingCells[newCell] = newCell.size; // Store the new cell with it's target size.
      cells.add(newCell);
      newCell.size = 0; // Change the size to 0, since new cells should start small.
      addCell(newCell);
    }

    List<Cell> cellsToRemove = [];
    growingCells.forEach((Cell cell, num targetSize) {
      cell.size = Math.min(targetSize, cell.size + 0.5 * time);
      if (cell.size >= targetSize) {
        cellsToRemove.add(cell);
      }
    });
    cellsToRemove.forEach((Cell cell) => growingCells.remove(cell));
  }

  void updateShrinkingCells(num time) {
    // Just checking the mod will trigger for every frame that second, so we need to check that the last frame was on a previous second.
    if (juggler.elapsedTime.floor() % 2 == 0 && (juggler.elapsedTime - time).floor() % 2 != 0) { //Add a new cell every 2 seconds.
      Cell cell;
      while (cell == null || growingCells.containsKey(cell)) {
        cell = cells[rand.nextInt(cells.length)];
      }
      shrinkingCells.add(cell);
    }

    List<Cell> cellsToRemove = [];
    shrinkingCells.forEach((Cell cell) {
      cell.size = Math.max(0, cell.size - 0.5 * time);
      if (cell.size <= 0) {
        cellsToRemove.add(cell);
      }
    });
    cellsToRemove.forEach((Cell cell) {
      shrinkingCells.remove(cell);
      cells.remove(cell);
      removeChild(cell); //This is throwing an error for some reason saying that the cell isn't a child of the stage.
      juggler.remove(cell);
    });
  }


  Cell createNewCell() {
    double phi = rand.nextDouble() * 2 * Math.pi;
    double r = rand.nextDouble() * stageRadius;
    stagexl.Point cellPoint = stagexl.Point.polar(r, phi) + canvasCenter;
    double size = rand.nextDouble() * 10 + 5;

    return Cell(cellPoint, size);
  }

}