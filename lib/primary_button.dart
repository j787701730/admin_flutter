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

class CFFloatingActionButton extends FloatingActionButton {
  CFFloatingActionButton({
    Key key,
    child,
    tooltip,
    foregroundColor,
    backgroundColor = const Color.fromARGB(55, 0, 0, 0),
    focusColor,
    hoverColor,
    splashColor,
    heroTag = 'CFFloatingActionButton',
    elevation = 0.0,
    focusElevation,
    hoverElevation,
    highlightElevation = 1.0,
    disabledElevation,
    @required onPressed,
    mini = true,
    shape,
    clipBehavior = Clip.none,
    focusNode,
    autofocus = false,
    materialTapTargetSize = MaterialTapTargetSize.shrinkWrap,
    isExtended = false,
  }) : super(
          key: key,
          child: child,
          tooltip: tooltip,
          foregroundColor: focusColor,
          backgroundColor: backgroundColor,
          focusColor: focusColor,
          hoverColor: hoverColor,
          splashColor: splashColor,
          heroTag: heroTag,
          elevation: elevation,
          focusElevation: focusElevation,
          hoverElevation: hoverElevation,
          highlightElevation: highlightElevation,
          disabledElevation: disabledElevation,
          onPressed: onPressed,
          mini: mini,
          shape: shape,
          clipBehavior: clipBehavior,
          focusNode: focusNode,
          autofocus: autofocus,
          materialTapTargetSize: materialTapTargetSize,
          isExtended: isExtended,
        );
}
