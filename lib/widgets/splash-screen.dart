import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:mood_classifer/api/api.dart';
import 'package:mood_classifer/main.dart';
import 'package:mood_classifer/routs.dart';
import 'package:mood_classifer/utils/file-utils.dart';
import 'package:mood_classifer/widgets/componenets/my_button.dart';

import '../constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    _boot();
    super.initState();
  }

  String _error = '';
  bool _loading = true;

  @override
  Widget build(BuildContext context) {
    Constants.SAFE_AREA_PADDING = MediaQuery.of(context).padding.top;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
          height: height,
          width: width,
          color: Constants.COLOR_MAIN_DARK,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: height / 2),
                      child: Text(
                        "تشخیص مود راننده",
                        style: Constants.TEXT_STYLE_WHITE_TITLE_BOLD,
                      ),
                    ),
                    Column(
                      children: [
                        _error != ''
                            ? Padding(
                                padding: EdgeInsets.only(bottom: height / 40),
                                child: Text(
                                  _error,
                                  style: Constants.TEXT_STYLE_ERROR_MEDIUM,
                                ),
                              )
                            : Container(),
                        Padding(
                          padding: EdgeInsets.only(bottom: height / 40),
                          child: _error != '' && !_loading
                              ? MyButton(
                                  callBack: () {
                                    _boot();
                                  },
                                  buttonText: "تلاش مجدد",
                                  width: width * 8 / 10,
                                  buttonColor: Constants.COLOR_WHITE_MAIN,
                                  overlayColor: Constants.COLOR_BUTTON_OVERLAY
                                      .withOpacity(0.5),
                                  buttonTextStyle:
                                      Constants.TEXT_STYLE_BLACK_MEDIUM_BOLD)
                              : Container(
                                  height: width / 6,
                                  width: width / 6,
                                  child: const LoadingIndicator(
                                    indicatorType: Indicator.pacman,
                                    colors: [
                                      Constants.COLOR_WHITE_MAIN,
                                    ],
                                    strokeWidth: 2,
                                    backgroundColor: Constants.COLOR_MAIN_DARK,
                                    pathBackgroundColor:
                                        Constants.COLOR_MAIN_DARK,
                                  ),
                                ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Align(

                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(top: Constants.SAFE_AREA_PADDING+height/80),
                  child: Image.asset(
                    Constants.NORC_IMAGE,
                    width: width * 1 / 4,
                    height: width * 1 / 4,
                  ),
                ),
              )
            ],
          )),
    );
  }

  void _getModelStatusAPI() async {
    var response = await API.Instance!.get("/model-controller/model-status");
    if (response.isFailed) {
      setState(() {
        _loading = false;
        _error = Constants.SERVER_ERROR;
      });
      return;
    }
    if (response.error != "") {
      setState(() {
        _loading = false;
        _error = Constants.MODEL_ERROR;
      });
      return;
    }
    setState(() {
      _loading = false;
      _error = '';
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      MyApp.gotoPageWithoutBack(context, Routes.HOME);
    });
  }

  _boot() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    var connectivityResult = await (Connectivity().checkConnectivity());
    String folder =
        await FileUtils.createFolderInAppDocDir(Constants.SAVE_AUDIO_PATH);
    Constants.SAVE_AUDIO_PATH_FOLDER = folder;
    FileUtils.deleteFolderItems(Constants.SAVE_AUDIO_PATH);
    if (!(connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi)) {
      setState(() {
        _loading = false;
        _error = Constants.CONNECTION_ERROR;
      });

      return;
    }
    _getModelStatusAPI();
  }
}
