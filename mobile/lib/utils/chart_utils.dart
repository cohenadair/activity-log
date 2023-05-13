import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';
import 'package:mobile/res/theme.dart';

RenderSpec<num>? defaultChartRenderSpec(BuildContext context) {
  return GridlineRendererSpec(
    labelStyle: TextStyleSpec(
      color: ColorUtil.fromDartColor(context.colorSecondaryText),
    ),
    lineStyle: LineStyleSpec(
      color: ColorUtil.fromDartColor(context.colorBarChartLines),
    ),
  );
}
