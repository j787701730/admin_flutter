import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class PrimaryButton extends FlatButton {
  PrimaryButton(
      {Key key,
      @required VoidCallback onPressed,
      @required Widget child,
      Color color,
      EdgeInsetsGeometry padding,
      String type})
      : super(
          key: key,
          onPressed: onPressed,
          child: child,
          textColor: Colors.white,
          color: color == null ? type == 'error' ? Colors.red : Colors.blue : color,
          padding: padding,

//  ValueChanged<bool> onHighlightChanged,
//    ButtonTextTheme textTheme,
//    Color textColor,
//    Color disabledTextColor,
//    Color color,
//  Color disabledColor,
//  Color focusColor,
//  Color hoverColor,
//  Color highlightColor,
//  Color splashColor,
//  Brightness colorBrightness,
//    EdgeInsetsGeometry padding,
//    ShapeBorder shape,
//    Clip clipBehavior,
//    FocusNode focusNode,
//  bool autofocus = false,
//  MaterialTapTargetSize materialTapTargetSize,
        );
}
