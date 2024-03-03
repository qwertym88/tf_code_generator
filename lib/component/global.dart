import 'package:flutter_application_1/component/layer_serialize.dart';

class GlobalVar {
  static ModelInfo modelInfo =
      ModelInfo(framework: 'tensorflow', layers: <LayerInfo>[])
        ..batch = 32
        ..epoch = 20
        ..loss = 'SGD'
        ..lr = 0.001
        ..optimizer = 'adam';

  // 按照index插入list，返回hash
  static int addLayer(int index, LayerInfo layer) {
    modelInfo.layers.insert(index, layer);
    return layer.hashCode;
  }

  // remove时layer widget记录的index会错位，故根据hash删除
  static void removeLayer(int hash) {
    modelInfo.layers.removeWhere((element) => element.hashCode == hash);
  }

  static LayerInfo getLayer(int hash) {
    return modelInfo.layers.firstWhere((element) => element.hashCode == hash);
  }
}
