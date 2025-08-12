import 'dart:async';

import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:flutter/material.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/my_page.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';

typedef OnListPickerChanged<T> = void Function(T);

/// A generic picker widget for selecting items from a list. This should be used
/// in place of a [DropdownButton] when there are a lot of options, or if
/// multi-select is desired.
///
/// Note that a [Set] is used to determine which items are selected, and as
/// such, `T` must override `==`.
///
/// Also note that the [ListPicker] title widget will not automatically
/// update. The [onChanged] method should set the state on the container
/// widget.
class ListPicker<T> extends StatelessWidget {
  /// A title for the [AppBar].
  final String? pageTitle;

  /// A [Set] of initially selected options.
  final Set<T> initialValues;

  /// This option works differently in that, no matter what, if it is selected
  /// nothing else can be selected at the same time. If another item is
  /// selected while this item is selected, this item is deselected.
  ///
  /// This is meant to be used as a "pick everything" option. For example,
  /// in an [Activity] picker that allows selection of all activities, this
  /// value could be "All activities".
  final ListPickerItem<T>? allItem;

  final List<ListPickerItem<T>> items;
  final OnListPickerChanged<Set<T>> onChanged;

  final bool allowsMultiSelect;

  /// If `true`, the selected value will render on the right side of the
  /// picker. This does not apply to multi-select pickers.
  final bool showsValueOnTrailing;

  /// Implement this property to create a custom title widget for displaying
  /// which items are selected. Default behaviour is to display a [Column] of
  /// all [ListPickerItem.title] properties.
  final Widget Function(Set<T>)? titleBuilder;

  /// A [Widget] to show at the top of the underlying [ListView]. This [Widget]
  /// will scroll with the [ListView].
  final Widget? listHeader;

  const ListPicker({
    this.pageTitle,
    required this.initialValues,
    this.allItem,
    required this.items,
    required this.onChanged,
    this.allowsMultiSelect = false,
    this.titleBuilder,
    this.listHeader,
    this.showsValueOnTrailing = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListItem(
      title:
          titleBuilder == null ? _buildTitle() : titleBuilder!(initialValues),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildSingleDetail(),
          Container(width: paddingDefault),
          const RightChevronIcon(),
        ],
      ),
      onTap: () {
        push(
          context,
          _ListPickerPage<T>(
            pageTitle: pageTitle,
            listHeader: listHeader,
            allowsMultiSelect: allowsMultiSelect,
            selectedValues: initialValues,
            allItem: allItem,
            items: items,
            onItemPicked: (T pickedItem) {
              if (!allowsMultiSelect) {
                _popPickerPage(context, {pickedItem});
              }
            },
            onDonePressed: allowsMultiSelect
                ? (Set<T> pickedItems) {
                    _popPickerPage(context, pickedItems);
                  }
                : null,
          ),
        );
      },
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: initialValues.map((item) {
        return Text(_getListPickerItem(item).title ?? "");
      }).toList(),
    );
  }

  Widget _buildSingleDetail() {
    if (initialValues.length == 1 &&
        !allowsMultiSelect &&
        showsValueOnTrailing) {
      return SecondaryText(_getListPickerItem(initialValues.first).title ?? "");
    }
    return const SizedBox();
  }

  void _popPickerPage(BuildContext context, Set<T> pickedItems) {
    onChanged(pickedItems);
    Navigator.pop(context);
  }

  ListPickerItem<T> _getListPickerItem(T item) {
    if (allItem != null && item == allItem!.value) {
      return allItem!;
    }
    return items.singleWhere((indexItem) => indexItem.value == item);
  }
}

/// A class to be used with [ListPicker].
class ListPickerItem<T> {
  final String? title;
  final String? subtitle;
  final T? value;

  /// Allows custom behaviour of individual items. Returns a non-null object
  /// of type T that was picked to invoke [ListPicker.onChanged]; `null`
  /// otherwise.
  ///
  /// Implemented as a [Future] because presumably, setting this method is
  /// for custom picker behaviour and will need to wait for that behaviour to
  /// finish.
  final Future<T?> Function()? onTap;

  final bool isDivider;

  /// Whether or not to dismiss the list picker when this item is picked.
  /// Defaults to `true`.
  final bool popsListOnPicked;

  ListPickerItem.divider()
      : value = null,
        title = null,
        subtitle = null,
        isDivider = true,
        popsListOnPicked = false,
        onTap = null;

  ListPickerItem({
    required this.title,
    this.subtitle,
    this.value,
    this.onTap,
    this.popsListOnPicked = true,
  })  : assert(value != null || (value == null && onTap != null)),
        assert(title != null),
        isDivider = false;
}

/// A helper page for [ListPicker] that renders a list of options.
class _ListPickerPage<T> extends StatefulWidget {
  final String? pageTitle;
  final Widget? listHeader;
  final Set<T> selectedValues;

  final ListPickerItem<T>? allItem;
  final List<ListPickerItem<T>> items;

  final Function(T) onItemPicked;
  final Function(Set<T>)? onDonePressed;

  final bool allowsMultiSelect;

  const _ListPickerPage({
    this.pageTitle,
    this.listHeader,
    this.allowsMultiSelect = false,
    required this.selectedValues,
    this.allItem,
    required this.items,
    required this.onItemPicked,
    this.onDonePressed,
  });

  @override
  _ListPickerPageState<T> createState() => _ListPickerPageState();
}

class _ListPickerPageState<T> extends State<_ListPickerPage<T>> {
  late Set<T> _selectedValues;

  @override
  void initState() {
    super.initState();
    _selectedValues = Set.of(widget.selectedValues);
  }

  @override
  Widget build(BuildContext context) {
    List<ListPickerItem<T>> items =
        (widget.allItem == null ? [] : [widget.allItem!])..addAll(widget.items);

    return MyPage(
      appBarStyle: MyPageAppBarStyle(
        title: widget.pageTitle,
        actions: widget.allowsMultiSelect
            ? [
                ActionButton.done(
                  onPressed: () {
                    widget.onDonePressed?.call(_selectedValues);
                  },
                ),
              ]
            : [],
      ),
      child: ListView(
        children: [
          widget.listHeader == null
              ? SizedBox()
              : Padding(padding: insetsDefault, child: widget.listHeader),
          ...items.map((ListPickerItem<T> item) {
            if (item.isDivider) {
              return const Divider();
            }

            return ListItem(
              title: Text(item.title!),
              subtitle: item.subtitle == null ? null : Text(item.subtitle!),
              trailing: _selectedValues.contains(item.value)
                  ? const Icon(Icons.check)
                  : null,
              onTap: () async {
                if (item.onTap == null) {
                  // Do not trigger the callback for an item that was
                  // selected, but not picked -- multi select picker items
                  // aren't technically picked until "Done" is pressed.
                  if (!widget.allowsMultiSelect) {
                    widget.onItemPicked(item.value as T);
                  }
                  _updateState(item.value as T);
                } else {
                  T? pickedItem = await item.onTap?.call();
                  if (pickedItem != null) {
                    widget.onItemPicked(pickedItem);
                    _updateState(pickedItem);
                  }
                }
              },
            );
          }),
        ],
      ),
    );
  }

  void _updateState(T pickedItem) {
    setState(() {
      if (widget.allowsMultiSelect) {
        if (widget.allItem != null && widget.allItem!.value == pickedItem) {
          // If the "all" item was picked, deselect all other items.
          _selectedValues = {widget.allItem!.value as T};
        } else {
          // Otherwise, toggle the picked item, and deselect the "all" item
          // if it exists.
          _toggleItemSelected(pickedItem);

          if (widget.allItem != null) {
            _selectedValues.remove(widget.allItem!.value);
          }
        }
      } else {
        // For single selection pickers, always have only one item selected.
        _selectedValues = {pickedItem};
      }
    });
  }

  void _toggleItemSelected(T item) {
    if (_selectedValues.contains(item)) {
      _selectedValues.remove(item);
    } else {
      _selectedValues.add(item);
    }
  }
}
