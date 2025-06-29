import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Example: const MyWidget().withPadding(15).putCenter
extension PaddingExtension on Widget {
  Widget withPadding({
    double all = 0,
    double? vertical,
    double? horizontal,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) =>
      Padding(
        padding: EdgeInsets.only(
          top: top ?? vertical ?? all,
          bottom: bottom ?? vertical ?? all,
          left: left ?? horizontal ?? all,
          right: right ?? horizontal ?? all,
        ),
        child: this,
      );

  Widget get putCenter => Center(child: this);
}

extension on String {
  TextStyle style({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) =>
      TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );
}
