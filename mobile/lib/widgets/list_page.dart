import 'package:flutter/material.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/page.dart';
import 'package:mobile/widgets/widget.dart';

/// A generic page for listing a given type, T, with the ability to navigate
/// to an "edit" page.
class ListPage<T> extends StatefulWidget {
  final String title;
  final Widget Function(T) getEditPageCallback;
  final Widget Function(T, Function(T)) buildTileCallback;
  final List<T> items;

  ListPage({
    @required this.title,
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
    return Page(
      appBarStyle: PageAppBarStyle(
        title: widget.title,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _onPressAddButton,
          ),
        ],
      ),
      child: ListView.separated(
        itemCount: widget.items.length,
        separatorBuilder: (BuildContext context, int i) => MinDivider(),
        itemBuilder: (BuildContext context, int i) =>
            widget.buildTileCallback(widget.items[i], _openEditPage),
      ),
    );
  }

  void _onPressAddButton() {
    _openEditPage(null);
  }

  void _openEditPage(T t) {
    push(context, widget.getEditPageCallback(t), fullscreenDialog: t == null);
  }
}