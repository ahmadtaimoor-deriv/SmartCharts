import 'dart:convert';
import 'package:chart_app/src/interop/js_interop.dart';
import 'package:deriv_chart/deriv_chart.dart' hide AddOnsRepository;
import 'package:chart_app/src/add_ons/add_ons_repository.dart';

/// State and methods of chart web adapter config.
class DrawingToolModel {
  /// Initialize
  DrawingToolModel();

  /// Drawing tools repo
  final AddOnsRepository<DrawingToolConfig> drawingToolsRepo =
      AddOnsRepository<DrawingToolConfig>(
    createAddOn: (Map<String, dynamic> map) => DrawingToolConfig.fromJson(map),
    onAddCallback: (AddOnConfig config) {
      final DrawingToolConfig drawingToolConfig = config as DrawingToolConfig;
      if (drawingToolConfig.drawingData != null &&
          drawingToolConfig.drawingData!.isDrawingFinished) {
        JsInterop.drawingTool?.onAdd?.call();
      }
    },
    onLoadCallback: (List items) {
      JsInterop.drawingTool?.onLoad?.call(items);
    },
    onUpdateCallback: (int index, AddOnConfig config) {
      JsInterop.drawingTool?.onUpdate?.call(index, config);
    },
  );

  /// DrawingTools
  late DrawingTools drawingTools = DrawingTools(
    onMouseEnterCallback: (int index) =>
        JsInterop.drawingTool?.onMouseEnter?.call(index),
    onMouseExitCallback: (int index) =>
        JsInterop.drawingTool?.onMouseExit?.call(index),
  )..drawingToolsRepo = drawingToolsRepo;

  ///
  void selectDrawing(DrawingToolConfig config) {
    drawingTools.onDrawingToolSelection(config);
  }

  /// Getting the repo
  AddOnsRepository<DrawingToolConfig> getDrawingTool() => drawingToolsRepo;

  /// function to get drawtools
  DrawingTools getDrawingTools() => drawingTools;

  /// To add a drawing
  void addOrUpdateDrawing(String dataString, int? index) {
    final Map<String, dynamic> config = json.decode(dataString)..remove('id');

    DrawingToolConfig? drawingToolConfig = DrawingToolConfig.fromJson(config);

    if (index != null && index > -1) {
      drawingToolConfig = drawingToolConfig.copyWith(
        configId: drawingToolsRepo.items[index].toJson()['configId'],
        edgePoints: drawingToolsRepo.items[index].toJson()['edgePoints'],
        drawingData: drawingToolsRepo.items[index].toJson()['drawingData'],
      );

      drawingTools.drawingToolsRepo!.updateAt(index, drawingToolConfig);
    } else {
      drawingTools.onDrawingToolSelection(drawingToolConfig);
    }
  }

  /// Adding Drawing used when restoring drawing from the localStorage
  void addDrawing(String dataString) {
    final Map<String, dynamic> config = json.decode(dataString)..remove('id');

    DrawingToolConfig? drawingToolConfig = DrawingToolConfig.fromJson(config);

    drawingToolConfig = drawingToolConfig.copyWith(
      configId: drawingToolConfig.configId,
      edgePoints: drawingToolConfig.edgePoints,
      drawingData: DrawingData(
        id: drawingToolConfig.configId!,
        drawingParts: drawingToolConfig.drawingData!.drawingParts,
        isDrawingFinished: true,
      ),
    );

    drawingTools.drawingToolsRepo!.add(drawingToolConfig);
  }

  /// To remove an existing drawing tool
  void removeDrawingTool(int index) {
    drawingToolsRepo.removeAt(index);
  }

  /// To get the tool name from config
  String getTypeOfSelectedDrawingTool(DrawingToolConfig config) {
    if (config is VerticalDrawingToolConfig) {
      return 'vertical';
    } else if (config is LineDrawingToolConfig) {
      return 'line';
    } else if (config is RayDrawingToolConfig) {
      return 'ray';
    } else if (config is ContinuousDrawingToolConfig) {
      return 'continuous';
    } else if (config is TrendDrawingToolConfig) {
      return 'trend';
    } else if (config is HorizontalDrawingToolConfig) {
      return 'Horizontal';
    } else if (config is ChannelDrawingToolConfig) {
      return 'channel';
    } else if (config is FibfanDrawingToolConfig) {
      return 'fibfan';
    } else if (config is RectangleDrawingToolConfig) {
      return 'rectangle';
    } else {
      return '';
    }
  }

  /// To edit a drawing
  void editDrawing(DrawingToolConfig drawingToolConfig, int? index) {
    if (index != null) {
      final DrawingToolConfig config = drawingToolConfig;
      drawingToolsRepo.updateAt(index, config);
      // drawingTools.drawingToolsRepo!.updateAt(index, config);
    }
  }

  ///
  void clearDrawingToolSelect() {
    drawingTools.clearDrawingToolSelection();
  }

  /// To clear all drawing tool
  void clearDrawingTool() {
    drawingTools.clearDrawingToolSelection();
    drawingToolsRepo.clear();
  }
}