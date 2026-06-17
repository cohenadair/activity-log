import 'package:adair_flutter_lib/model/gen/adair_flutter_lib.pb.dart';
import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:adair_flutter_lib/utils/string.dart';
import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/activity.dart';
import 'package:mobile/model/report.dart';
import 'package:mobile/report_manager.dart';
import 'package:mobile/widgets/edit_page.dart';

class EditReportPage extends StatefulWidget {
  final Report? editingReport;
  final Set<Activity> activities;
  final DateRange dateRange;

  /// Called with the newly created [Report] after a successful save. Not
  /// called when editing an existing report.
  final void Function(Report)? onSaved;

  const EditReportPage({
    this.editingReport,
    required this.activities,
    required this.dateRange,
    this.onSaved,
  });

  @override
  EditReportPageState createState() => EditReportPageState();
}

class EditReportPageState extends State<EditReportPage> {
  final _formKey = GlobalKey<FormState>();

  bool get _isEditing => widget.editingReport != null;

  late TextEditingController _nameController;
  String? _nameValidatorValue;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: _isEditing ? widget.editingReport!.name : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return EditPage(
      title: _isEditing
          ? Strings.of(context).editReportPageEditTitle
          : Strings.of(context).editReportPageNewTitle,
      padding: insetsVerticalSmall,
      onSave: _onPressedSaveButton,
      onDelete: _onPressedDeleteButton,
      deleteDescription: _isEditing
          ? format(Strings.of(context).editReportPageDeleteMessage, [
              widget.editingReport!.name,
            ])
          : null,
      isEditingCallback: () => _isEditing,
      form: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: paddingDefault),
          child: TextFormField(
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            controller: _nameController,
            decoration: InputDecoration(
              labelText: Strings.of(context).editReportPageNameLabel,
            ),
            validator: (_) => _nameValidatorValue,
          ),
        ),
      ),
    );
  }

  void _onPressedSaveButton() {
    final name = _nameController.text.trim();

    _validateName(name, (errorText) {
      _nameValidatorValue = errorText;
      if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
        return;
      }
      _save(name);
    });
  }

  void _validateName(String name, void Function(String?) onFinish) {
    if (_isEditing &&
        equalsTrimmedIgnoreCase(widget.editingReport!.name, name)) {
      onFinish(null);
      return;
    }

    if (name.isEmpty) {
      onFinish(Strings.of(context).editReportPageMissingName);
      return;
    }

    final nameExistsMessage = Strings.of(context).editReportPageNameExists;
    ReportManager.get.reportNameExists(name).then((exists) {
      onFinish(exists ? nameExistsMessage : null);
    });
  }

  void _save(String name) {
    final activityIds = widget.activities.map((a) => a.id).toList();

    if (_isEditing) {
      final builder = ReportBuilder.fromReport(widget.editingReport!)
        ..name = name
        ..activityIds = activityIds
        ..dateRange = widget.dateRange;

      ReportManager.get.updateReport(builder.build);
    } else {
      final report = ReportBuilder(
        name: name,
        activityIds: activityIds,
        dateRange: widget.dateRange,
      ).build;

      ReportManager.get.addReport(report);
      widget.onSaved?.call(report);
    }

    Navigator.pop(context);
  }

  void _onPressedDeleteButton() {
    ReportManager.get.removeReport(widget.editingReport!.id);
  }
}
