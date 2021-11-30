package com.chavesgu.images_picker;

import android.content.pm.ActivityInfo;

import com.luck.picture.lib.PictureSelectionModel;
import com.luck.picture.lib.PictureSelector;
import com.luck.picture.lib.config.PictureConfig;
import com.luck.picture.lib.config.PictureMimeType;
import com.luck.picture.lib.language.LanguageConfig;
import com.yalantis.ucrop.view.OverlayView;

import java.lang.reflect.Array;
import java.util.HashMap;
import java.util.List;
import java.util.UUID;

public class Utils {
    public static PictureSelectionModel setPhotoSelectOpt(PictureSelectionModel model, int count, double quality) {
        model
                .imageEngine(GlideEngine.createGlideEngine())
                .maxSelectNum(count)
                .minSelectNum(1)
                .maxVideoSelectNum(count)
                .minVideoSelectNum(1)
                .selectionMode(count > 1 ? PictureConfig.MULTIPLE : PictureConfig.SINGLE)
                .isSingleDirectReturn(false)
                .isWeChatStyle(true)
                .isCamera(false)
                .isZoomAnim(true)
                .isGif(true)
                .isEnableCrop(false)
                .isCompress(false)
                .minimumCompressSize(100)
                .isReturnEmpty(false)
                .isAndroidQTransform(true)
                .setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT)
                .isOriginalImageControl(false)
                .isMaxSelectEnabledMask(true)
                .setCameraImageFormat(PictureMimeType.JPEG)
                .setCameraVideoFormat(PictureMimeType.MP4)
                .renameCompressFile("image_picker_compress_"+UUID.randomUUID().toString()+".jpg")
                .renameCropFileName("image_picker_crop_"+UUID.randomUUID().toString()+".jpg")
//                .cameraFileName("image_picker_camera_"+UUID.randomUUID().toString()+".jpg")
        ;
        if (quality > 0) {
            model.isCompress(true).compressQuality((int) ((double) quality * 100));
        }
        return model;
    }

    public static PictureSelectionModel setCropOpt(PictureSelectionModel model, HashMap<String, Object> opt) {
        model
                .isEnableCrop(true)
                .freeStyleCropMode(OverlayView.FREESTYLE_CROP_MODE_ENABLE)
                .circleDimmedLayer(opt.get("cropType").equals("CropType.circle"))
                .showCropFrame(!opt.get("cropType").equals("CropType.circle"))
                .showCropGrid(false)
                .rotateEnabled(true)
                .scaleEnabled(true)
                .isDragFrame(true)
                .hideBottomControls(false)
                .isMultipleSkipCrop(true)
                .cutOutQuality((int) ((double) opt.get("quality") * 100));
        if (opt.get("aspectRatioX") != null) {
            model.isDragFrame(false);
            model.withAspectRatio((int) opt.get("aspectRatioX"), (int) opt.get("aspectRatioY"));
        }
        return model;
    }

    public static PictureSelectionModel setLanguage(PictureSelectionModel model, String language) {
        switch (language) {
            case "Language.Chinese":
                model.setLanguage(LanguageConfig.CHINESE);
                break;
            case "Language.ChineseTraditional":
                model.setLanguage(LanguageConfig.TRADITIONAL_CHINESE);
                break;
            case "Language.English":
                model.setLanguage(LanguageConfig.ENGLISH);
                break;
            case "Language.Japanese":
                model.setLanguage(LanguageConfig.JAPAN);
                break;
            case "Language.French":
                model.setLanguage(LanguageConfig.FRANCE);
                break;
            case "Language.Korean":
                model.setLanguage(LanguageConfig.KOREA);
                break;
            case "Language.German":
                model.setLanguage(LanguageConfig.GERMANY);
                break;
            case "Language.Vietnamese":
                model.setLanguage(LanguageConfig.VIETNAM);
                break;
            default:
                model.setLanguage(-1);
        }
        return model;
    }
}
