import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mood_classifer/api/api.dart';
import 'package:mood_classifer/main.dart';
import 'package:mood_classifer/models/PredictModel.dart';
import 'package:mood_classifer/utils/file-utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../constants.dart';
import 'componenets/my_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final record = Record();

  // Permissions
  bool has_storage_perm = false;
  bool has_audio_perm = false;

  // Recording
  late Timer _timer;
  int _recordRemainDuration = 16;
  bool _isRecording = false;
  bool _hasFile = false;
  String filename = "";

  // Upload
  bool _uploadLoading = false;
  bool _hasUploaded = false;
  bool _isActionsDisabled = false;
  bool _uploadResIsError = false;
  String _uploadRes = '';

  //preprocess
  bool _processLoading = false;
  bool _hasProcessed = false;
  bool _processResIsError = false;
  String _processRes = '';

  //predict
  bool _predictLoading = false;
  bool _haspredicted = false;
  bool _predictResIsError = false;
  String _predictRes = '';

  //result
  bool _resultLoading = false;
  bool _resultResIsError = false;
  String _resultRes = '';
  List<PredictModel> _predictedModels = [];
  List<Widget> _predictecdWidget = [];

  _requestAudioPermission() async {
    if (Platform.isAndroid) {
      var result_storage = await Permission.storage.request();
      var result_audio = await record.hasPermission();
      if (result_storage != PermissionStatus.granted)
        MyApp.showSnackBar(context,
            content: "دسترسی فایل داده نشده", isError: true);
      else
        has_storage_perm = true;
      if (result_audio != true)
        MyApp.showSnackBar(context,
            content: "دسترسی ضبط صدا داده نشده", isError: true);
      else
        has_audio_perm = true;
    }
  }

  _startRecording() async {
    try {
      await FileUtils.deleteFolderItems(Constants.SAVE_AUDIO_PATH);
      DateTime now = DateTime.now();
      String now_str = now
          .toString()
          .replaceAll(" ", "_")
          .replaceAll(':', "_")
          .replaceAll('-', '_') .replaceAll('.', '_');

    filename = 'raw_data_' + now_str + '.wav';

    setState(() {
    _isRecording = true;
    _hasFile = false;
    _hasUploaded = false;
    _uploadRes = '';
    _uploadResIsError = false;

    _processLoading = false;
    _hasProcessed = false;
    _processResIsError = false;
    _processRes = '';
    _predictLoading = false;
    _haspredicted = false;
    _predictResIsError = false;
    _predictRes = '';
    _resultLoading = false;
    _resultResIsError = false;
    _resultRes = '';
    _predictedModels = [];
    _predictecdWidget = [];
    });
    await record.start(
    path: Constants.SAVE_AUDIO_PATH_FOLDER + filename,
    encoder: AudioEncoder.wav, // by default
    bitRate: 128000, // by default
    samplingRate: 44100, // by default
    );
    startTimer();
    } catch (e) {
    _stopRecording();
    }
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
          (Timer timer) {
        if (_recordRemainDuration == 0) {
          setState(() {
            timer.cancel();
            _stopRecording();
            _recordRemainDuration = 16;
          });
        } else {
          setState(() {
            _recordRemainDuration--;
          });
        }
      },
    );
  }

  _stopRecording() async {
    try {
      await record.stop();
      setState(() {
        _isRecording = false;
        _hasFile = true;
      });
    } catch (e) {
      setState(() {
        _isRecording = false;
        _hasFile = true;
      });
    }
  }

  @override
  void initState() {
    _requestAudioPermission();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery
        .of(context)
        .size
        .width;
    double height = MediaQuery
        .of(context)
        .size
        .height;
    return Scaffold(
      backgroundColor: Constants.COLOR_MAIN_DARK,
      body: Container(
          height: height,
          padding: EdgeInsets.only(top: Constants.SAFE_AREA_PADDING),
          width: width,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: height / 20),
                  child: Container(
                      width: width * 8 / 10,
                      child: const Text(
                        'مرحله 1',
                        style: Constants.TEXT_STYLE_WHITE_MEDIUM_BOLD,
                      )),
                ),
                Padding(
                  padding: EdgeInsets.only(top: height / 80),
                  child: Container(
                      width: width * 8 / 10,
                      child: const Text(
                        'ابتدا صدا را ضبط کنید ( بین 6 تا 16 ثانیه )',
                        style: Constants.TEXT_STYLE_WHITE_SMALL,
                      )),
                ),
                Padding(
                  padding: EdgeInsets.only(top: height / 80),
                  child: MyButton(
                      callBack: () {
                        if (!_isActionsDisabled) {
                          if (_isRecording) {
                            if (16 - _recordRemainDuration <= 6) {
                              MyApp.showSnackBar(context,
                                  content: "حداقل 6.1 ثانیه صبر کنید",
                                  isError: true);
                            } else {
                              _recordRemainDuration = 16;
                              _timer.cancel();
                              _stopRecording();
                            }
                          } else {
                            if (has_storage_perm && has_audio_perm) {
                              _startRecording();
                            } else {
                              _requestAudioPermission();
                            }
                          }
                        } else {
                          MyApp.showSnackBar(context,
                              content:
                              "ضبط در هنگام فعایتهای دیگر غیر فعال است",
                              isError: true);
                        }
                      },
                      buttonText: _isRecording ? 'اتمام ضبط' : 'ضبط صدا',
                      width: width * 8 / 10,
                      buttonColor: Constants.COLOR_WHITE_MAIN,
                      overlayColor:
                      Constants.COLOR_BUTTON_OVERLAY.withOpacity(0.5),
                      buttonTextStyle: Constants.TEXT_STYLE_BLACK_MEDIUM_BOLD),
                ),
                Padding(
                  padding: EdgeInsets.only(top: height / 80),
                  child: Container(
                      width: width * 8 / 10,
                      child: Text(
                        'زمان باقی مانده : $_recordRemainDuration',
                        style: Constants.TEXT_STYLE_WHITE_SMALL,
                      )),
                ),
                Padding(
                  padding: EdgeInsets.only(top: height / 80),
                  child: Container(
                      width: width * 8 / 10,
                      child: Text(
                        'نام فایل : $filename',
                        style: Constants.TEXT_STYLE_WHITE_SMALL,
                      )),
                ),
                Padding(
                  padding: EdgeInsets.only(top: height / 40),
                  child: _divider(height, width),
                ),
                _hasFile && !_isRecording
                    ? Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: height / 20),
                      child: Container(
                          width: width * 8 / 10,
                          child: const Text(
                            'مرحله 2',
                            style: Constants.TEXT_STYLE_WHITE_MEDIUM_BOLD,
                          )),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: height / 80),
                      child: Container(
                          width: width * 8 / 10,
                          child: const Text(
                            'سپس دکمه آپلود را زده و منتظر بمانید',
                            style: Constants.TEXT_STYLE_WHITE_SMALL,
                          )),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: height / 80),
                      child: MyButton(
                          callBack: () {
                            if (!_isActionsDisabled) {
                              _uploadAudio();
                            } else {
                              MyApp.showSnackBar(context,
                                  content:
                                  "آپلود در هنگام فعایتهای دیگر غیر فعال است",
                                  isError: true);
                            }
                          },
                          buttonText: 'آپلود فایل',
                          width: width * 8 / 10,
                          indicatorColor: Constants.COLOR_MAIN_DARK,
                          buttonColor: Constants.COLOR_WHITE_MAIN,
                          isLoading: _uploadLoading,
                          overlayColor: Constants.COLOR_BUTTON_OVERLAY
                              .withOpacity(0.5),
                          buttonTextStyle:
                          Constants.TEXT_STYLE_BLACK_MEDIUM_BOLD),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: height / 80),
                      child: Container(
                          width: width * 8 / 10,
                          child: Text(
                            'جواب سرور : $_uploadRes',
                            style: _uploadResIsError
                                ? Constants.TEXT_STYLE_ERROR_SMALL
                                : Constants.TEXT_STYLE_WHITE_SMALL,
                          )),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: height / 40),
                      child: _divider(height, width),
                    ),
                  ],
                )
                    : Container(),
                _hasUploaded
                    ? Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: height / 20),
                      child: Container(
                          width: width * 8 / 10,
                          child: const Text(
                            'مرحله 3',
                            style: Constants.TEXT_STYLE_WHITE_MEDIUM_BOLD,
                          )),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: height / 80),
                      child: Container(
                          width: width * 8 / 10,
                          child: const Text(
                            'سپس دکمه پیش پردازش را زده و منتظر بمانید',
                            style: Constants.TEXT_STYLE_WHITE_SMALL,
                          )),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: height / 80),
                      child: MyButton(
                          callBack: () {
                            if (!_isActionsDisabled) {
                              _preprocessData();
                            } else {
                              MyApp.showSnackBar(context,
                                  content:
                                  "پیشپردازش در هنگام فعایتهای دیگر غیر فعال است",
                                  isError: true);
                            }
                          },
                          indicatorColor: Constants.COLOR_MAIN_DARK,
                          isLoading: _processLoading,
                          buttonText: 'پیشپردازش',
                          width: width * 8 / 10,
                          buttonColor: Constants.COLOR_WHITE_MAIN,
                          overlayColor: Constants.COLOR_BUTTON_OVERLAY
                              .withOpacity(0.5),
                          buttonTextStyle:
                          Constants.TEXT_STYLE_BLACK_MEDIUM_BOLD),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: height / 80),
                      child: Container(
                          width: width * 8 / 10,
                          child: Text(
                            'جواب سرور : $_processRes',
                            style: _processResIsError
                                ? Constants.TEXT_STYLE_ERROR_SMALL
                                : Constants.TEXT_STYLE_WHITE_SMALL,
                          )),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: height / 40),
                      child: _divider(height, width),
                    ),
                  ],
                )
                    : Container(),
                _hasProcessed
                    ? Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: height / 20),
                      child: Container(
                          width: width * 8 / 10,
                          child: const Text(
                            'مرحله 4',
                            style: Constants.TEXT_STYLE_WHITE_MEDIUM_BOLD,
                          )),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: height / 80),
                      child: Container(
                          width: width * 8 / 10,
                          child: const Text(
                            'سپس دکمه پیشبینی و طبقه بندی را زده و منتظر بمانید',
                            style: Constants.TEXT_STYLE_WHITE_SMALL,
                          )),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: height / 80),
                      child: MyButton(
                          callBack: () {
                            if (!_isActionsDisabled) {
                              _predictData();
                            } else {
                              MyApp.showSnackBar(context,
                                  content:
                                  "پیشبینی و طبقه بندی در هنگام فعایتهای دیگر غیر فعال است",
                                  isError: true);
                            }
                          },
                          indicatorColor: Constants.COLOR_MAIN_DARK,
                          isLoading: _predictLoading,
                          buttonText: 'پیشبینی و طبقه بندی',
                          width: width * 8 / 10,
                          buttonColor: Constants.COLOR_WHITE_MAIN,
                          overlayColor: Constants.COLOR_BUTTON_OVERLAY
                              .withOpacity(0.5),
                          buttonTextStyle:
                          Constants.TEXT_STYLE_BLACK_MEDIUM_BOLD),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: height / 80),
                      child: Container(
                          width: width * 8 / 10,
                          child: Text(
                            'جواب سرور : $_predictRes',
                            style: _predictResIsError
                                ? Constants.TEXT_STYLE_ERROR_SMALL
                                : Constants.TEXT_STYLE_WHITE_SMALL,
                          )),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: height / 40),
                      child: _divider(height, width),
                    ),
                  ],
                )
                    : Container(),
                _haspredicted
                    ? Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: height / 20),
                      child: Container(
                          width: width * 8 / 10,
                          child: const Text(
                            'مرحله 5',
                            style: Constants.TEXT_STYLE_WHITE_MEDIUM_BOLD,
                          )),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: height / 80),
                      child: Container(
                          width: width * 8 / 10,
                          child: const Text(
                            'در نهایت دکمه گزارش را فشار دهید',
                            style: Constants.TEXT_STYLE_WHITE_SMALL,
                          )),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: height / 80),
                      child: MyButton(
                          callBack: () {
                            _getResult(height, width);
                          },
                          indicatorColor: Constants.COLOR_MAIN_DARK,
                          isLoading: _resultLoading,
                          buttonText: 'مشاهده گزارش',
                          width: width * 8 / 10,
                          buttonColor: Constants.COLOR_WHITE_MAIN,
                          overlayColor: Constants.COLOR_BUTTON_OVERLAY
                              .withOpacity(0.5),
                          buttonTextStyle:
                          Constants.TEXT_STYLE_BLACK_MEDIUM_BOLD),
                    ),
                    _resultResIsError
                        ? Padding(
                      padding: EdgeInsets.only(top: height / 80),
                      child: Container(
                          width: width * 8 / 10,
                          child: Text(
                            'جواب سرور : $_resultRes',
                            style: _resultResIsError
                                ? Constants.TEXT_STYLE_ERROR_SMALL
                                : Constants.TEXT_STYLE_WHITE_SMALL,
                          )),
                    )
                        : Container(),
                    _predictedModels.length != 0
                        ? Padding(
                      padding: EdgeInsets.only(top: height / 20),
                      child: Column(
                        children: _predictecdWidget,
                      ),
                    )
                        : Container(),
                    Padding(
                      padding: EdgeInsets.only(top: height / 20),
                      child: Container(),
                    ),
                  ],
                )
                    : Container()
              ],
            ),
          )),
    );
  }

  _predictedItemWidget(PredictModel model, double height, double width) {
    return Padding(
      padding: EdgeInsets.only(bottom: height / 40),
      child: Container(
        width: width * 8 / 10,
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(
                'تاریخ',
                style: Constants.TEXT_STYLE_WHITE_MEDIUM_BOLD,
              ),
              Text(
                model.date,
                style: Constants.TEXT_STYLE_WHITE_SMALL,
              )
            ]),
            Padding(
              padding: EdgeInsets.only(top: height / 80),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'نام فایل',
                      style: Constants.TEXT_STYLE_WHITE_MEDIUM_BOLD,
                    ),
                    Text(
                      model.filename,
                      style: Constants.TEXT_STYLE_WHITE_SMALL,
                    )
                  ]),
            ),
            Padding(
              padding: EdgeInsets.only(top: height / 80),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'مود',
                      style: Constants.TEXT_STYLE_WHITE_MEDIUM_BOLD,
                    ),
                    Text(
                      model.mood,
                      style: model.mood == "neutral" ? Constants
                          .TEXT_STYLE_WHITE_SMALL_BOLD : model.mood ==
                          "positive"
                          ? Constants.TEXT_STYLE_GREEN_MOOD_SMALL
                          : Constants.TEXT_STYLE_BLUE_MOOD_SMALL,
                    )
                  ]),
            ),
            Padding(
              padding: EdgeInsets.only(top: height / 80),
              child: Container(
                height: 0.5,
                width: width * 8 / 10,
                decoration: BoxDecoration(
                  color: Constants.COLOR_WHITE_MAIN,
                  borderRadius: BorderRadius.circular(
                      Constants.TEXT_INPUT_ROUNDNESS),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _uploadAudio() async {
    setState(() {
      _uploadLoading = true;
      _isActionsDisabled = true;
      _hasUploaded = false;
      _uploadResIsError = false;
    });
    if (filename == '') {
      MyApp.showSnackBar(context, content: "فایلی یافت نشد", isError: true);
      return;
    }
    var response = await API.Instance!.upload_post(
        "model-controller/upload-audio",
        Constants.SAVE_AUDIO_PATH_FOLDER + filename);
    if (response.isFailed) {
      setState(() {
        _uploadLoading = false;
        _uploadRes = response.error!;
        _isActionsDisabled = false;
        _uploadResIsError = true;
      });
      return;
    }
    setState(() {
      _isActionsDisabled = false;
      _uploadLoading = false;
      _hasUploaded = true;
      _uploadRes = response.data;
    });
  }

  _preprocessData() async {
    setState(() {
      _processLoading = true;
      _isActionsDisabled = true;
      _hasProcessed = false;
      _processResIsError = false;
    });

    var response =
    await API.Instance!.post("model-controller/process-raw-data", {});
    if (response.isFailed) {
      setState(() {
        _processLoading = false;
        _processRes = response.error!;
        _isActionsDisabled = false;
        _processResIsError = true;
      });
      return;
    }
    setState(() {
      _processLoading = false;
      _hasProcessed = true;
      _isActionsDisabled = false;
      _processRes = response.data;
    });
  }

  _predictData() async {
    setState(() {
      _predictLoading = true;
      _isActionsDisabled = true;
      _haspredicted = false;
      _predictResIsError = false;
    });

    var response = await API.Instance!.post("model-controller/predict-items",
        {"result_number": 1, "delete_data": "True"});
    if (response.isFailed) {
      setState(() {
        _predictLoading = false;
        _predictRes = response.error!;
        _isActionsDisabled = false;
        _predictResIsError = true;
      });
      return;
    }
    if (response.data != '' && response.data.toString().contains('error')) {
      setState(() {
        _predictLoading = false;
        _predictRes = response.data;
        _isActionsDisabled = false;
        _predictResIsError = true;
      });
      return;
    }
    setState(() {
      _predictLoading = false;
      _haspredicted = true;
      _isActionsDisabled = false;
      _predictRes = response.data;
    });
  }

  _getResult(double height, double width) async {
    setState(() {
      _predictedModels = [];
      _predictecdWidget = [];
      _resultLoading = true;
      _isActionsDisabled = true;
      _resultResIsError = false;
    });

    var response = await API.Instance!
        .post("model-controller/get_single_result", {"result_number": 1});
    if (response.isFailed) {
      setState(() {
        _resultLoading = false;
        _resultRes = response.error!;
        _isActionsDisabled = false;
        _resultResIsError = true;
      });
      return;
    }
    if (response.data != '' && response.data.toString().contains('problem')) {
      setState(() {
        _resultLoading = false;
        _resultRes = response.data.toString();
        _isActionsDisabled = false;
        _resultResIsError = true;
      });
      return;
    }
    for (var i = 0; i < response.data.length; i++) {
      _predictedModels.add(PredictModel.fromJson(response.data[i]));
    }
    setState(() {
      for (var i = 0; i < _predictedModels.length; i++) {
        _predictecdWidget.add(
            _predictedItemWidget(_predictedModels[i], height, width));
      }
      _resultLoading = false;
      _isActionsDisabled = false;
      _resultRes = response.data.toString();
    });
  }

  //  void _getModelStatusAPI() async {
  //     var response = await API.Instance!.get("/model-controller/model-status");
  //     if (response.isFailed) {
  //       setState(() {
  //         _loading = false;
  //         _error = Constants.SERVER_ERROR;
  //       });
  //       return;
  //     }
  //     if (response.error != "") {
  //       setState(() {
  //         _loading = false;
  //         _error = Constants.MODEL_ERROR;
  //       });
  //       return;
  //     }
  //     setState(() {
  //       _loading = false;
  //       _error = '';
  //     });
  //     Future.delayed(const Duration(milliseconds: 1500), () {
  //       MyApp.gotoPageWithoutBack(context, Routes.HOME);
  //     });
  //   }
  _divider(double height, double width) {
    return Container(
      height: 0.75,
      width: width * 8 / 10,
      decoration: BoxDecoration(
        color: Constants.COLOR_WHITE_MAIN,
        borderRadius: BorderRadius.circular(Constants.TEXT_INPUT_ROUNDNESS),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
