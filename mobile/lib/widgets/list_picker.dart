import 'package:flutter/material.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/page.dart';

typedef OnListPickerChanged<T> = void Function(T);

/// A generic picker widget for selecting items from a list. This should be used
/// in place of a [DropdownButton] when there are a lot of options.
///
/// Note that `==` is used to determine which item is selected by comparing
/// the given `selectedItem` to each [ListPickerItem.value]. If you find
/// that the current selection isn't working, it is likely `T` needs to
/// override `==`.
class ListPicker<T> extends StatefulWidget {
  final T initialValue;
  final List<ListPickerItem<T>> options;
  final OnListPickerChanged<T> onChanged;

  ListPicker({
    @required this.initialValue,
    @required this.options,
    @required this.onChanged,
  }) : assert(initialValue != null),
       assert(options != null),
       assert(onChanged != null);

  @override
  _ListPickerState<T> createState() => _ListPickerState<T>();
}

class _ListPickerState<T> extends State<ListPicker<T>> {
  T _selectedItem;

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: widget.options.singleWhere((ListPickerItem<T> item) {
        return item.value == _selectedItem;
      }).child,
      trailing: Icon(Icons.chevron_right),
      onTap: () {
        push(context, _ListPickerPage<T>(
          selectedItem: _selectedItem,
          onItemPicked: (T pickedItem) {
            widget.onChanged(pickedItem);
            setState(() {
              _selectedItem = pickedItem;
            });

            Navigator.pop(context);
          },
          options: widget.options,
        ));
      },
    );
  }
}

/// A class to be used with [ListPicker].
class ListPickerItem<T> {
  final Widget child;
  final T value;

  /// Allows custom behaviour of individual items. If this is not `null`, it is
  /// called instead of [ListPicker.onChanged].
  final VoidCallback onTap;

  final bool isDivider;

  ListPickerItem.divider()
    : value = null,
      child = Divider(),
      isDivider = true,
      onTap = null;

  ListPickerItem({
    @required this.child,
    this.value,
    this.onTap,
  }) : assert(value != null || (value == null && onTap != null)),
       assert(child != null),
       isDivider = false;
}

/// A helper page for [ListPicker] that renders a list of options.
class _ListPickerPage<T> extends StatelessWidget {
  final T selectedItem;
  final List<ListPickerItem<T>> options;
  final Function(T) onItemPicked;

  _ListPickerPage({
    @required this.selectedItem,
    @required this.options,
    @required this.onItemPicked,
  }) : assert(selectedItem != null),
        assert(options != null),
        assert(onItemPicked!= null);

  @override
  Widget build(BuildContext context) {
    return Page(
      appBarStyle: PageAppBarStyle(),
      child: ListView(
        children: options.map((ListPickerItem<T> item) {
          if (item.isDivider) {
            return item.child;
          }

          return ListTile(
            title: item.child,
            trailing: selectedItem == item.value ? Icon(
              Icons.check,
              color: Theme.of(context).primaryColor,
            ) : null,
            onTap: () {
              if (item.onTap != null) {
                item.onTap();
              } else {
                onItemPicked(item.value);
              }
            },
          );
        }).toList(),
      ),
    );
  }
}