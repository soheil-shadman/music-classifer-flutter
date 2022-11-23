import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
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
  final ScrollController _controller = ScrollController();

  // Permissions
  bool has_storage_perm = false;
  bool has_audio_perm = false;

  // Recording
  static int MAX_DUR = 31;

  late Timer _timer;
  int _recordRemainDuration = 0;
  int _recordTime = 0;
  bool _isRecording = false;
  bool _hasFile = false;
  String filename = "";
  int _numberOfFrames = 0;

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
  int _posMoodNum = 0;
  int _negMoodCount = 0;
  int _nutMoodCount = 0;
  List<PredictModel> _predictedModels = [];
  List<Widget> _predictecdWidget = [];

  //result
  int _feedBackMood = -1;
  bool _feedBackResIsError = false;
  bool _feedBackLoading = false;
  String _feedBackRes = '';
  bool _hasFeedback = false;

  _boot() async {
    await _requestAudioPermission();
    _showHintDialog();
  }

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
          .replaceAll('-', '_')
          .replaceAll('.', '_');

      filename = 'raw_data_' + now_str + '.wav';

      setState(() {
        _isRecording = true;
        _hasFile = false;
        _numberOfFrames = 0;
        _recordTime = 0;
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
        _posMoodNum = 0;
        _negMoodCount = 0;
        _nutMoodCount = 0;
        _feedBackMood = -1;
        _feedBackResIsError = false;
        _feedBackLoading = false;
        _feedBackRes = '';
        _hasFeedback = false;
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
            _recordRemainDuration = MAX_DUR;
          });
        } else {
          setState(() {
            _recordRemainDuration--;
            _recordTime++;
            if (_recordTime % 3 == 0) {
              _numberOfFrames++;
            }
          });
        }
      },
    );
  }

  void _scrollDown() {
    _controller.animateTo(
      _controller.position.maxScrollExtent,
      duration: Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  void _showHintDialog() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          double height = MediaQuery.of(context).size.height;
          double width = MediaQuery.of(context).size.width;
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    Constants.TEXT_INPUT_ROUNDNESS)), //this right here
            child: Container(
              width: width * 4 / 5,
              height: height*4/5,
              child: Padding(
                padding: EdgeInsets.all(width / 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "1: اگر اجازه دسترسی را ندادید در مراحل آتی بدهید",
                          style: Constants.TEXT_STYLE_BLACK_MEDIUM_BOLD,
                          overflow: TextOverflow.visible,
                        ),
                        SizedBox(
                          height: height / 80,
                        ),
                        const Text(
                          "2: این نرم افزار برای محیط ماشین و صداهای آن طراحی شده است",
                          style: Constants.TEXT_STYLE_BLACK_MEDIUM_BOLD,
                          overflow: TextOverflow.visible,
                        ),
                        SizedBox(
                          height: height / 80,
                        ),
                        const Text(
                          "3: در صورت گرفتن نتیجه نامطلوب، بازخورد میتوانید بدهید",
                          style: Constants.TEXT_STYLE_BLACK_MEDIUM_BOLD,
                          overflow: TextOverflow.visible,
                        ),
                        SizedBox(
                          height: height / 80,
                        ),
                        const Text(
                          "4: در صورت دیدن باگ من را در جریان بگذارید :)",
                          style: Constants.TEXT_STYLE_BLACK_MEDIUM_BOLD,
                          overflow: TextOverflow.visible,
                        ),
                        SizedBox(
                          height: height / 20,
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Container(
                          width: width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                "محمد سهیل شادمان",
                                style: Constants.TEXT_STYLE_BLACK_TITLE_BOLD,
                                overflow: TextOverflow.visible,
                              ),
                              SizedBox(
                                height: height / 80,
                              ),
                              const Text(
                                "s.shadman@aut.ac.ir",
                                style: Constants.TEXT_STYLE_BLACK_MEDIUM_BOLD,
                                overflow: TextOverflow.visible,
                              ),
                              SizedBox(
                                height: height / 80,
                              ),
                              const Text(
                                "soheil_shadman@yahoo.com",
                                style: Constants.TEXT_STYLE_BLACK_MEDIUM_BOLD,
                                overflow: TextOverflow.visible,
                              ),
                              SizedBox(
                                height: height / 80,
                              ),
                              const Text(
                                "AUT NORC",
                                style: Constants.TEXT_STYLE_BLACK_TITLE_BOLD,
                                overflow: TextOverflow.visible,
                              ),
                              Container(
                                height: width / 6,
                                width: width / 6,
                                child: Center(
                                  child: const LoadingIndicator(
                                    indicatorType: Indicator.pacman,
                                    colors: [
                                      Constants.COLOR_MAIN_DARK,
                                    ],
                                    strokeWidth: 2,
                                    backgroundColor: Constants.COLOR_WHITE_MAIN,
                                    pathBackgroundColor:
                                    Constants.COLOR_MAIN_DARK,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        MyButton(
                          callBack: () {
                            MyApp.backTo(context);
                          },
                          buttonText: "فهمیدم",
                          width: width * 3.5 / 4,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
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
    _recordRemainDuration = MAX_DUR;
    _boot();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Constants.COLOR_MAIN_DARK,
      body: Container(
          height: height,
          padding: EdgeInsets.only(top: Constants.SAFE_AREA_PADDING),
          width: width,
          child: SingleChildScrollView(
            controller: _controller,
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
                        'ابتدا صدا را ضبط کنید ( بین 6 تا 31 ثانیه )',
                        style: Constants.TEXT_STYLE_WHITE_SMALL,
                      )),
                ),
                Padding(
                  padding: EdgeInsets.only(top: height / 80),
                  child: MyButton(
                      callBack: () {
                        if (!_isActionsDisabled) {
                          if (_isRecording) {
                            if (MAX_DUR - _recordRemainDuration <= 6) {
                              MyApp.showSnackBar(context,
                                  content: "حداقل 6.1 ثانیه صبر کنید",
                                  isError: true);
                            } else {
                              _recordRemainDuration = MAX_DUR;
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
                        'ثانیه ضبط شده : $_recordTime',
                        style: Constants.TEXT_STYLE_WHITE_SMALL,
                      )),
                ),
                Padding(
                  padding: EdgeInsets.only(top: height / 80),
                  child: Container(
                      width: width * 8 / 10,
                      child: Text(
                        'تعداد فریم ها : $_numberOfFrames',
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
                                    children: [
                                      Column(
                                        children: _predictecdWidget,
                                      ),
                                      Container(
                                        width: width * 8 / 10,
                                        child: Row(
                                          children: [
                                            Column(
                                              children: [
                                                Text(
                                                  _posMoodNum.toString(),
                                                  style: Constants
                                                      .TEXT_STYLE_WHITE_TITLE_BOLD,
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  "Positives",
                                                  style: Constants
                                                      .TEXT_STYLE_GREEN_MOOD_SMALL,
                                                )
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                Text(
                                                  _nutMoodCount.toString(),
                                                  style: Constants
                                                      .TEXT_STYLE_WHITE_TITLE_BOLD,
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  "Neutrals",
                                                  style: Constants
                                                      .TEXT_STYLE_WHITE_MEDIUM,
                                                )
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                Text(
                                                  _negMoodCount.toString(),
                                                  style: Constants
                                                      .TEXT_STYLE_WHITE_TITLE_BOLD,
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  "Negatives",
                                                  style: Constants
                                                      .TEXT_STYLE_BLUE_MOOD_SMALL,
                                                )
                                              ],
                                            ),
                                          ],
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(),
                          _predictedModels.length != 0
                              ? Padding(
                                  padding: EdgeInsets.only(top: height / 20),
                                  child: Column(
                                    children: [
                                      Column(
                                        children: [
                                          _divider(height, width),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: height / 20),
                                            child: Container(
                                                width: width * 8 / 10,
                                                child: const Text(
                                                  'مرحله آخر ( دلبخواهی )',
                                                  style: Constants
                                                      .TEXT_STYLE_WHITE_MEDIUM_BOLD,
                                                )),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: height / 80),
                                            child: Container(
                                                width: width * 8 / 10,
                                                child: const Text(
                                                  'در صورتی که مود غلط بوده، مود صحیح را انتخاب کنید',
                                                  style: Constants
                                                      .TEXT_STYLE_WHITE_SMALL,
                                                )),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: height / 80),
                                            child: _moodRow(height, width),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: height / 40),
                                            child: MyButton(
                                                callBack: () {
                                                  if (!_isActionsDisabled) {
                                                    _feedBack();
                                                  } else {
                                                    MyApp.showSnackBar(context,
                                                        content:
                                                            "بازخورد در هنگام فعایتهای دیگر غیر فعال است",
                                                        isError: true);
                                                  }
                                                },
                                                indicatorColor:
                                                    Constants.COLOR_MAIN_DARK,
                                                isLoading: _feedBackLoading,
                                                buttonText: 'فرستادن',
                                                width: width * 8 / 10,
                                                buttonColor:
                                                    Constants.COLOR_WHITE_MAIN,
                                                overlayColor: Constants
                                                    .COLOR_BUTTON_OVERLAY
                                                    .withOpacity(0.5),
                                                buttonTextStyle: Constants
                                                    .TEXT_STYLE_BLACK_MEDIUM_BOLD),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: height / 80),
                                            child: Container(
                                                width: width * 8 / 10,
                                                child: Text(
                                                  'جواب سرور : $_feedBackRes',
                                                  style: _feedBackResIsError
                                                      ? Constants
                                                          .TEXT_STYLE_ERROR_SMALL
                                                      : Constants
                                                          .TEXT_STYLE_WHITE_SMALL,
                                                )),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: height / 40),
                                            child: _divider(height, width),
                                          )
                                        ],
                                      ),
                                    ],
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
                      style: model.mood == "neutral"
                          ? Constants.TEXT_STYLE_WHITE_SMALL_BOLD
                          : model.mood == "positive"
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
                  borderRadius:
                      BorderRadius.circular(Constants.TEXT_INPUT_ROUNDNESS),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _moodRow(double height, double width) {
    return Container(
      width: width * 8 / 10,
      height: height / 18,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _feedBackMood = 0;
              });
            },
            child: Container(
              width: width * 2.5 / 10,
              height: height / 18,
              decoration: BoxDecoration(
                color: _feedBackMood == 0
                    ? Constants.COLOR_GREE
                    : Constants.COLOR_WHITE_MAIN,
                borderRadius: BorderRadius.circular(Constants.APP_ROUNDNESS),
              ),
              child: Center(
                child: Text(
                  "Positive",
                  style: Constants.TEXT_STYLE_BLACK_MEDIUM_BOLD,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _feedBackMood = 1;
              });
            },
            child: Container(
              width: width * 2.5 / 10,
              height: height / 18,
              decoration: BoxDecoration(
                color: _feedBackMood == 1
                    ? Constants.COLOR_LIGHT_GRAY
                    : Constants.COLOR_WHITE_MAIN,
                borderRadius: BorderRadius.circular(Constants.APP_ROUNDNESS),
              ),
              child: Center(
                child: Text(
                  "Neutral",
                  style: Constants.TEXT_STYLE_BLACK_MEDIUM_BOLD,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _feedBackMood = 2;
              });
            },
            child: Container(
              width: width * 2.5 / 10,
              height: height / 18,
              decoration: BoxDecoration(
                color: _feedBackMood == 2
                    ? Constants.COLOR_BLUE
                    : Constants.COLOR_WHITE_MAIN,
                borderRadius: BorderRadius.circular(Constants.APP_ROUNDNESS),
              ),
              child: Center(
                child: Text(
                  "Negative",
                  style: Constants.TEXT_STYLE_BLACK_MEDIUM_BOLD,
                ),
              ),
            ),
          ),
        ],
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

    var response = await API.Instance!.post("model-controller/process-raw-data",
        {"session_id": Constants.SESSION_ID, "filename": filename});
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

  _feedBack() async {
    if (_hasFeedback) {
      MyApp.showSnackBar(context, content: "شما قبلا بازخورد داده اید !");
      return;
    }
    if (_feedBackMood == -1) {
      MyApp.showSnackBar(context, content: "مودی انتخاب نشده", isError: true);
      return;
    }
    setState(() {
      _feedBackLoading = true;
      _isActionsDisabled = true;
      _feedBackResIsError = false;
    });

    var response =
        await API.Instance!.post("model-controller/feed_back_on_audio", {
      "session_id": Constants.SESSION_ID,
      "filename": filename,
      "mood": _feedBackMood == 0
          ? "positive"
          : _feedBackMood == 1
              ? "neutral"
              : "negative",
      "audio_duration": _recordTime
    });
    if (response.isFailed) {
      setState(() {
        _feedBackLoading = false;
        _feedBackRes = response.error!;
        _isActionsDisabled = false;
        _feedBackResIsError = true;
      });
      return;
    }
    setState(() {
      _feedBackMood = -1;
      _hasFeedback = true;
      _feedBackLoading = false;
      _isActionsDisabled = false;
      _feedBackRes = response.data;
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
        {"session_id": Constants.SESSION_ID, "filename": filename});
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
      _posMoodNum = 0;
      _negMoodCount = 0;
      _nutMoodCount = 0;
      _resultLoading = true;
      _isActionsDisabled = true;
      _resultResIsError = false;
    });

    var response = await API.Instance!.post(
        "model-controller/get_session_file_result",
        {"session_id": Constants.SESSION_ID, "filename": filename});
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
    List<PredictModel> _orderd = [];

    for (var i = 0; i < _predictedModels.length; i++) {
      for (int j = 0; j < _predictedModels.length; j++) {
        String str = _predictedModels[j].filename.split('-')[0];
        if (str == i.toString()) {
          _orderd.add(_predictedModels[j]);
        }
      }
    }
    for (var i = 0; i < _orderd.length; i++) {
      if (_orderd[i].mood == 'positive') {
        _posMoodNum++;
      } else if (_orderd[i].mood == 'negative') {
        _negMoodCount++;
      } else {
        _nutMoodCount++;
      }
      _predictecdWidget.add(_predictedItemWidget(_orderd[i], height, width));
    }
    setState(() {
      _resultLoading = false;
      _isActionsDisabled = false;
      _resultRes = response.data.toString();
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      _scrollDown();
    });
  }

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
    _controller.dispose();
    super.dispose();
  }
}
