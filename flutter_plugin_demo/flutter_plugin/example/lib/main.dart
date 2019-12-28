import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_plugin/flutter_plugin.dart';
import 'package:path_provider/path_provider.dart';

import 'base_dialog.dart';

void main() => runApp(MyExampleApp());

class MyExampleApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyExampleApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: new HomeWidget(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            FlutterPlugin.showToast("Hello World");
          },
          child: Text("toast"),
        ),
      ),
    );
  }
}

class HomeWidget extends StatefulWidget {
  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  String _platformVersion = 'Unknown';

  StreamController<double> ctrl = new StreamController<double>.broadcast();

  String _apkPath = "";

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String platformVersion;

    try {
      platformVersion = await FlutterPlugin.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            height: 40,
            child: Text('Running on: $_platformVersion\n'),
          ),
          RaisedButton(
            onPressed: () async {
              if (!Platform.isAndroid) {
                FlutterPlugin.showToast("暂未实现install功能");
                return;
              }

              onDownLoadFile((path) {
                _apkPath = path;
              });

              //显示Dialog
              showDialog(
                  barrierDismissible: true,
                  context: context,
                  builder: (BuildContext context) {
                    return BaseDialog(
                        Center(
                          child: SizedBox(
                            height: 250,
                            width: 250,
                            child: Column(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(top: 20, bottom: 30),
                                  child: Text(
                                    "下载更新",
                                    style: TextStyle(
                                        letterSpacing: 5,
                                        fontSize: 20,
                                        color: Theme.of(context).primaryColor),
                                  ),
                                ),
                                StreamBuilder(
                                  builder: (BuildContext context,
                                      AsyncSnapshot<double> shot) {
                                    if (shot.hasData) {
                                      if (shot.data >= 1) {
                                        Future.delayed(
                                                Duration(milliseconds: 400))
                                            .then((value) {
                                          Navigator.of(context).pop(this);
                                        });

                                        //安装
                                        if (_apkPath.isNotEmpty) {
                                          FlutterPlugin.installApk(_apkPath);
                                        }
                                      }
                                      return Stack(
                                        alignment: Alignment.center,
                                        children: <Widget>[
                                          SizedBox(
                                            height: 120,
                                            width: 120,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              backgroundColor: Colors.grey[300],
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                      Colors.blue),
                                              value: shot.data,
                                            ),
                                          ),
                                          Text(
                                            (shot.data * 100)
                                                    .toStringAsFixed(0) +
                                                "%",
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Theme.of(context)
                                                    .primaryColor),
                                          ),
                                        ],
                                      );
                                    } else {
                                      return Container();
                                    }
                                  },
                                  initialData: 0.0,
                                  stream: ctrl.stream,
                                ),
                              ],
                            ),
                          ),
                        ),
                        250,
                        250);
                  });
            },
            child: Text("download"),
          )
        ],
      ),
    );
  }

  //文件下载
  void onDownLoadFile(ValueChanged<String> callBack) async {
    String downloadURL = "http://xz.tcyl77.com/633207/apk/douyinand51.apk";

    String fileName = "update.apk";

    Directory directory = await getExternalStorageDirectory();

    String downloadDic = directory.path + "/download/";

    String downloadPath = downloadDic + fileName;
    if (null != callBack) callBack(downloadPath); //把地址回调回去

    Dio dio = new Dio();
    File filePr = File(downloadPath);
    var isPrExist = await filePr.exists();
    if (isPrExist) {
      await filePr.delete(); // 删除之前没有下载完成的文件
    }
    // 必须加上 否则download 报 can not open file
    File file = new File(downloadPath);
    file.create(recursive: true);
    Response response = await dio.download(downloadURL, downloadPath,
        onReceiveProgress: (received, total) {
      if (total != -1) {
        print((received / total * 100).toStringAsFixed(0) + "%");
        if (!ctrl.isClosed) ctrl.sink.add(received / total);
      }
    }).catchError((error) {
      print(error.toString());
    });
    print(response.statusMessage.toString());
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    ctrl?.close();
  }
}
