import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tb_vision/src/capture/intro.dart';

class Questionaire extends StatefulWidget {
  const Questionaire({super.key});

  @override
  State<Questionaire> createState() => _QuestionaireState();
}

class _QuestionaireState extends State<Questionaire> {
  List<dynamic> _questions = [];
  int _currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  // Load questions from a JSON file
  Future<void> _loadQuestions() async {
    final String response = await rootBundle.loadString(
        'assets/questions.json'); // Make sure to add the JSON file to your assets folder
    final List<dynamic> data = jsonDecode(response);
    setState(() {
      _questions = data;
    });
  }

  // Widget to display the current question in a card view
  Widget _buildQuestionCard() {
    if (_questions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    var question = _questions[_currentQuestionIndex];
    var options = question['options'] as List<dynamic>;

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
              question['question'],
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
                    null, // Placeholder for group value if needed for form submission
                //TODO
                onChanged: (value) {
                  // Handle option selection
                },
              );
            }),
          ],
        ),
      ),
    );
  }
  //TODO
  void nextQuestion() {
    //Handle logic such as does option being choose
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      // Save questionaire to DB
      _showFinishDialog();
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
              Navigator.pop(context); // Pop the dialog
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CaptureInstructionsPage(),
                ),
              );
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  void _previousQuestion() {
    setState(() {
      if (_currentQuestionIndex > 0) {
        _currentQuestionIndex--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Questionnaire"),
      ),
      body: Column(
        children: [
          Expanded(child: _buildQuestionCard()), // Display the question
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _previousQuestion,
                  child: const Text("Previous"),
                ),
                // Navigation Button (Next or Finish)
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
