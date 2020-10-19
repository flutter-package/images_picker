# images_picker

Flutter plugin for selecting images/videos from the Android and iOS image library, and taking pictures/videos with the camera

ios(10+): [ZLPhotoBrowser](https://github.com/longitachi/ZLPhotoBrowser)

android(21+): [PictureSelector](https://github.com/LuckSiege/PictureSelector)

This plugin is learn from [lisen87/image_pickers](https://github.com/lisen87/image_pickers)

### Support
- pick multiple images/videos from photo album (wechat style)
- use camera to take image/video
- crop images with custom aspectRatio
- compress images with quality/maxSize
- localizations currently support english,chinese,japanese(more for android)
> Don't need to set localizations,the plugin will follow system

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
### All params
```dart
// for pick
int count = 1,
PickType pickType = PickType.image,
bool gif = true,
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

### TODO LIST.
- [ ] save image/videos to Photo album
- [ ] use custom themeColor

# License
MIT License
