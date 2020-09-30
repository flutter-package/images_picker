
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
    bool gif = true,
    CropOption cropOpt,
    int maxSize,
    double quality,
  }) async {
    assert(count > 0, 'count must > 0');
    if (quality != null) {
      assert(quality > 0, 'quality must > 0');
      assert(quality <= 1, 'quality must <= 1');
    }
    if (maxSize != null) {
      assert(maxSize > 0, 'maxSize must > 0');
    }
    try {
      List<dynamic> res = await _channel.invokeMethod('pick', {
        "count": count,
        "pickType": pickType.toString(),
        "gif": gif,
        "maxSize": maxSize ?? null,
        "quality": quality ?? -1,
        "cropOption": cropOpt!=null?{
          "quality": quality ?? 1,
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
          if (image["size"]!=null) media.size = (image["size"]/1024).toDouble();
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
    CropOption cropOpt,
    int maxSize,
    double quality,
  }) async {
    if (quality != null) {
      assert(quality > 0, 'quality must > 0');
      assert(quality <= 1, 'quality must <= 1');
    }
    if (maxSize != null) {
      assert(maxSize > 0, 'maxSize must > 0');
    }
    try {
      List<dynamic> res = await _channel.invokeMethod('openCamera', {
        "pickType": pickType.toString(),
        "maxTime": maxTime,
        "maxSize": maxSize ?? null,
        "quality": quality ?? -1,
        "cropOption": cropOpt!=null?{
          "quality": quality ?? 1,
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
          if (image["size"]!=null) media.size = (image["size"]/1024).toDouble();
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
  all,
}

enum CropType {
  rect,
  circle,
}

class CropAspectRatio {
  final double aspectRatioX;
  final double aspectRatioY;

  const CropAspectRatio(this.aspectRatioX, this.aspectRatioY)
    :
      assert(aspectRatioX > 0.0, 'aspectRatioX must > 0'),
      assert(aspectRatioY > 0.0, 'aspectRatioY must > 0');

  static const custom = null;
  static const wh2x1 = CropAspectRatio(2, 1);
  static const wh1x2 = CropAspectRatio(1, 2);
  static const wh3x4 = CropAspectRatio(3, 4);
  static const wh4x3 = CropAspectRatio(4, 3);
  static const wh16x9 = CropAspectRatio(16, 9);
  static const wh9x16 = CropAspectRatio(9, 16);
}

class CropOption {
  final CropType cropType;
  final CropAspectRatio aspectRatio;

  CropOption({
    this.aspectRatio = CropAspectRatio.custom,
    this.cropType = CropType.rect,
  });
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
