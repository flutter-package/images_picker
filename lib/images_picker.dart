
import 'dart:async';

import 'package:flutter/services.dart';

class ImagesPicker {
  static const MethodChannel _channel =
      const MethodChannel('chavesgu/images_picker');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<List<Media>> pick({
    int count = 1,
    PickType pickType = PickType.image,
  }) async {
    try {
      List<dynamic> res = await _channel.invokeMethod('pick', {
        "count": count,
        "pickType": pickType.toString(),
      });
      if (res.length > 0) {
        List<Media> output = (res ?? []).map((image) {
          Media media = Media();
          media.thumbPath = image["thumbPath"];
          media.path = image["path"];
          media.size = image["size"]?.toDouble();
          return media;
        }).toList();
        return output;
      }
      return null;
    } catch (e) {
//      print(e);
      return null;
    }
  }

  static Future<List<Media>> openCamera({
    PickType pickType = PickType.image,
    int maxTime = 15,
  }) async {
    try {
      List<dynamic> res = await _channel.invokeMethod('openCamera', {
        "pickType": pickType.toString(),
        "maxTime": maxTime,
      });
      if (res.length > 0) {
        List<Media> output = (res ?? []).map((image) {
          Media media = Media();
          media.thumbPath = image["thumbPath"];
          media.path = image["path"];
          media.size = image["size"]?.toDouble();
          return media;
        }).toList();
        return output;
      }
      return null;
    } catch (e) {
//      print(e);
      return null;
    }
  }
}

enum PickType {
  image,
  video,
}

class Media {
  ///视频缩略图图片路径
  ///Video thumbnail image path
  String thumbPath;

  ///视频路径或图片路径
  ///Video path or image path
  String path;

  /// 文件大小
  double size;
}
