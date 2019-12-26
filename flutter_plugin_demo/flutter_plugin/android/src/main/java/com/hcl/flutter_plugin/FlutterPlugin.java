package com.hcl.flutter_plugin;

import android.util.Log;
import android.widget.Toast;

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


}
