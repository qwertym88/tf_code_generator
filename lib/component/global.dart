import 'package:flutter_application_1/component/layer_serialize.dart';

class GlobalVar {
  static ModelInfo modelInfo = ModelInfo(
      framework: 'tensorflow', layers: <LayerInfo>[], dataset: 'MNIST')
    ..batch = 32
    ..epoch = 20
    ..loss = 'SGD'
    ..lr = 0.001
    ..optimizer = 'Adam';

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

  static int getHash(int index) {
    return modelInfo.layers[index].hashCode;
  }
}

// 生成python代码
String generate(ModelInfo model) {
  String code = '''#import statements
import keras
import numpy as np
import tensorflow as tf
from keras.layers import *
from keras import optimizers
from keras.callbacks import TensorBoard
from datetime import datetime

TIMESTAMP = '{0:%H-%M-%S %m-%d-%Y/}'.format(datetime.now())
train_log_dir = 'logs/train/' + TIMESTAMP\n\n''';

  String? vocabulary = model.layers[0].vocabulary?.toString(); // 第一层必须是input
  String inputShape =
      model.layers[0].dimensions!.map((i) => i.toString()).join(', ');

  switch (model.dataset) {
    case 'MNIST':
      code += '''from keras.datasets import mnist
from keras.utils import to_categorical

#preprocessing:
(x_train, y_train), (x_test, y_test) = mnist.load_data()

x_train = x_train.reshape(x_train.shape[0], 28, 28, 1).astype('float32') / 255.0
x_test = x_test.reshape(x_test.shape[0], 28, 28, 1).astype('float32') / 255.0
y_train = to_categorical(y_train, num_classes=10)
y_test = to_categorical(y_test, num_classes=10)\n''';
      break;
    case 'IMDB':
      code += '''from keras.datasets import imdb
from keras_preprocessing.sequence import pad_sequences

#preprocessing:
(x_train,y_train),(x_test,y_test) = imdb.load_data(num_words=$vocabulary)\n\n

x_train = pad_sequences(x_train, maxlen=$inputShape)
x_test = pad_sequences(x_test, maxlen=$inputShape)\n''';
      break;
    case 'Reuters':
      code += '''from keras.datasets import reuters
from keras_preprocessing.sequence import pad_sequences
from keras.utils import to_categorical

#preprocessing:
(x_train,y_train),(x_test,y_test) = reuters.load_data(num_words=$vocabulary)

x_train = pad_sequences(x_train, maxlen=$inputShape)
x_test = pad_sequences(x_test, maxlen=$inputShape)
num_classes = np.max(y_train) + 1 # num_classes=46
y_train = to_categorical(y_train, num_classes)
y_test = to_categorical(y_test, num_classes)\n''';
      break;
    case 'Fashion MNIST':
      code += '''from keras.datasets import fashion_mnist
from keras.utils import to_categorical

#preprocessing:
(x_train, y_train), (x_test, y_test) = fashion_mnist.load_data()

x_train = x_train.reshape(x_train.shape[0], 28, 28, 1).astype('float32') / 255.0
x_test = x_test.reshape(x_test.shape[0], 28, 28, 1).astype('float32') / 255.0
y_train = to_categorical(y_train, num_classes=10)
y_test = to_categorical(y_test, num_classes=10)\n''';
      break;
    case 'CIFAR 10':
      code += '''from keras.datasets import cifar10
from keras.utils import to_categorical

#preprocessing:
(x_train, y_train), (x_test, y_test) = cifar10.load_data()

x_train = x_train.astype('float32') / 255.0
x_test = x_test.astype('float32') / 255.0
y_train = to_categorical(y_train, num_classes=10)
y_test = to_categorical(y_test, num_classes=10)\n''';
      break;
    default:
      break;
  }

  code += '#creating the model\n';
  code += 'model = keras.Sequential()\n';
  code += '#adding layers\n';
  code += 'model.add(InputLayer(input_shape = ($inputShape)))\n';

  for (LayerInfo layer in model.layers) {
    switch (layer.type) {
      //linear case
      case 'Dense':
        code +=
            'model.add(Dense(${layer.nou!}, activation = \'${layer.activation!.toLowerCase()}\'))\n';
        break;

      //convolution case
      case 'Convolution':
        String d;
        if (layer.kernelSize!.length == 1) {
          d = '1D';
        } else if (layer.kernelSize!.length == 2) {
          d = '2D';
        } else if (layer.kernelSize!.length == 3) {
          d = '3D';
        } else {
          break;
        }
        code +=
            'model.add(Conv$d(${layer.nou!}, (${layer.kernelSize!.join(', ')}), strides = ${layer.stride!}, activation = \'${layer.activation!.toLowerCase()}\', padding = \'${layer.padding!.toLowerCase()}\'))\n';
        break;

      //pooling case
      case 'Pooling':
        String d;
        if (layer.kernelSize!.length == 1) {
          d = '1D';
        } else if (layer.kernelSize!.length == 2) {
          d = '2D';
        } else if (layer.kernelSize!.length == 3) {
          d = '3D';
        } else {
          break;
        }
        if (layer.method! == 'MaxPooling') {
          code +=
              'model.add(MaxPooling$d((${layer.kernelSize!.join(', ')}), strides = ${layer.stride}))\n';
        } else if (layer.method! == 'AvePooling') {
          code +=
              'model.add(AveragePooling$d((${layer.kernelSize!.join(', ')}), strides = ${layer.stride}))\n';
        } else if (layer.method! == 'GlobalMaxPooling') {
          code += 'model.add(GlobalMaxPooling$d())\n';
        }
        break;

      // LSTM case
      case 'LSTM':
        code +=
            'model.add(LSTM(${layer.nou!}, dropout=${layer.dropout!}, recurrent_dropout=${layer.recurrentDropout!}))\n';
        break;

      // normalization case
      case 'Normalization':
        if (layer.method! == 'BatchNormalization') {
          code += 'model.add(BatchNormalization(axis = ${layer.axis!}))\n';
        } else if (layer.method! == 'LayerNormalization') {
          code += 'model.add(LayerNormalization(axis = ${layer.axis!}))\n';
        } else if (layer.method! == 'GroupNormalization') {
          code += 'model.add(GroupNormalization(axis = ${layer.axis!}))\n';
        }
        break;

      // reshaping case
      case 'Reshaping':
        if (layer.method! == 'Reshape') {
          code += 'model.add(Reshape((${layer.dimensions!.join(', ')})))\n';
        } else if (layer.method! == 'Flatten') {
          code += 'model.add(Flatten())\n';
        }
        break;

      // dropout case
      case 'Dropout':
        if (layer.method! == 'Dropout') {
          code += 'model.add(Dropout(${layer.dropout!}))\n';
        } else if (layer.method! == 'SpatialDropout' &&
            layer.dimensions!.length <= 3) {
          code +=
              'model.add(SpatialDropout${layer.dimensions!.length}D(${layer.dropout!}))\n';
        }
        break;

      // embedding case
      case 'Embedding':
        if (vocabulary != null) {
          code +=
              'model.add(Embedding(input_dim = ${layer.inputDim!}, output_dim = ${layer.outputDim!}))\n';
        }
        break;

      // output case
      case 'Output':
        code +=
            'model.add(Dense(${layer.nou!}, activation = \'${layer.activation!.toLowerCase()}\'))\n';
        break;

      default:
        break;
    }
  }
  code += '\nmodel.summary()\n\n';

  code += '#compiling the model\n';
  code +=
      'model.compile(optimizer = optimizers.${model.optimizer!}(learning_rate = ${model.lr}), loss = \'${model.loss!.toLowerCase()}\', metrics=[\'acc\'])\n\n';

  code += '#training the model\n';
  code += 'tbCallBack = TensorBoard(log_dir = train_log_dir)\n';
  code +=
      'history = model.fit(x = x_train, y = y_train, batch_size = ${model.batch}, epochs = ${model.epoch},callbacks = [tbCallBack])\n\n\n';

  code += '#testing the model\n';
  code += 'print("\\n\\nevaluating model performance...\\n")\n';
  code += 'model.evaluate(x_test,y_test)';
  return code;
}
