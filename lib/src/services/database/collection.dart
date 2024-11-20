import 'package:tb_vision/env/env.dart';

class Collection {
  final String dbId;
  final String id;
  final String name;

  Collection({required this.dbId, required this.id, required this.name});
}

final collections = [
  Collection(
    dbId: Env.databaseId,
    id: Env.hospitalCollectionId,
    name: 'Hospital',
  ),
  Collection(
    dbId: Env.databaseId,
    id: Env.patientCollectionId,
    name: 'Patient',
  ),
  Collection(
    dbId: Env.databaseId,
    id: Env.administrationCollectionId,
    name: 'Administration',
  ),
  Collection(
    dbId: Env.databaseId,
    id: Env.questionnaireCollectionId,
    name: 'Questionnaire',
  ),
  Collection(
    dbId: Env.databaseId,
    id: Env.analysisCollectionId,
    name: 'Analysis',
  ),
];
