import 'dart:async';

import 'package:flutter/services.dart';

class FlutterPlugin {

  //除了 MethodChannel 还有其他交互方式
  static const MethodChannel _channel =
      const MethodChannel('flutter_plugin');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  /**
   * 显示Toast
   */
  static Future<void> showToast(String content)async {
    await _channel.invokeMethod("toast",content);
  }


  /**
   * 安装Apk
   */
  static Future<bool> installApk(String path) async{
    return await _channel.invokeMethod("installApk",path);
  }
}
