package com.chavesgu.images_picker;

import android.content.ContentResolver;
import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Environment;
import android.os.ParcelFileDescriptor;
import android.provider.MediaStore;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import androidx.annotation.Nullable;
import androidx.annotation.NonNull;

import static java.io.File.separator;

public class FileSaver {
    static boolean saveVideo(@NonNull Context context, String filePath, @Nullable  String albumName) {
        boolean saveRes = false;
        String folderName = context.getApplicationInfo().loadLabel(context.getPackageManager()).toString();
        if (albumName!=null) folderName = albumName;
        ContentValues values = new ContentValues();
        values.put(MediaStore.Video.Media.MIME_TYPE, "video/mp4");
        values.put(MediaStore.Video.Media.DATE_ADDED, System.currentTimeMillis() / 1000);
        if (android.os.Build.VERSION.SDK_INT >= 29) {
            values.put(MediaStore.Video.Media.DATE_TAKEN, System.currentTimeMillis());
            values.put(MediaStore.Video.Media.RELATIVE_PATH, "Movies/" + folderName);
            values.put(MediaStore.Video.Media.IS_PENDING, true);
            Uri uri = context.getContentResolver().insert(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, values);
            ParcelFileDescriptor pfd = null;
            try {
                pfd = context.getContentResolver().openFileDescriptor(uri, "w");
                OutputStream out = new FileOutputStream(pfd.getFileDescriptor());
                saveRes = saveVideoToStream(context, filePath, out);
            } catch (FileNotFoundException e) {
                e.printStackTrace();
            }
            values.clear();
            values.put(MediaStore.Video.Media.IS_PENDING, false);
            context.getContentResolver().update(uri, values, null, null);
        } else {
            File directory = new File(Environment.getExternalStorageDirectory().toString() + separator + folderName);
            if (!directory.exists()) {
                directory.mkdirs();
            }
            String fileName = String.valueOf(System.currentTimeMillis()) + ".mp4";
            File file = new File(directory, fileName);
            try {
                OutputStream out = new FileOutputStream(file);
                saveRes = saveVideoToStream(context, filePath, out);
                Uri tmpUri = Uri.fromFile(file);
                context.sendBroadcast(new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, tmpUri));
            } catch (FileNotFoundException e) {
                e.printStackTrace();
            }
            if (file.getAbsolutePath() != null) {
                values.put(MediaStore.Video.Media.DATA, file.getAbsolutePath());
                // .DATA is deprecated in API 29
                context.getContentResolver().insert(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, values);
            }
        }
        return saveRes;
    }

    static boolean saveImage(@NonNull Context context, Bitmap bitmap,String suffix, @Nullable String albumName) {
        boolean saveRes = false;
        String folderName = context.getApplicationInfo().loadLabel(context.getPackageManager()).toString();
        if (albumName!=null) folderName = albumName;
        if (android.os.Build.VERSION.SDK_INT >= 29) {
            ContentValues values = contentValues(suffix);
            values.put(MediaStore.Images.Media.DATE_TAKEN, System.currentTimeMillis());
            values.put(MediaStore.Images.Media.RELATIVE_PATH, "Pictures/" + folderName);
            values.put(MediaStore.Images.Media.IS_PENDING, true);
            // RELATIVE_PATH and IS_PENDING are introduced in API 29.
            Uri uri = context.getContentResolver().insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values);
            if (uri != null) {
                try {
                    saveRes = saveImageToStream(bitmap, context.getContentResolver().openOutputStream(uri));
//                    context.sendBroadcast(new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, uri));
                } catch (FileNotFoundException e) {
                    e.printStackTrace();
                }
                values.put(MediaStore.Images.Media.IS_PENDING, false);
                context.getContentResolver().update(uri, values, null, null);
            }
        } else {
            File directory = new File(Environment.getExternalStorageDirectory().toString() + separator + folderName);
            // getExternalStorageDirectory is deprecated in API 29
            if (!directory.exists()) {
                directory.mkdirs();
            }
            String fileName = String.valueOf(System.currentTimeMillis()) + "."+suffix;
            File file = new File(directory, fileName);
            try {
                saveRes = saveImageToStream(bitmap, new FileOutputStream(file));
                Uri tmpUri = Uri.fromFile(file);
                context.sendBroadcast(new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, tmpUri));
            } catch (FileNotFoundException e) {
                e.printStackTrace();
            }
            if (file.getAbsolutePath() != null) {
                ContentValues values = contentValues(suffix);
                values.put(MediaStore.Images.Media.DATA, file.getAbsolutePath());
                // .DATA is deprecated in API 29
                context.getContentResolver().insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values);
            }
        }
        return saveRes;
    }

    static ContentValues contentValues(@NonNull String suffix){
        ContentValues values = new ContentValues();
        String type = "image/"+suffix;
        if (suffix.equals("jpg") || suffix.equals("jpeg")) {
            type = "image/jpeg";
        }
        values.put(MediaStore.Images.Media.MIME_TYPE, type);
        values.put(MediaStore.Images.Media.DATE_ADDED, System.currentTimeMillis() / 1000);
        return values;
    }

    static Boolean saveVideoToStream(@NonNull Context context, String filePath, OutputStream out) {
        try {
            File videoFile = new File(filePath);
            InputStream in = new FileInputStream(videoFile);
            byte[] buf = new byte[8192];
            try {
                while (true) {
                    int sz = in.read(buf);
                    if (sz <= 0)break;
                    out.write(buf, 0, sz);
                }
                return true;
            } catch (IOException e) {
                e.printStackTrace();
                return false;
            }
        } catch (FileNotFoundException e) {
            e.printStackTrace();
            return false;
        }
    }

    static boolean saveImageToStream(Bitmap bitmap, OutputStream outputStream) {
        if (outputStream != null) {
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream);
            try {
                outputStream.close();
                return true;
            } catch (IOException e) {
                e.printStackTrace();
                return false;
            }
        }
        return false;
    }
}
