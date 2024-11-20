import 'package:tb_vision/env/env.dart';

class Bucket {
  final String name;
  final String id;

  Bucket({required this.name, required this.id});
}

final buckets = [
  Bucket(
    id: Env.questionaireBucketId,
    name: 'Questionnaire',
  ),
  Bucket(
    id: Env.analysisBucketId,
    name: 'Analysis',
  ),
];
