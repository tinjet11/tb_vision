import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tb_vision/src/screens/home.dart';
import 'package:tb_vision/src/services/auth/auth.dart';
import 'package:tb_vision/src/services/database/collection.dart';
import 'package:tb_vision/src/services/database/database_service.dart';
import 'package:tb_vision/src/services/database/model.dart';
import 'package:tb_vision/src/services/storage/bucket.dart';
import 'package:tb_vision/src/services/storage/storage_service.dart';

class Questionaire extends StatefulWidget {
  final Questionnaire questionnaireData;
  const Questionaire({super.key, required this.questionnaireData});

  @override
  State<Questionaire> createState() => _QuestionaireState();
}

class _QuestionaireState extends State<Questionaire> {
  List<dynamic> _questions = [];
  bool isLoading = true;
  List<String?> _answers = []; // Array to store answers
  late DatabaseService dbService;
  late StorageService storageService;
  var logger = Logger(printer: PrettyPrinter());

  @override
  void initState() {
    super.initState();
    dbService = DatabaseService(client, collections);
    storageService = StorageService(client, buckets);
    _fetchQuestionsFromUrl();
  }

  Future<void> _fetchQuestionsFromUrl() async {
    try {
      var bytes = await storageService.getFileView(
          "Questionnaire", widget.questionnaireData.questionId);

      // Decode the response if it's in JSON format
      final String dataString = utf8.decode(bytes);

      // Parse the string into a JSON object
      final Map<String, dynamic> jsonData = jsonDecode(dataString);

      setState(() {
        _questions = [
          ...jsonData['part1'],
          ...jsonData['part2']
        ]; // Combine both parts
        _answers = List<String?>.filled(
            _questions.length, null); // Initialize answers with null
        isLoading = false;
      });
    } catch (e) {
      logger.e("Error fetching questions", error: e);
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onAnswerSelected(int index, String answer) {
    setState(() {
      _answers[index] = answer; // Update the _answers array
    });
  }

  Future<void> _onSubmit() async {
    if (_answers.contains(null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please ensure every question is answered"),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    // try {
    //   var payload = {"answer": _answers};
    //   await dbService.updateDocument(
    //       "Questionnaire", widget.questionnaireData.id, payload);
    // } catch (e) {
    //   logger.e("Error saving answer to db", error: e);
    // }

    _showFinishDialog();
  }

  void _showFinishDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Questionnaire Completed"),
        content: const Text("Thank you for completing the questionnaire."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Home(),
                ),
              );
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  double _calculateProgress() {
    int answeredCount = _answers.where((answer) => answer != null).length;
    return answeredCount / _questions.length;
  }

  Widget _buildQuestionList() {
    if (isLoading) {
      return ListView.builder(
          itemCount: 10,
          itemBuilder: (BuildContext context, int index) {
            var options = ["Yes", "No"];
            return Skeletonizer(
              enabled: isLoading,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                margin: const EdgeInsets.all(16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Mock Question Data",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ...options.map((option) {
                        return RadioListTile(
                          title: Text(option),
                          value: option,
                          onChanged: (value) {
                            _onAnswerSelected(index, value as String);
                          },
                          groupValue: '',
                        );
                      })
                    ],
                  ),
                ),
              ),
            );
          });
    }

    return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _questions.length,
        itemBuilder: (BuildContext context, int index) {
          var question = _questions[index];
          var options = question['options'] as List<dynamic>? ?? ["Yes", "No"];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question['question'] ?? "No question available",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...options.map((option) {
                    return RadioListTile(
                      title: Text(option),
                      value: option,
                      groupValue: _answers[
                          index], // Link to _selectedAnswer for selection
                      onChanged: (value) {
                        _onAnswerSelected(index, value as String);
                      },
                    );
                  })
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Questionnaire"),
      ),
      body: Column(children: [
        LinearProgressIndicator(
          value: _questions.isEmpty ? 0 : _calculateProgress(),
          backgroundColor: Colors.grey[300],
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
        Expanded(child: _buildQuestionList()),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: _onSubmit,
                child: const Text("Submit"),
              ),
            ],
          ),
        )
      ]),
    );
  }
}
