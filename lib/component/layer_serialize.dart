// To parse this JSON data, do
//
//     modelInfo = modelInfoFromJson(jsonString);

import 'dart:convert';

ModelInfo modelInfoFromJson(String str) => ModelInfo.fromJson(json.decode(str));

String modelInfoToJson(ModelInfo data) => json.encode(data.toJson());

class ModelInfo {
  String framework;
  double? lr;
  String? loss;
  String? optimizer;
  int? epoch;
  int? batch;
  List<LayerInfo> layers;

  ModelInfo({
    required this.framework,
    required this.layers,
    this.lr,
    this.loss,
    this.optimizer,
    this.epoch,
    this.batch,
  });

  factory ModelInfo.fromJson(Map<String, dynamic> json) => ModelInfo(
        framework: json["framework"],
        lr: json["lr"]?.toDouble(),
        loss: json["loss"],
        optimizer: json["optimizer"],
        epoch: json["epoch"],
        batch: json["batch"],
        layers: List<LayerInfo>.from(
            json["layers"].map((x) => LayerInfo.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "framework": framework,
        "lr": lr,
        "loss": loss,
        "optimizer": optimizer,
        "epoch": epoch,
        "batch": batch,
        "layers": List<dynamic>.from(layers.map((x) => x.toJson())),
      };
}

class LayerInfo {
  String type;
  List<int>? dimensions;
  int? filterNum;
  List<dynamic>? filterSize;
  dynamic stride;
  String? padding;
  String? activation;
  int? nou;

  LayerInfo({
    required this.type,
    this.dimensions,
    this.filterNum,
    this.filterSize,
    this.stride,
    this.padding,
    this.activation,
    this.nou,
  });

  // 访问不存在的key时返回null
  factory LayerInfo.fromJson(Map<String, dynamic> json) => LayerInfo(
        type: json["type"],
        dimensions: json["dimensions"] == null
            ? null
            : List<int>.from(json["dimensions"]!.map((x) => x)),
        filterNum: json["filter_num"],
        filterSize: json["filter_size"] == null
            ? null
            : List<dynamic>.from(json["filter_size"]!.map((x) => x)),
        stride: json["stride"],
        padding: json["padding"],
        activation: json["activation"],
        nou: json["nou"],
      );

  Map<String, dynamic> toJson() {
    var map = {
      "type": type,
      "dimensions": dimensions == null
          ? null
          : List<dynamic>.from(dimensions!.map((x) => x)),
      "filter_num": filterNum,
      "filter_size": filterSize == null
          ? null
          : List<dynamic>.from(filterSize!.map((x) => x)),
      "stride": stride,
      "padding": padding,
      "activation": activation,
      "nou": nou,
    };
    // 专门去除空值，避免生成一堆"xxx":null
    map.removeWhere((key, value) => value == null);
    return map;
  }
}
