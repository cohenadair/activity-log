import 'package:adair_flutter_lib/res/theme.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart';
import 'package:flutter/material.dart';

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
