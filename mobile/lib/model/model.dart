import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

abstract class Model {
  final String _id;
  String get id => _id;

  Model.fromFirestore(DocumentSnapshot doc) : _id = doc.documentID;
  Model.fromBuilder(ModelBuilder builder) : _id = builder.id;

  Map<String, dynamic> toMap();
}

abstract class ModelBuilder {
  String id = Uuid().v1();

  ModelBuilder();
  ModelBuilder.fromModel(Model model) : id = model.id;

  Model get build;
}