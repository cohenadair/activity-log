import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/page.dart';

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
  /// A [Set] of initially selected options.
  final Set<T> initialValues;

  /// This option works differently in that, no matter what, if it is selected
  /// nothing else can be selected at the same time. If another item is
  /// selected while this item is selected, this item is deselected.
  ///
  /// This is meant to be used as a "pick everything" option. For example,
  /// in an [Activity] picker that allows selection of all activities, this
  /// value could be "All activities".
  final ListPickerItem<T> allItem;

  final List<ListPickerItem<T>> items;
  final OnListPickerChanged<Set<T>> onChanged;

  final bool allowsMultiSelect;

  /// Implement this property to create a custom title widget for displaying
  /// which items are selected. Default behaviour is to display a [Column] of
  /// all [ListPickerItem.child] properties.
  final Widget Function(Set<T>) titleBuilder;

  ListPicker({
    @required this.initialValues,
    this.allItem,
    @required this.items,
    @required this.onChanged,
    this.allowsMultiSelect = false,
    this.titleBuilder,
  }) : assert(initialValues != null),
       assert(items != null),
       assert(onChanged != null)
  {
    // Assert that all initial values exist in the given items, and that there
    // are no duplicates.
    initialValues.forEach((T value) {
      try {
        assert(_getListPickerItem(value) != null);
      } on StateError catch(_) {
        assert(false, "Initial value must appear 1 time in items");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListItem(
      title: titleBuilder == null
          ? _buildTitle() : titleBuilder(initialValues),
      trailing: Icon(Icons.chevron_right),
      onTap: () {
        push(context, _ListPickerPage<T>(
          allowsMultiSelect: allowsMultiSelect,
          selectedValues: initialValues,
          allItem: allItem,
          items: items,
          onItemPicked: (T pickedItem) {
            if (!allowsMultiSelect) {
              _popPickerPage(context, Set.of([pickedItem]));
            }
          },
          onDonePressed: allowsMultiSelect ? (Set<T> pickedItems) {
            _popPickerPage(context, pickedItems);
          } : null,
        ));
      },
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: initialValues.map((item) {
        return _getListPickerItem(item).child;
      }).toList(),
    );
  }

  void _popPickerPage(BuildContext context, Set<T> pickedItems) {
    onChanged(pickedItems);
    Navigator.pop(context);
  }

  ListPickerItem<T> _getListPickerItem(T item) {
    if (item == allItem.value) {
      return allItem;
    }
    return items.singleWhere((indexItem) => indexItem.value == item);
  }
}

/// A class to be used with [ListPicker].
class ListPickerItem<T> {
  final Widget child;
  final T value;

  /// Allows custom behaviour of individual items. Returns a non-null object
  /// of type T that was picked to invoke [ListPicker.onChanged]; `null`
  /// otherwise.
  ///
  /// Implemented as a [Future] because presumably, setting this method is
  /// for custom picker behaviour and will need to wait for that behaviour to
  /// finish.
  final Future<T> Function() onTap;

  final bool isDivider;

  /// Whether or not to dismiss the list picker when this item is picked.
  /// Defaults to `true`.
  final bool popsListOnPicked;

  ListPickerItem.divider()
    : value = null,
      child = Divider(),
      isDivider = true,
      popsListOnPicked = false,
      onTap = null;

  ListPickerItem({
    @required this.child,
    this.value,
    this.onTap,
    this.popsListOnPicked = true,
  }) : assert(value != null || (value == null && onTap != null)),
       assert(child != null),
       isDivider = false;
}

/// A helper page for [ListPicker] that renders a list of options.
class _ListPickerPage<T> extends StatefulWidget {
  final Set<T> selectedValues;

  final ListPickerItem<T> allItem;
  final List<ListPickerItem<T>> items;

  final Function(T) onItemPicked;
  final Function(Set<T>) onDonePressed;

  final bool allowsMultiSelect;

  _ListPickerPage({
    this.allowsMultiSelect = false,
    @required this.selectedValues,
    this.allItem,
    @required this.items,
    @required this.onItemPicked,
    this.onDonePressed,
  }) : assert(selectedValues != null),
       assert(items != null),
       assert(onItemPicked != null);

  @override
  _ListPickerPageState<T> createState() => _ListPickerPageState();
}

class _ListPickerPageState<T> extends State<_ListPickerPage<T>> {
  Set<T> _selectedValues;

  @override
  void initState() {
    super.initState();
    _selectedValues = Set.of(widget.selectedValues);
  }

  @override
  Widget build(BuildContext context) {
    List<ListPickerItem<T>> items =
        (widget.allItem == null ? [] : [widget.allItem])..addAll(widget.items);

    return Page(
      appBarStyle: PageAppBarStyle(
        actions: widget.allowsMultiSelect ? [
          ActionButton.done(onPressed: () {
            widget.onDonePressed(_selectedValues);
          }),
        ] : [],
      ),
      child: ListView(
        children: items.map((ListPickerItem<T> item) {
          if (item.isDivider) {
            return item.child;
          }

          return ListItem(
            title: item.child,
            trailing: _selectedValues.contains(item.value) ? Icon(
              Icons.check,
              color: Theme.of(context).primaryColor,
            ) : null,
            onTap: () async {
              if (item.onTap == null) {
                // Do not trigger the callback for an item that was selected,
                // but not picked -- multi select picker items aren't
                // technically picked until "Done" is pressed.
                if (!widget.allowsMultiSelect) {
                  widget.onItemPicked(item.value);
                }
                _updateState(item.value);
              } else {
                T pickedItem = await item.onTap();
                if (pickedItem != null) {
                  widget.onItemPicked(pickedItem);
                  _updateState(pickedItem);
                }
              }
            },
          );
        }).toList(),
      ),
    );
  }

  void _updateState(T pickedItem) {
    setState(() {
      if (widget.allowsMultiSelect) {
        if (widget.allItem != null && widget.allItem.value == pickedItem) {
          // If the "all" item was picked, deselect all other items.
          _selectedValues = Set.of([widget.allItem.value]);
        } else {
          // Otherwise, toggle the picked item, and deselect the "all" item
          // if it exists.
          _toggleItemSelected(pickedItem);

          if (widget.allItem != null) {
            _selectedValues.remove(widget.allItem.value);
          }
        }
      } else {
        // For single selection pickers, always have only one item selected.
        _selectedValues = Set.of([pickedItem]);
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