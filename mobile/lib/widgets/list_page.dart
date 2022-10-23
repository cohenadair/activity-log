import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/page.dart' as p;
import 'package:mobile/widgets/widget.dart';

/// A generic page for listing a given type, T, with the ability to navigate
/// to an "edit" page.
class ListPage<T> extends StatefulWidget {
  final String title;

  /// A [Widget] to show when the list is empty.
  final Widget empty;
  final Widget Function(T) getEditPageCallback;
  final Widget Function(T, Function(T)) buildTileCallback;
  final List<T> items;

  ListPage({
    @required this.title,
    this.empty,
    @required this.getEditPageCallback,
    @required this.buildTileCallback,
    @required this.items,
  }) : assert(title != null),
        assert(getEditPageCallback != null),
        assert(buildTileCallback != null),
        assert(items != null);

  @override
  _ListPageState createState() => _ListPageState<T>();
}

class _ListPageState<T> extends State<ListPage<T>> {
  @override
  Widget build(BuildContext context) {
    return p.Page(
      appBarStyle: p.PageAppBarStyle(
        title: widget.title,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _onPressAddButton,
          ),
        ],
      ),
      child: _buildList(),
    );
  }

  Widget _buildList() {
    if (widget.items.isEmpty && widget.empty != null) {
      return widget.empty;
    }

    return ListView.separated(
      itemCount: widget.items.length,
      separatorBuilder: (BuildContext context, int i) => MinDivider(),
      itemBuilder: (BuildContext context, int i) =>
          widget.buildTileCallback(widget.items[i], _openEditPage),
    );
  }

  void _onPressAddButton() {
    _openEditPage(null);
  }

  void _openEditPage(T t) {
    push(context, widget.getEditPageCallback(t), fullscreenDialog: t == null);
  }
}