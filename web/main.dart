import 'dart:async';
import 'dart:html';
import 'package:stagexl/stagexl.dart';
import 'stage.dart' as flowStage;

Future<Null> main() async {
  StageOptions options = StageOptions()
    ..backgroundColor = Color.White
    ..renderEngine = RenderEngine.WebGL
    ..antialias = true;

  CanvasElement canvas = querySelector('#stage');
  int canvasHeight = canvas.clientHeight;
  int canvasWidth = canvas.clientWidth;
  var stage = flowStage.Stage(canvas, width: canvasWidth, height: canvasHeight, options: options);

  var renderLoop = RenderLoop();
  renderLoop.addStage(stage);
  stage.juggler.add(stage);

  var resourceManager = ResourceManager();

  await resourceManager.load();
}
