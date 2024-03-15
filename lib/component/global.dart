import 'package:flutter_application_1/component/layer_serialize.dart';

class GlobalVar {
  static ModelInfo modelInfo =
      ModelInfo(framework: 'tensorflow', layers: <LayerInfo>[])
        ..batch = 32
        ..epoch = 20
        ..loss = 'SGD'
        ..lr = 0.001
        ..optimizer = 'adam'
        ..dataset = 'minst';

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

// 生成python代码
String generate(ModelInfo model) {
  //creating the string to write (code)
  String code = '#import statements\n';
  // if (model.framework == 'TensorFlow') {
  code += 'import keras\n';
  code += 'import tensorflow as tf\n';
  code += 'from keras.layers import *\n';
  code += 'from keras.callbacks import TensorBoard\n';

  code += 'from keras.datasets import ${model.dataset}\n';
  code += 'from datetime import datetime\n\n';

  code += 'TIMESTAMP = \'{0:%H-%M-%S %m-%d-%Y/}\'.format(datetime.now())\n';
  code += 'train_log_dir = \'logs/train/\' + TIMESTAMP\n\n';

  code += '#specify x_train and y_train here:\n';

  code += '(x_train,y_train),(x_test,y_test)=${model.dataset}.load_data()\n\n';
  code += '#creating the model\n';
  code += 'model = keras.Sequential()\n';
  code += '#adding layers\n';

  String inputShape =
      model.layers[0].dimensions!.map((i) => i.toString()).join(', ');
  if (model.layers[0].type == 'Input') {
    code += 'model.add(InputLayer(input_shape = ($inputShape)))\n';
  }

  for (LayerInfo layer in model.layers) {
    // let ret_seq = 'False';
    switch (layer.type) {
      //linear case
      case 'Dense':
        code +=
            'model.add(Dense(${layer.nou!}, activation = \'${layer.activation!.toLowerCase()}\'))';
        break;

      //convolution 2D case
      case 'Conv2d':
        code +=
            'model.add(Conv2D(${layer.filterNum!}, (${layer.filterSize![0]}, ${layer.filterSize![1]}), strides = ${layer.stride!}, activation = \'${layer.activation!.toLowerCase()}\', padding = \'${layer.padding}\'))';
        break;

      //pool 2D case
      case 'Max Pool 2D':
        if (layer.pooling! == 'MaxPooling') {
          code +=
              'model.add(MaxPooling2D((${layer.filterSize![0]}, ${layer.filterSize![1]}), strides = ${layer.stride}))';
        } else if (layer.pooling! == 'AvePooling') {
          code +=
              'model.add(AvePooling((${layer.filterSize![0]}, ${layer.filterSize![1]}), strides = ${layer.stride}))';
        }
        break;

      //output case
      case 'Output':
        code +=
            'model.add(Dense(${layer.nou!}, activation = \'${layer.activation!.toLowerCase()}\'))';
        break;

      //         //convolution 1D case
      //         case 'Convolution 1D':
      //             code += 'model.add(Conv1D(${layer.filter_num}, ${layer.filter_size}, strides = ${layer.stride}, activation = '${layer.activation.toLowerCase()}', padding = '${layer.padding}'))'
      //             break;

      //         //convolution 3D case
      //         case 'Convolution 3D':
      //             code += 'model.add(Conv3D(${layer.filter_num}, (${layer.filter_size[0]}, ${layer.filter_size[1]}, ${layer.filter_size[2]}), strides = ${layer.stride}, activation = '${layer.activation.toLowerCase()}', padding = '${layer.padding}'))'
      //             break;

      //         //max pool 1D case
      //         case 'Max Pool 1D':
      //             code += 'model.add(MaxPooling1D(${layer.filter_size}, strides = ${layer.stride}))'
      //             break;

      //         //max pool 3D case
      //         case 'Max Pool 3D':
      //             code += 'model.add(MaxPooling3D((${layer.filter_size[0]}, ${layer.filter_size[1]}, ${layer.filter_size[2]}), strides = ${layer.stride}))'
      //             break;

      //         //max pool 3D case
      //         case 'Activation':
      //             if (['ELU', 'LeakyReLU', 'PReLU', 'ReLU', 'Softmax', 'ThresholdedReLU'].indexOf(layer.type) >= 0) {
      //                 code += 'model.add(${layer.type}())';
      //             }
      //             else {
      //                 code += 'model.add(Activation(activations.${layer.type}))'
      //             }
      //             break;

      //         //avg pool 1D case
      //         case 'Avg Pool 1D':
      //             code += 'model.add(AveragePooling1D(${layer.filter_size}, strides = ${layer.stride}))';
      //             break;

      //         //avg pool 2D case
      //         case 'Avg Pool 2D':
      //             code += 'model.add(AveragePooling2D((${layer.filter_size[0]}, ${layer.filter_size[1]}), strides = ${layer.stride}))';
      //             break;

      //         //avg pool 3D case
      //         case 'Avg Pool 3D':
      //             code += 'model.add(AveragePooling3D((${layer.filter_size[0]}, ${layer.filter_size[1]}, ${layer.filter_size[2]}), strides = ${layer.stride}))';
      //             break;

      //         //batch normalization case
      //         case 'Batch Normalization':
      //             code += 'model.add(BatchNormalization())';
      //             break;

      //         //dropout case
      //         case 'Dropout':
      //             code += 'model.add(Dropout(rate = ${layer.prob}))';
      //             break;

      //         //embedding case
      //         case 'Embedding':
      //             code += 'model.add(Embedding(input_dim = ${layer.input_dim}, output_dim = ${layer.output_dim}, input_length = ${layer.input_length}))';
      //             break;

      //         //flatten case
      //         case 'Flatten':
      //             code += 'model.add(Flatten())';
      //             break;

      //         //LSTM and GRU case
      //         case 'GRU':
      //         case 'LSTM':
      //             if (layer.ret_seq) {
      //                 ret_seq = 'True';
      //             }
      //             code += 'model.add(${layer.name}(units = ${layer.units}, activations = '${layer.activation}', recurrent_activation = '${layer.re_activation}', return_sequences = ${ret_seq}))';
      //             break;

      //         //RNN case
      //         case 'RNN':
      //             if (layer.ret_seq) {
      //                 ret_seq = 'True';
      //             }
      //             code += 'model.add(SimpleRNN(units = ${layer.units}, activations = '${layer.activation}', return_sequences = ${ret_seq}))';
      //             break;
      default:
        break;
    }
  }
  code += '\nmodel.summary()\n\n';

  code += '#compiling the model\n';
  code +=
      'model.compile(optimizer = tf.keras.optimizers.${model.optimizer}(learning_rate = ${model.lr}), loss = \'${model.loss}\', metrics=[\'acc\'])\n\n';

  code += '#training the model\n';
  code += 'tbCallBack = TensorBoard(log_dir=train_log_dir)\n';
  code +=
      'history = model.fit(x= x_train, y= y_train, batch_size = ${model.batch}, epochs = ${model.epoch},callbacks=[tbCallBack])\n\n\n';

  code += '#testing the model\n';
  code += 'print("\\n\\nevaluating model performance...\\n")\n';
  code += 'model.evaluate(x_test,y_test)';
  return code;
}
