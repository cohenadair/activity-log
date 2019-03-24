import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/loading.dart';
import 'package:mobile/widgets/page.dart';
import 'package:mobile/widgets/widget.dart';

/// A generic page for listing a given type, T, with the ability to navigate
/// to an "edit" page.
class ListPage<T> extends StatefulWidget {
  final String _title;
  final Widget Function(T) _onGetEditPageCallback;
  final Widget Function(T, Function(T)) _onBuildTileCallback;
  final Stream<List<T>> _stream;

  ListPage({
    @required String title,
    @required Widget Function(T) onGetEditPageCallback,
    @required Widget Function(T, Function(T)) onBuildTileCallback,
    @required Stream<List<T>> stream,
  }) : assert(title != null),
       assert(onGetEditPageCallback != null),
       assert(onBuildTileCallback != null),
       assert(stream != null),
       _title = title,
       _onGetEditPageCallback = onGetEditPageCallback,
       _onBuildTileCallback = onBuildTileCallback,
       _stream = stream;

  @override
  _ListPageState createState() => _ListPageState<T>();
}

class _ListPageState<T> extends State<ListPage<T>> {
  String get _title => widget._title;
  Widget Function(T) get _onGetEditPageCallback =>
      widget._onGetEditPageCallback;
  Widget Function(T, Function(T)) get _onBuildTileCallback => widget._onBuildTileCallback;
  Stream get _stream => widget._stream;

  @override
  Widget build(BuildContext context) {
    return Page(
      appBarStyle: PageAppBarStyle(
        title: _title,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _onPressAddButton,
          ),
        ],
      ),
      child: StreamBuilder<List<T>>(
        stream: _stream,
        builder: (BuildContext context, AsyncSnapshot<List<T>> snapshot) {
          if (!snapshot.hasData) {
            return Loading.centered();
          }

          return ListView.separated(
            itemCount: snapshot.data.length,
            separatorBuilder: (BuildContext context, int i) => MinDivider(),
            itemBuilder: (BuildContext context, int i) {
              return _onBuildTileCallback(snapshot.data[i], _openEditPage);
            },
          );
        },
      ),
    );
  }

  void _onPressAddButton() {
    _openEditPage(null);
  }

  void _openEditPage(T t) {
    push(context, _onGetEditPageCallback(t), fullscreenDialog: t == null);
  }
}
