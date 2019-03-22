import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/loading.dart';
import 'package:mobile/widgets/page.dart';
import 'package:mobile/widgets/widget.dart';

// TODO: Investigate why generic typedefs do not work here.
typedef OnGetEditPageCallback = Widget Function(dynamic t);
typedef OnBuildTileCallback = Widget Function(dynamic t, Function(dynamic t));

/// A generic page for listing a given type, T, with the ability to navigate
/// to an "edit" page.
class ListPage<T> extends StatefulWidget {
  final AppManager _app;
  final String _title;
  final OnGetEditPageCallback _onGetEditPageCallback;
  final OnBuildTileCallback _onBuildTileCallback;
  final Stream<List<T>> _stream;

  ListPage({
    @required AppManager app,
    @required String title,
    @required OnGetEditPageCallback onGetEditPageCallback,
    @required OnBuildTileCallback onBuildTileCallback,
    @required Stream<List<T>> stream,
  }) : assert(app != null),
       assert(title != null),
       assert(onGetEditPageCallback != null),
       assert(onBuildTileCallback != null),
       assert(stream != null),
       _app = app,
       _title = title,
       _onGetEditPageCallback = onGetEditPageCallback,
       _onBuildTileCallback = onBuildTileCallback,
       _stream = stream;

  @override
  _ListPageState createState() => _ListPageState<T>();
}

class _ListPageState<T> extends State<ListPage> {
  AppManager get _app => widget._app;
  String get _title => widget._title;
  OnGetEditPageCallback get _onGetEditPageCallback =>
      widget._onGetEditPageCallback;
  OnBuildTileCallback get _onBuildTileCallback => widget._onBuildTileCallback;
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
            separatorBuilder: (BuildContext context, int i) =>
                MinDivider(),
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
