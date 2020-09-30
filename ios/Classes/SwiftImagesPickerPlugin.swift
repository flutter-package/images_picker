import Flutter
import UIKit
import AssetsLibrary
import Photos
import MobileCoreServices
import ZLPhotoBrowser

protocol StringOrInt { }

extension Int: StringOrInt { }
extension UInt64: StringOrInt { }
extension String: StringOrInt { }

public class SwiftImagesPickerPlugin: NSObject, FlutterPlugin {
  static let channelName:String = "chavesgu/images_picker";

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
    let instance = SwiftImagesPickerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method=="pick" {
      let args = call.arguments as? NSDictionary;
      let count = args!["count"] as! Int;
      let pickType = args!["pickType"] as? String;
      let supportGif = args!["gif"] as! Bool;
      let maxSize = args!["maxSize"] as? Int;
      let cropOption = args!["cropOption"] as? NSDictionary;
      let theme = args!["theme"] as? NSDictionary;

      let vc = UIApplication.shared.delegate!.window!!.rootViewController!;
      let ac = ZLPhotoPreviewSheet();
      let config = ZLPhotoConfiguration.default();
      self.setConfig(configuration: config, pickType: pickType);
      config.maxSelectCount = count;
      config.allowSelectGif = supportGif;
      if cropOption != nil {
        config.allowEditImage = true;
        if let aspectRatioX = cropOption!["aspectRatioX"] as? Double,let aspectRatioY = cropOption!["aspectRatioY"] as? Double {
          config.editImageClipRatios = [ZLImageClipRatio(title: "", whRatio: CGFloat(aspectRatioX/aspectRatioY))];
        }
      }

      self.setThemeColor(configuration: config, colors: theme);

      var resArr = [[String: StringOrInt]]();

      ac.selectImageBlock = { (images, assets, isOriginal) in
        let manager = PHImageManager.default();
        if pickType=="PickType.image" { // 解析图片
          let group = DispatchGroup();
          for (index, image) in images.enumerated() {
            let asset = assets[index];
            group.enter();
            if self.getImageType(asset: asset)=="gif" && supportGif { // gif 取原路径
              self.resolveImage(asset: asset, resultHandler: { dir in
                resArr.append(dir);
                group.leave();
              })
            } else {
              resArr.append(self.resolveImage(image: image, maxSize: maxSize));
              group.leave();
            }
          }
          group.notify(queue: .main) {
            result(resArr);
          }
        } else if pickType=="PickType.video" { // 解析视频
          let group = DispatchGroup();
          let options = PHVideoRequestOptions()
          options.isNetworkAccessAllowed = true
          options.deliveryMode = .automatic
          options.version = .original
          for asset in assets {
            // requestAVAsset
            group.enter();
            manager.requestAVAsset(forVideo: asset, options: options, resultHandler: { avasset,audioMix,info  in
              let videoUrl = avasset as! AVURLAsset;
              let url = videoUrl.url;
              // TODO: mov to mp4
              resArr.append(self.resolveVideo(url: url));
              group.leave();
            })
          }
          group.notify(queue: .main) {
            result(resArr);
          }
        } else {
          result(nil);
        }
      }
      ac.showPhotoLibrary(sender: vc);
    } else if call.method=="openCamera" {  // 相机拍照、录视频
      let args = call.arguments as? NSDictionary;
      let pickType = args!["pickType"] as? String;
      let cropOption = args!["cropOption"] as? NSDictionary;
      let maxSize = args!["maxSize"] as? Int;
      let maxTime = args!["maxTime"] as? Int;

      let vc = UIApplication.shared.delegate!.window!!.rootViewController!;
      let camera = ZLCustomCamera();
      let config = ZLPhotoConfiguration.default();
      config.maxRecordDuration = maxTime ?? 15;
      self.setConfig(configuration: config, pickType: pickType);
      if cropOption != nil {
        config.allowEditImage = true;
        if let aspectRatioX = cropOption!["aspectRatioX"] as? Double,let aspectRatioY = cropOption!["aspectRatioY"] as? Double {
          config.editImageClipRatios = [ZLImageClipRatio(title: "", whRatio: CGFloat(aspectRatioX/aspectRatioY))];
        }
      }

      camera.takeDoneBlock = { (image, url) in
        if pickType=="PickType.image" {
          if let image = image {
            var resArr = [[String: StringOrInt]]();
            resArr.append(self.resolveImage(image: image, maxSize: maxSize));
            result(resArr);
          } else {
            result(nil);
          }
        } else if pickType=="PickType.video" {
          if let url = url {
            var resArr = [[String: StringOrInt]]();
            resArr.append(self.resolveVideo(url: url));
            result(resArr);
          } else {
            result(nil);
          }
        }
      }
      vc.showDetailViewController(camera, sender: nil);
    } else if call.method=="saveImageToAlbum" {
//      ZLPhotoManager.saveImageToAlbum();
    } else if call.method=="saveVideoToAlbum" {
//      ZLPhotoManager.saveVideoToAblum();
    } else {
      result(nil);
    }
  }

  // 图片解析  写入tmp
  private func resolveImage(image: UIImage, maxSize: Int?)->[String: StringOrInt] {
    var dir = [String: StringOrInt]();
    let data:Data?;
    let imagePath:String;
    if let maxSize = maxSize { // 需要压缩
      imagePath = self.compressImage(image: image, maxSize: maxSize);
    } else { // 不需要压缩
      data = image.jpegData(compressionQuality: 1);
      imagePath = self.createFile(data: data);
    }
    dir.updateValue(imagePath, forKey: "path");
    dir.updateValue(imagePath, forKey: "thumbPath");
    do {
      let attr = try FileManager.default.attributesOfItem(atPath: imagePath);
      let fileSize = attr[FileAttributeKey.size] as! UInt64;
      dir.updateValue(fileSize, forKey: "size");
    } catch {
    }
    return dir;
  }
// 解析gif
  private func resolveImage(asset: PHAsset, resultHandler: @escaping ([String: StringOrInt])->Void)->Void {
    var dir = [String: StringOrInt]();
    let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
    options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
      return true
    }
    asset.requestContentEditingInput(with: options, completionHandler: { contentEditingInput, info in
      if let url = contentEditingInput!.fullSizeImageURL {
        let urlStr = url.absoluteString;
        let path = (urlStr as NSString).substring(from: 7);
        dir.updateValue(path, forKey: "path");
        dir.updateValue(path, forKey: "thumbPath");
        do {
          let size = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize;
          dir.updateValue((size ?? 0) as Int, forKey: "size");
        } catch {
        }
        resultHandler(dir);
      } else {
        resultHandler(dir);
      }
    })
  }

  private func resolveVideo(url: URL)->[String: StringOrInt] {
    var dir = [String: StringOrInt]();

    let urlStr = url.absoluteString;
    let path = (urlStr as NSString).substring(from: 7);
    dir.updateValue(path, forKey: "path");

    let thumb = self.getVideoThumbPath(url: path); // 获取视频封面图
    let thumbData = thumb?.jpegData(compressionQuality: 1); // 转Data
    let thumbPath = self.createFile(data: thumbData); // 写入封面图
    dir.updateValue(thumbPath, forKey: "thumbPath");
    do {
      let size = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize;
      dir.updateValue((size ?? 0) as Int, forKey: "size");
    } catch {
    }
    return dir;
  }


  private func getVideoThumbPath(url: String)->UIImage? {
    do {
      let avasset = AVAsset.init(url: NSURL.fileURL(withPath: url));
      let gen = AVAssetImageGenerator.init(asset: avasset);
      gen.appliesPreferredTrackTransform = true;
      let time = CMTime.init(seconds: 0.0, preferredTimescale: 600);
      let image = try gen.copyCGImage(at: time, actualTime: nil);
      let thumb = UIImage.init(cgImage: image);
      return thumb;
    } catch {
      return nil;
    }
  }

  private func createFile(data: Data?)->String {
    let uuid = UUID().uuidString;
    let tmpDir = NSTemporaryDirectory();
    let filename = "\(tmpDir)image_picker_\(uuid).jpg";
    let fileManager = FileManager.default;
    fileManager.createFile(atPath: filename, contents: data, attributes: nil);
    return filename;
  }

  private func compressImage(image: UIImage, maxSize: Int)->String {
    let maxSize = maxSize * 1000; // to kb
    let image = self.resizeImage(originalImg: image);
    var compression:CGFloat = 1;
    var data:Data = image.jpegData(compressionQuality: compression)!;
    if (data.count < maxSize) {
      return self.createFile(data: data);
    }
    var max:CGFloat = 1;
    var min:CGFloat = 0;
    for index in (0...5) {
      compression = (max + min) / 2;
      data = image.jpegData(compressionQuality: compression)!;
      if (data.count < maxSize * Int(0.9)) {
          min = compression;
      } else if (data.count > maxSize) {
          max = compression;
      } else {
          break;
      }
    }
    return self.createFile(data: data);
  }

  private func resizeImage(originalImg:UIImage) -> UIImage{

    //prepare constants
    let width = originalImg.size.width
    let height = originalImg.size.height
    let scale = width/height

    var sizeChange = CGSize()

    if width <= 1280 && height <= 1280{ //a，图片宽或者高均小于或等于1280时图片尺寸保持不变，不改变图片大小
        return originalImg
    }else if width > 1280 || height > 1280 {//b,宽或者高大于1280，但是图片宽度高度比小于或等于2，则将图片宽或者高取大的等比压缩至1280

        if scale <= 2 && scale >= 1 {
            let changedWidth:CGFloat = 1280
            let changedheight:CGFloat = changedWidth / scale
            sizeChange = CGSize(width: changedWidth, height: changedheight)

        }else if scale >= 0.5 && scale <= 1 {

            let changedheight:CGFloat = 1280
            let changedWidth:CGFloat = changedheight * scale
            sizeChange = CGSize(width: changedWidth, height: changedheight)

        }else if width > 1280 && height > 1280 {//宽以及高均大于1280，但是图片宽高比大于2时，则宽或者高取小的等比压缩至1280

            if scale > 2 {//高的值比较小

                let changedheight:CGFloat = 1280
                let changedWidth:CGFloat = changedheight * scale
                sizeChange = CGSize(width: changedWidth, height: changedheight)

            }else if scale < 0.5{//宽的值比较小

                let changedWidth:CGFloat = 1280
                let changedheight:CGFloat = changedWidth / scale
                sizeChange = CGSize(width: changedWidth, height: changedheight)

            }
        }else {//d, 宽或者高，只有一个大于1280，并且宽高比超过2，不改变图片大小
            return originalImg
        }
    }

    UIGraphicsBeginImageContext(sizeChange)

    //draw resized image on Context
    originalImg.draw(in: CGRect(x: 0, y: 0, width: sizeChange.width, height: sizeChange.height))

    //create UIImage
    let resizedImg = UIGraphicsGetImageFromCurrentImageContext()

    UIGraphicsEndImageContext()

    return resizedImg ?? originalImg
  }
  
  private func getImageType(asset: PHAsset)->String {
    if let filename = asset.value(forKey: "filename") as? String {
      if let index = filename.lastIndex(of: ".") {
        let temp = filename.suffix(from: index);
        return String(temp.suffix(from: temp.index(temp.startIndex, offsetBy: 1))).lowercased();
      }
      return "unknown";
    }
//    if let identifier = asset.value(forKey: "uniformTypeIdentifier") as? String {
//      if identifier == kUTTypeJPEG as String {
//        return "jpg";
//      }
//      if identifier == kUTTypePNG as String {
//        return "png";
//      }
//      if identifier == kUTTypeGIF as String {
//        return "gif";
//      }
//      return "unknown";
//    }
    // kUTTypeJPEG
    // kUTTypeGIF
    // kUTTypePNG
    return "unknown";
  }

  private func setConfig(configuration: ZLPhotoConfiguration, pickType: String?) {
//    configuration.style = .externalAlbumList;
    configuration.languageType = .chineseSimplified;
    configuration.allowTakePhotoInLibrary = false;
    configuration.allowMixSelect = true;
    configuration.allowEditImage = false;
    configuration.allowEditVideo = false;
    configuration.saveNewImageAfterEdit = false;
    if pickType=="PickType.video" {
      configuration.allowSelectImage = false;
      configuration.allowSelectVideo = true;
    } else if pickType=="PickType.all" {
      configuration.allowSelectImage = true;
      configuration.allowSelectVideo = true;
    } else {
      configuration.allowSelectImage = true;
      configuration.allowSelectVideo = false;
    }
    configuration.allowSlideSelect = false;
    configuration.videoExportType = ZLCustomCamera.VideoExportType.mp4;
  }

  private func setThemeColor(configuration: ZLPhotoConfiguration, colors: NSDictionary?) {
    let theme = ZLPhotoThemeColorDeploy();
    configuration.themeColorDeploy = theme;
  }
}
