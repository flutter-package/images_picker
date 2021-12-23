# images_picker

[![images-picker](https://img.shields.io/badge/pub-1.2.10-orange)](https://pub.dev/packages/images_picker)

Flutter plugin for selecting images/videos from the Android and iOS image library, and taking pictures/videos with the camera,save image/video to album/gallery

ios(10+): [ZLPhotoBrowser](https://github.com/longitachi/ZLPhotoBrowser)

android(21+): [PictureSelector](https://github.com/LuckSiege/PictureSelector)

### Support
- pick multiple images/videos from photo album (wechat style)
- use camera to take image/video
- crop images with custom aspectRatio
- compress images with quality/maxSize
- save image/video to album/gallery
- localizations currently support
  - System, Chinese, ChineseTraditional, English, Japanese, French, Korean, German, Vietnamese,
    
### Install
For ios:
```
<key>NSCameraUsageDescription</key>
<string>Example usage description</string>
<key>NSMicrophoneUsageDescription</key>
<string>Example usage description</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Example usage description</string>
```
For android:
```
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```

```
Goto android/app/build.gradle
minSdkVersion 21
```

And,
```yaml
images_picker: ^newest
```
```dart
import "package:images_picker/images_picker.dart";
```

### Usage

- simple picker image

```dart
Future getImage() async {
    List<Media> res = await ImagesPicker.pick(
      count: 3,
      pickType: PickType.image,
    );
// Media
// .path
// .thumbPath (path for video thumb)
// .size (kb)
}
```
- simple picker video
```dart
Future getImage() async {
    List<Media> res = await ImagesPicker.pick(
      count: 3,
      pickType: PickType.video,
    );
// Media
// .path
// .thumbPath (path for video thumb)
// .size (kb)
}
```
- simple open camera
```dart
ImagesPicker.openCamera(
  pickType: PickType.video,
  maxTime: 15, // record video max time
);
```
- add gif support
```dart
ImagesPicker.pick(
  // ...
  gif: true, // default is true
);
```
- add max video duration pick
```dart
ImagesPicker.pick(
  // ...
  maxTime: 30, // second
);
```
- add cropper (gif crop unsupported)
```dart
ImagesPicker.pick(
  // ...
  // when cropOpt isn't null, crop is enabled
  cropOpt: CropOption(
    aspectRatio: CropAspectRatio.custom,
    cropType: CropType.rect, // currently for android
  ),
);
```
- add compress
```dart
ImagesPicker.pick(
  // ...
  // when maxSize/quality isn't null, compress is enabled
  quality: 0.8, // only for android
  maxSize: 500, // only for ios (kb)
);
```
- set language
```dart
ImagesPicker.pick(
  language: Language.English,
// you can set Language.System for following phone language
)
```
- save file to album
```dart
ImagesPicker.saveImageToAlbum(file, albumName: "");
ImagesPicker.saveVideoToAlbum(file, albumName: "");
```
- save network file to album

**because the HTTP request is uncontrollable in plugin(such as progress),you must download file ahead of time**
```dart
void save() async {
    File file = await downloadFile('https://xxx.example.com/xx.png');
    bool res = await ImagesPicker.saveImageToAlbum(file, albumName: "");
    print(res);
}

Future<File> downloadFile(String url) async {
  Dio simple = Dio();
  String savePath = Directory.systemTemp.path + '/' + url.split('/').last;
  await simple.download(url, savePath,
      options: Options(responseType: ResponseType.bytes));
  print(savePath);
  File file = new File(savePath);
  return file;
}
```
### All params
```dart
// for pick
int count = 1,
PickType pickType = PickType.image,
bool gif = true,
int maxTime = 120,
CropOption cropOpt,
int maxSize,
double quality,

// for camera
PickType pickType = PickType.image,
int maxTime = 15,
CropOption cropOpt,
int maxSize,
double quality,
```
### proguard-rules
```
-keep class com.luck.picture.lib.** { *; }

-dontwarn com.yalantis.ucrop**
-keep class com.yalantis.ucrop** { *; }
-keep interface com.yalantis.ucrop** { *; }
```

# License
MIT License
