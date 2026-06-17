import 'package:adair_flutter_lib/model/gen/adair_flutter_lib.pb.dart';
import 'package:mobile/model/model.dart';

class Report extends Model {
  static const _keyName = "name";
  static const _keyActivityIds = "activity_ids";
  static const _keyDateRange = "date_range";

  final String name;

  /// Empty list means "All Activities".
  final List<String> activityIds;

  final DateRange dateRange;

  Report.fromMap(super.map)
    : name = map[_keyName],
      activityIds = _parseActivityIds(map[_keyActivityIds] as String),
      dateRange = DateRange.fromJson(map[_keyDateRange]),
      super.fromMap();

  Report.fromBuilder(ReportBuilder super.builder)
    : name = builder.name,
      activityIds = builder.activityIds,
      dateRange = builder.dateRange,
      super.fromBuilder();

  static List<String> _parseActivityIds(String raw) =>
      raw.isEmpty ? [] : raw.split(",");

  @override
  Map<String, dynamic> toMap() {
    return {
      _keyName: name,
      _keyActivityIds: activityIds.join(","),
      _keyDateRange: dateRange.writeToJson(),
    }..addAll(super.toMap());
  }

  @override
  bool operator ==(other) {
    return other is Report && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class ReportBuilder extends ModelBuilder {
  String name;
  List<String> activityIds;
  DateRange dateRange;

  ReportBuilder({
    required this.name,
    required this.activityIds,
    required this.dateRange,
  });

  ReportBuilder.fromReport(Report super.report)
    : name = report.name,
      activityIds = List.of(report.activityIds),
      dateRange = report.dateRange,
      super.fromModel();

  @override
  Report get build => Report.fromBuilder(this);
}
