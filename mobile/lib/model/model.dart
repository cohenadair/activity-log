import 'package:uuid/uuid.dart';

abstract class Model {
  static const keyId = "id";

  final String _id;
  String get id => _id;

  Model.fromMap(Map<String, dynamic> map) : _id = map[keyId];
  Model.fromBuilder(ModelBuilder builder) : _id = builder.id;

  Map<String, dynamic> toMap() {
    return {keyId: _id};
  }
}

abstract class ModelBuilder {
  String id = const Uuid().v1();

  ModelBuilder();
  ModelBuilder.fromModel(Model model) : id = model.id;

  Model get build;
}
