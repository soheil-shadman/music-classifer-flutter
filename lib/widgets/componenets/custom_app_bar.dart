import 'package:flutter/material.dart';
import 'package:mood_classifer/constants.dart';
import 'package:mood_classifer/main.dart';

class CustomAppBar extends StatelessWidget {
  double width;
  String pageName ;

  CustomAppBar({Key? key, required this.width,this.pageName=""}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(top: Constants.SAFE_AREA_PADDING),
        child: Container(
          height: width / 6,
          alignment: Alignment.center,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(right: width / 20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        MyApp.backTo(context);
                      },
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Constants.COLOR_MAIN_DARK,
                        size: width / 18,
                      ),
                    ),
                    Padding(
                      padding:  EdgeInsets.only(right: width/80),
                      child: Text(pageName,style:Constants.TEXT_STYLE_BLACK_MEDIUM_BOLD,),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
