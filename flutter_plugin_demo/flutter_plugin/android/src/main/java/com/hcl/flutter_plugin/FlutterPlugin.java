package com.hcl.flutter_plugin;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.util.Log;
import android.widget.Toast;

import androidx.core.content.FileProvider;

import java.io.File;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** FlutterPlugin */
public class FlutterPlugin implements MethodCallHandler {

  private static final String TAG = FlutterPlugin.class.getSimpleName();


  private final Registrar registrar;

  //构造
  private FlutterPlugin(Registrar registrar) {
    this.registrar = registrar;
  }


  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_plugin");
    channel.setMethodCallHandler(new FlutterPlugin(registrar));
  }


  //来自Flutter的方法调用
  @Override
  public void onMethodCall(MethodCall call, Result result) {

    String target = call.method;
    switch (target) {
      case "getPlatformVersion":
        result.success("Android " + android.os.Build.VERSION.RELEASE);
        break;
      case "toast":
        String content = (String) call.arguments;
        Log.d(TAG, "toast: " + content);
        showToast(content);
        break;

      case "installApk":
        String path = (String) call.arguments;
        Log.d(TAG, "install" + path);
        File file = new File(path);
        installApk(file, registrar.context());
        break;
      default:
        result.notImplemented();
        break;
    }

  }




  /**
   * 显示Toast
   *
   * @param content
   */
  private void showToast(String content) {
    Toast.makeText(registrar.context(), content, Toast.LENGTH_SHORT).show();
  }


  /**
   * 安装APK
   *
   * @param apk
   * @param context
   */
  private boolean installApk(File apk, Context context) {
    Intent installApkIntent = new Intent();
    installApkIntent.setAction(Intent.ACTION_VIEW);
    installApkIntent.addCategory(Intent.CATEGORY_DEFAULT);
    installApkIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);

    Uri uri = null;
    if (Build.VERSION.SDK_INT > Build.VERSION_CODES.M) {
      uri = FileProvider.getUriForFile(context, context.getPackageName() + ".fileprovider", apk);
      installApkIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
    } else {
      uri = Uri.fromFile(apk);
    }
    installApkIntent.setDataAndType(uri, "application/vnd.android.package-archive");

    if (context.getPackageManager().queryIntentActivities(installApkIntent, 0).size() > 0) {
      context.startActivity(installApkIntent);
    }
    return true;

  }


}
