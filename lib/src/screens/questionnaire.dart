import 'dart:convert';
import 'package:flutter/material.dart';
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
  int _currentQuestionIndex = 0;
  bool isLoading = true;
  List<String?> _answers = []; // Array to store answers
  String? _selectedAnswer; // To store the current selection
  late DatabaseService dbService;
  late StorageService storageService;

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
      print("Error fetching questions: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onAnswerSelected(String answer) {
    setState(() {
      _selectedAnswer = answer; // Update the selected answer
      _answers[_currentQuestionIndex] = answer; // Update the _answers array
    });
  }

  Widget _buildQuestionCard() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_questions.isEmpty) {
      return const Center(child: Text("No questions found."));
    }

    var question = _questions[_currentQuestionIndex];
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
                groupValue:
                    _selectedAnswer, // Link to _selectedAnswer for selection
                onChanged: (value) {
                  _onAnswerSelected(value as String);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Future<void> nextQuestion() async {
    if (_selectedAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select an option before move on"),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        // Move to the next question
        _currentQuestionIndex++;

        // Update _selectedAnswer to the stored answer for the new question, or reset if not answered
        _selectedAnswer = _answers[_currentQuestionIndex];
      });
    } else {
      print(_answers);
      // Save answer to db
      dbService = DatabaseService(client, collections);
      try {
        var payload = {"answer": _answers};
        await dbService.updateDocument(
            "Questionnaire", widget.questionnaireData.id, payload);
      } catch (e) {
        print(e);
      }

      _showFinishDialog();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        // Move to the previous question
        _currentQuestionIndex--;

        // Update _selectedAnswer to the stored answer for the new question
        _selectedAnswer = _answers[_currentQuestionIndex];
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Questionnaire"),
      ),
      body: Column(
        children: [
          Expanded(child: _buildQuestionCard()),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentQuestionIndex > 0)
                  ElevatedButton(
                    onPressed: _previousQuestion,
                    child: const Text("Previous"),
                  ),
                ElevatedButton(
                  onPressed: nextQuestion,
                  child: Text(_currentQuestionIndex == _questions.length - 1
                      ? "Finish"
                      : "Next"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
