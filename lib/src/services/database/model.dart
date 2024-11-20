class Administration {
  final String id;
  final Patient patientData;
  final String datetime;
  final Hospital hospitalData;
  final Record? recordData;
  final Analysis? analysisData;
  final Questionnaire? questionnaireData;

  Administration({
    required this.id,
    required this.patientData,
    required this.datetime,
    required this.hospitalData,
    this.recordData,
    this.analysisData,
    this.questionnaireData,
  });

  factory Administration.fromJson(Map<String, dynamic> json) => Administration(
        id: json['\$id'],
        patientData: Patient.fromJson(json['patient']),
        datetime: json['datetime'],
        hospitalData:
            Hospital.fromJson(json['hospital']), // Parsing directly as Hospital
        recordData:
            json['record'] != null ? Record.fromJson(json['record']) : null,
        analysisData: json['analysis'] != null
            ? Analysis.fromJson(json['analysis'])
            : null,
        questionnaireData: json['questionnaire'] != null
            ? Questionnaire.fromJson(json['questionnaire'])
            : null,
      );
}

class Hospital {
  final String id;
  final String name;

  Hospital({required this.id, required this.name});

  factory Hospital.fromJson(Map<String, dynamic> json) => Hospital(
        id: json['\$id'], // Adjust to match the actual key for ID in your data
        name: json['name'],
      );
}

class Record {
  final String id;
  final String datetime;

  Record({required this.id, required this.datetime});

  factory Record.fromJson(Map<String, dynamic> json) => Record(
        id: json['\$id'], // Adjust to match the actual key for ID in your data
        datetime: json['datetime'],
      );
}

class Questionnaire {
  final String id;
  final List<String> answer;
  final String questionId;

  Questionnaire({
    required this.id,
    required this.answer,
    required this.questionId,
  });

  // Factory constructor for creating a Questionnaire instance from JSON
  factory Questionnaire.fromJson(Map<String, dynamic> json) => Questionnaire(
        id: json['\$id'],
        answer: List<String>.from(
            json['answer'] ?? []), // Convert JSON array to List<String>
        questionId: json['question_id'],
      );
}

class Patient {
  final String id;
  final String name;
  final String staffId;
  final String hospitalId;

  Patient({
    required this.id,
    required this.name,
    required this.staffId,
    required this.hospitalId,
  });

  // Factory constructor for creating a Patient instance from JSON
  factory Patient.fromJson(Map<String, dynamic> json) => Patient(
        id: json['\$id'],
        name: json['name'],
        staffId: json['staff_id'],
        hospitalId: json['hospital_id'],
      );
}

class Analysis {
  final String id;
  final String? status;

  Analysis({
    required this.id,
    required this.status,
  });

  // Factory constructor for creating a Patient instance from JSON
  factory Analysis.fromJson(Map<String, dynamic> json) => Analysis(
        id: json['\$id'],
        status: json['status'],
      );
}
