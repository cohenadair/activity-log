import 'package:flutter/material.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

/// A widget that displays a list of titles and values in a formatted list.
class Summary extends StatelessWidget {
  final String title;
  final EdgeInsets padding;
  final List<SummaryItem> items;

  Summary({
    this.title = "",
    this.padding = insetsZero,
    this.items = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        children: <Widget>[
          isEmpty(title) ? Empty() : Padding(
            padding: insetsBottomDefault,
            child: LargeHeadingText(title),
          ),
        ]..addAll(_buildItems(context)),
      ),
    );
  }

  List<Widget> _buildItems(BuildContext context) {
    return items.map((SummaryItem item) {
      return Padding(
        padding: insetsRowDefault,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.subhead,
                ),
                Text(
                  item.value is String ? item.value : item.value.toString(),
                  style: Theme.of(context).textTheme.subhead.copyWith(
                    color: Theme.of(context).disabledColor,
                  ),
                ),
              ],
            ),
            isEmpty(item.subtitle) ? Empty() : Text(
              item.subtitle,
              style: Theme.of(context).textTheme.subtitle.copyWith(
                color: Theme.of(context).disabledColor,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}

class SummaryItem {
  final String title;
  final String subtitle;
  final dynamic value;

  SummaryItem({
    @required this.title,
    this.subtitle,
    this.value,
  });
}