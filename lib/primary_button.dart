import 'package:admin_flutter/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

enum BtnType { primary, success, warning, danger, Default, info }

class PrimaryButton extends FlatButton {
  static btnColor(type) {
    switch (type) {
      case BtnType.primary:
        return CFColors.primary;
        break;
      case BtnType.success:
        return CFColors.success;
        break;
      case BtnType.warning:
        return CFColors.warning;
        break;
      case BtnType.danger:
        return CFColors.danger;
        break;
      case BtnType.Default:
        return CFColors.white;
        break;
      case BtnType.info:
        return CFColors.info;
        break;
    }
  }

  PrimaryButton({
    Key key,
    @required VoidCallback onPressed,
    @required Widget child,
    EdgeInsetsGeometry padding,
    BtnType type: BtnType.primary,
  }) : super(
          key: key,
          onPressed: onPressed,
          child: child,
          textColor: Colors.white,
          color: btnColor(type),
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
    backgroundColor,
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
