import 'package:flutter_application_1/component/layer_serialize.dart';

class GlobalVar {
  static ModelInfo modelInfo = ModelInfo(framework: 'tensorflow')
    ..batch = 32
    ..epoch = 20
    ..loss = 'SGD'
    ..lr = 0.001
    ..optimizer = 'adam'
    ..layers = <LayerInfo>[];

  static void addLayers(int index, LayerInfo layer) {
    modelInfo.layers?.insert(index, layer);
  }
}
