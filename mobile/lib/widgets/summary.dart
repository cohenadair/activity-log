import 'package:flutter/material.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/widgets/list_item.dart';
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
      return ListItem(
        title: Text(item.title),
        subtitle: isEmpty(item.subtitle) ? null : Text(item.subtitle),
        trailing: SecondaryText(
          item.value is String ? item.value : item.value.toString(),
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