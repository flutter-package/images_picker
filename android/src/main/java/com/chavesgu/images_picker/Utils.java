package com.chavesgu.images_picker;

import android.content.pm.ActivityInfo;

import com.luck.picture.lib.PictureSelectionModel;
import com.luck.picture.lib.PictureSelector;
import com.luck.picture.lib.config.PictureConfig;

import java.lang.reflect.Array;
import java.util.HashMap;
import java.util.List;

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
                .isCompress(true)
                .compressFocusAlpha(true)
                .minimumCompressSize(100)
                .compressQuality((int) ((double) quality * 100))
                .isReturnEmpty(false)
                .isAndroidQTransform(true)
                .setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT)
                .isOriginalImageControl(true)
                .isMaxSelectEnabledMask(true);
        if (quality < 0) model.isCompress(false);
        return model;
    }

    public static PictureSelectionModel setCropOpt(PictureSelectionModel model, HashMap<String, Object> opt) {
        model
                .isEnableCrop(true)
                .freeStyleCropEnabled(true)
                .circleDimmedLayer(opt.get("cropType").equals("CropType.circle"))
                .showCropFrame(!opt.get("cropType").equals("CropType.circle"))
                .showCropGrid(false)
                .rotateEnabled(true)
                .scaleEnabled(true)
                .isDragFrame(true)
                .hideBottomControls(false)
                .isMultipleSkipCrop(true)
                .compressFocusAlpha(true)
                .cutOutQuality(100);
        if (opt.get("aspectRatioX") != null) {
            model.isDragFrame(false);
            model.withAspectRatio((int) opt.get("aspectRatioX"), (int) opt.get("aspectRatioY"));
        }
        return model;
    }
}
