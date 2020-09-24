
import 'dart:async';

import 'package:flutter/cupertino.dart';
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
    CropOption cropOpt,
  }) async {
    try {
      List<dynamic> res = await _channel.invokeMethod('pick', {
        "count": count,
        "pickType": pickType.toString(),
        "cropOption": cropOpt!=null?{
          "quality": cropOpt.quality,
          "cropType": cropOpt.cropType?.toString(),
          "aspectRatioX": cropOpt.aspectRatio?.aspectRatioX,
          "aspectRatioY": cropOpt.aspectRatio?.aspectRatioY,
        }:null,
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

enum CropType {
  rect,
  circle,
}

class CropAspectRatio {
  final int aspectRatioX;
  final int aspectRatioY;

  const CropAspectRatio(this.aspectRatioX, this.aspectRatioY)
    :
      assert(aspectRatioX > 0, 'aspectRatioX must > 0'),
      assert(aspectRatioY > 0, 'aspectRatioY must > 0');
}

class CropOption {
  final CropType cropType;
  final CropAspectRatio aspectRatio;
  final double quality;

  CropOption({
    this.aspectRatio = const CropAspectRatio(1, 1),
    this.cropType = CropType.rect,
    this.quality = 1,
  }) :
      assert(quality > 0, 'quality must > 0'),
      assert(quality <= 1, 'quality must <= 1');
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

  Media({
    this.path,
    this.thumbPath,
    this.size,
  });
}
