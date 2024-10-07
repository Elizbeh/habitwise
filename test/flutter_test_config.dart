import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
void main() {
  // Configure hitTest warnings to be fatal
  WidgetController.hitTestWarningShouldBeFatal = true;

  // Enable debug checking for intrinsic sizes
  debugCheckIntrinsicSizes = true;
}
