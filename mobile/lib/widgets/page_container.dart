import 'package:flutter/material.dart';
import 'package:mobile/res/dimen.dart';

class PageContainer extends Container {
  PageContainer({Widget child}) : super(
    padding: EdgeInsets.only(
      left: Dimen.defaultPadding,
      right: Dimen.defaultPadding,
      top: Dimen.smallPadding,
      bottom: Dimen.smallPadding
    ),
    child: SafeArea(child: child),
  );
}