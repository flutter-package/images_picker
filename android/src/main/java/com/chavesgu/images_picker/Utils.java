package com.chavesgu.images_picker;

import android.content.pm.ActivityInfo;

import com.luck.picture.lib.PictureSelectionModel;
import com.luck.picture.lib.PictureSelector;
import com.luck.picture.lib.config.PictureConfig;

import java.util.HashMap;

public class Utils {
    public static PictureSelectionModel setPhotoSelectOpt(PictureSelectionModel model, int count) {
        return model
                .imageEngine(GlideEngine.createGlideEngine())
                .maxSelectNum(count)
                .minSelectNum(1)
                .maxVideoSelectNum(count)
                .minVideoSelectNum(1)
                .selectionMode(count > 1 ? PictureConfig.MULTIPLE : PictureConfig.SINGLE)
                .isSingleDirectReturn(false)
                .isWeChatStyle(true)
                .isCamera(false)
                .isGif(false)
                .isEnableCrop(false)
                .isCompress(true)
                .compressFocusAlpha(true)
                .minimumCompressSize(100)
                .isReturnEmpty(false)
                .isAndroidQTransform(true)
                .setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT)
                .isOriginalImageControl(true)
                .isMaxSelectEnabledMask(true);
    }

    public static PictureSelectionModel setCropOpt(PictureSelectionModel model, HashMap<String, Object> opt) {
        return model
                .isEnableCrop(true)
                .withAspectRatio((int) opt.get("aspectRatioX"), (int) opt.get("aspectRatioY"))
                .freeStyleCropEnabled(true)
                .circleDimmedLayer(opt.get("cropType").equals("CropType.circle"))
                .showCropFrame(!opt.get("cropType").equals("CropType.circle"))
                .showCropGrid(false)
                .rotateEnabled(true)
                .scaleEnabled(true)
                .isDragFrame(false)
                .hideBottomControls(false)
                .isMultipleSkipCrop(true)
                .cutOutQuality((int) ((double) opt.get("quality") * 100));
    }
}
