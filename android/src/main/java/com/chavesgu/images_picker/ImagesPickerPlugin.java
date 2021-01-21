package com.chavesgu.images_picker;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.media.ThumbnailUtils;
import android.os.Build;
import android.os.Environment;
import android.provider.MediaStore;
import android.util.Log;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.UUID;

import androidx.annotation.NonNull;

import androidx.annotation.Nullable;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import com.luck.picture.lib.PictureSelectionModel;
import com.luck.picture.lib.PictureSelector;
import com.luck.picture.lib.config.PictureConfig;
import com.luck.picture.lib.config.PictureMimeType;
import com.luck.picture.lib.entity.LocalMedia;
import com.luck.picture.lib.listener.OnResultCallbackListener;
import com.luck.picture.lib.tools.PictureFileUtils;
import com.yalantis.ucrop.util.FileUtils;

import static android.app.Activity.RESULT_OK;

/** ImagesPickerPlugin */
public class ImagesPickerPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private Result _result;
  private Activity activity;
  private Context context;
  public static String channelName = "chavesgu/images_picker";

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), channelName);
    channel.setMethodCallHandler(this);
    context = flutterPluginBinding.getApplicationContext();
  }

  public static void registerWith(Registrar registrar) {
    ImagesPickerPlugin instance = new ImagesPickerPlugin();
    final MethodChannel channel = new MethodChannel(registrar.messenger(), channelName);
    channel.setMethodCallHandler(instance);
    instance.context = registrar.context();
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    activity = binding.getActivity();
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {

  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    activity = binding.getActivity();
  }

  @Override
  public void onDetachedFromActivity() {

  }


  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    _result = result;
    switch (call.method) {
      case "getPlatformVersion":
        result.success("Android " + android.os.Build.VERSION.RELEASE);
        break;
      case "pick": {
        int count = (int) call.argument("count");
        String pickType = call.argument("pickType");
        double quality = call.argument("quality");
        boolean supportGif = call.argument("gif");
        HashMap<String, Object> cropOption = call.argument("cropOption");

        int chooseType;
        switch (pickType) {
          case "PickType.video":
            chooseType = PictureMimeType.ofVideo();
            break;
          case "PickType.all":
            chooseType = PictureMimeType.ofAll();
            break;
          default:
            chooseType = PictureMimeType.ofImage();
            break;
        }
        PictureSelectionModel model = PictureSelector.create(activity)
                .openGallery(chooseType);
        Utils.setPhotoSelectOpt(model, count, quality);
        if (cropOption!=null) Utils.setCropOpt(model, cropOption);
        model.isGif(supportGif);
        resolveMedias(model);
        break;
      }
      case "openCamera": {
        String pickType = call.argument("pickType");
        int maxTime = call.argument("maxTime");
        double quality = call.argument("quality");
        HashMap<String, Object> cropOption = call.argument("cropOption");
        PictureSelectionModel model = PictureSelector.create(activity)
                .openCamera(pickType.equals("PickType.video") ? PictureMimeType.ofVideo() : PictureMimeType.ofImage());
        model.setOutputCameraPath(context.getCacheDir().getAbsolutePath());
        model.recordVideoSecond(maxTime);
        Utils.setPhotoSelectOpt(model, 1, quality);
        if (cropOption!=null) Utils.setCropOpt(model, cropOption);
        resolveMedias(model);
        break;
      }
      default:
        result.notImplemented();
        break;
    }
  }

  private void resolveMedias(PictureSelectionModel model) {
    model.forResult(new OnResultCallbackListener<LocalMedia>() {
      @Override
      public void onResult(List<LocalMedia> medias) {
        // 结果回调
        List<Object> resArr = new ArrayList<Object>();
        for (LocalMedia media:medias) {
          Log.i("media mimeType", media.getMimeType());
          HashMap<String, Object> map = new HashMap<String, Object>();
          String path = media.getPath();
          if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            path = media.getAndroidQToPath();
          }
          if (media.isCut()) path = media.getCutPath();
          if (media.isCompressed()) path = media.getCompressPath();
          path = copyToTmp(path);
          map.put("path", path);

          String thumbPath;
          if (media.getMimeType().contains("image")) {
            thumbPath = path;
          } else {
            thumbPath = createVideoThumb(path);
          }
          map.put("thumbPath", thumbPath);

          int size = getFileSize(path);
          map.put("size", size);

          resArr.add(map);
        }

//          PictureFileUtils.deleteCacheDirFile(context, type);
        PictureFileUtils.deleteAllCacheDirFile(context);

        _result.success(resArr);
      }
      @Override
      public void onCancel() {
        // 取消
      }
    });
  }

  private String createVideoThumb(String path) {
    Bitmap bitmap = ThumbnailUtils.createVideoThumbnail(path, MediaStore.Video.Thumbnails.FULL_SCREEN_KIND);
    ByteArrayOutputStream bytes = new ByteArrayOutputStream();
    bitmap.compress(Bitmap.CompressFormat.JPEG, 100, bytes);
    try {
      File outputDir = context.getCacheDir();
      File outputFile = File.createTempFile("image_picker_"+ UUID.randomUUID().toString(), ".jpg", outputDir);
      FileOutputStream fo = new FileOutputStream(outputFile);
      fo.write(bytes.toByteArray());
      fo.close();
      return outputFile.getAbsolutePath();
    } catch (IOException e) {
      e.printStackTrace();
    }
    return "";
  }

  private int getFileSize(String path) {
    File file = new File(path);
    int size = Integer.parseInt(String.valueOf(file.length()));
    return size;
  }

  private String copyToTmp(String originPath) {
    String resPath = originPath;
    String suffix = originPath.substring(originPath.lastIndexOf('.'));
    File from = new File(originPath);
    File to;
    try {
      File outputDir = context.getCacheDir();
      to = File.createTempFile("image_picker_"+ UUID.randomUUID().toString(), suffix, outputDir);

      try {
        InputStream in = new FileInputStream(from);
        OutputStream out = new FileOutputStream(to);
        byte[] buf = new byte[1024];
        try {
          int len;
          while ((len = in.read(buf)) > 0) {
            out.write(buf, 0, len);
          }
          resPath = to.getAbsolutePath();
        } catch (IOException e) {
          Log.w("image_picker", e.getLocalizedMessage());
        }
      } catch (FileNotFoundException e) {
        Log.w("image_picker", e.getLocalizedMessage());
      }
    } catch (IOException e) {
      Log.w("image_picker", e.getLocalizedMessage());
    }
    return resPath;
  }
}
