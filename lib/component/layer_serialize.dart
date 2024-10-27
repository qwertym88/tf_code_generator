// To parse this JSON data, do
//
//     modelInfo = modelInfoFromJson(jsonString);

import 'dart:convert';

ModelInfo modelInfoFromJson(String str) => ModelInfo.fromJson(json.decode(str));

String modelInfoToJson(ModelInfo data) => json.encode(data.toJson());

// TODO: layer_serialize添加datasets  已添加待测试
class ModelInfo {
  String framework;
  String dataset;
  List<LayerInfo> layers;
  double? lr;
  String? loss;
  String? optimizer;
  int? epoch;
  int? batch;

  ModelInfo({
    required this.framework,
    required this.layers,
    required this.dataset,
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
        dataset: json["dataset"],
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
        "dataset": dataset,
        "epoch": epoch,
        "batch": batch,
        "layers": List<dynamic>.from(layers.map((x) => x.toJson())),
      };
}

class LayerInfo {
  String type;
  List<int>? dimensions;
  int? vocabulary;
  int? filterNum;
  List<int>? kernelSize;
  int? stride;
  String? padding;
  String? activation;
  String? method; // 细分类别
  int? nou;
  int? axis;
  double? dropout;
  double? recurrentDropout;
  int? inputDim;
  int? outputDim;

  LayerInfo({
    required this.type,
    this.dimensions,
    this.vocabulary,
    this.filterNum,
    this.kernelSize,
    this.stride,
    this.padding,
    this.activation,
    this.method,
    this.nou,
    this.axis,
    this.dropout,
    this.recurrentDropout,
    this.inputDim,
    this.outputDim,
  });

  // 访问不存在的key时返回null
  factory LayerInfo.fromJson(Map<String, dynamic> json) => LayerInfo(
        type: json["type"],
        dimensions: json["dimensions"] == null
            ? null
            : List<int>.from(json["dimensions"]!.map((x) => x)),
        vocabulary: json["vocabulary"],
        filterNum: json["filter_num"],
        kernelSize: json["kernel_size"] == null
            ? null
            : List<int>.from(json["kernel_size"]!.map((x) => x)),
        stride: json["stride"],
        padding: json["padding"],
        activation: json["activation"],
        method: json["method"],
        nou: json["nou"],
        axis: json["axis"],
        dropout: json["dropout"],
        recurrentDropout: json["recurrent_dropout"],
        inputDim: json["input_dim"],
        outputDim: json["output_dim"],
      );

  Map<String, dynamic> toJson() {
    var map = {
      "type": type,
      "dimensions":
          dimensions == null ? null : List<int>.from(dimensions!.map((x) => x)),
      "vocabulary": vocabulary,
      "filter_num": filterNum,
      "kernel_size":
          kernelSize == null ? null : List<int>.from(kernelSize!.map((x) => x)),
      "stride": stride,
      "padding": padding,
      "activation": activation,
      "method": method,
      // "pooling": pooling,
      // "normalization": normalization,
      // "reshaping": reshaping,
      "nou": nou,
      "axis": axis,
      "dropout": dropout,
      "recurrent_dropout": recurrentDropout,
      "input_dim": inputDim,
      "output_dim": outputDim,
    };
    // 专门去除空值，避免生成一堆"xxx":null
    map.removeWhere((key, value) => value == null);
    return map;
  }
}
