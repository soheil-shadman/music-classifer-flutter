import 'package:flutter/material.dart';
import 'package:mood_classifer/constants.dart';


class MyTextField extends StatefulWidget {
  TextEditingController controller;
  double width;
  double height;
  bool isPassword;
  int inputType;

  // 0 = > Text , 1 => Phone , 2 => Email

  bool goToNextNode;

  String hintText;
  String labelText;
  double boarderWidth;
  Function(String) onChange;
  String? Function(String?)? validator;

  MyTextField({
    required this.controller,
    required this.onChange,
    required this.validator,
    this.inputType = 0,
    this.goToNextNode = false,
    this.width = 200,
    this.height = 50,
    this.hintText = "وارد کنید",
    this.labelText = "تست",
    this.boarderWidth = 1.5,
    this.isPassword = false,
  });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  bool _obscure = false;

  @override
  void initState() {
    if (widget.isPassword) {
      _obscure = true;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      child: TextFormField(
        controller: widget.controller,
        cursorHeight: 20,
        validator: widget.validator,
        textInputAction:
            widget.goToNextNode ? TextInputAction.next : TextInputAction.done,
        cursorColor: Constants.COLOR_MAIN_DARK,
        style: Constants.TEXT_STYLE_BLACK_SMALL,
        decoration: InputDecoration(
          suffix: widget.isPassword
              ? GestureDetector(
                  child: _obscure
                      ? Icon(
                          Icons.visibility,
                          color: Constants.COLOR_BUTTON_OVERLAY,
                          size: 15,
                        )
                      : Icon(
                          Icons.visibility_off,
                          color: Constants.COLOR_BUTTON_OVERLAY,
                          size: 15,
                        ),
                  onTap: () {
                    setState(() {
                      _obscure = !_obscure;
                    });
                  },
                )
              : Container(height: 15,width: 15,color: Colors.transparent,),
          labelText: widget.labelText,
          // errorText: widget.validator(widget.controller.text),
          filled: true,
          errorStyle: Constants.TEXT_STYLE_ERROR_VERY_SMALL,
          //  contentPadding: EdgeInsets.all(15.0),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Constants.TEXT_INPUT_ROUNDNESS),
            borderSide: BorderSide(
              width: widget.boarderWidth,
              color: Constants.COLOR_MAIN_DARK.withOpacity(0.25),
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Constants.TEXT_INPUT_ROUNDNESS),
            borderSide: BorderSide(
              width: widget.boarderWidth,
              color: Constants.COLOR_RED_ERROR,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Constants.TEXT_INPUT_ROUNDNESS),
            borderSide: BorderSide(
              width: widget.boarderWidth,
              color: Constants.COLOR_MAIN_DARK.withOpacity(0.25),
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Constants.TEXT_INPUT_ROUNDNESS),
            borderSide: BorderSide(
              width: widget.boarderWidth,
              color: Constants.COLOR_BUTTON_OVERLAY,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Constants.TEXT_INPUT_ROUNDNESS),
            borderSide: BorderSide(
              width: widget.boarderWidth,
              color: Constants.COLOR_BUTTON_OVERLAY,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Constants.TEXT_INPUT_ROUNDNESS),
            borderSide: BorderSide(
              width: widget.boarderWidth,
              color: Constants.COLOR_BUTTON_OVERLAY,
            ),
          ),
          labelStyle: Constants.TEXT_STYLE_GRAY_VERY_SMALL,
        ),
        keyboardType: widget.inputType == 0
            ? TextInputType.text
            : widget.inputType == 1
                ? TextInputType.phone
                : widget.inputType == 2
                    ? TextInputType.emailAddress
                    : TextInputType.text,
        onChanged: (value) {
          widget.onChange(value);
        },
        obscureText: widget.isPassword
            ? _obscure
                ? true
                : false
            : false,
      ),
    );
  }
}
