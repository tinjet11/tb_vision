import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tb_vision/src/services/database/model.dart';
import 'package:tb_vision/src/screens/questionnaire.dart';
import 'package:tb_vision/src/services/utils.dart';

class QuestionnaireCard extends StatefulWidget {
  final Administration? administrationData;
  final Questionnaire? questionnaireData;
  final bool isLoading;

  const QuestionnaireCard({
    super.key,
    required this.administrationData,
    required this.isLoading,
    this.questionnaireData,
  });

  @override
  State<QuestionnaireCard> createState() => _QuestionnaireCardState();
}

class _QuestionnaireCardState extends State<QuestionnaireCard> {
  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: widget.isLoading,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        shadowColor: Colors.black.withOpacity(0.1),
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Questionnaire",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Skeleton.ignore(child: _buildActionButton(context)),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the action button based on the state of the questionnaire and administration data.
  Widget _buildActionButton(BuildContext context) {
    // if administration date haven't reach
    if (!Utils.hasAdministrationDatePassed(
        widget.administrationData?.datetime)) {
      return const Text(
        "Locked",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.grey,
        ),
      );
    }

    // if questionnaire answer empty
    if (Utils.isQuestionnaireAnswerEmpty(widget.questionnaireData?.answer)) {
      return OutlinedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Questionaire(
                questionnaireData: widget.questionnaireData!,
              ),
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFF003366),
          side: const BorderSide(color: Color(0xFF003366), width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          "Answer",
          style: TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    // if answer not empty and administration date have passed
    return const Text(
      "Completed",
      style: TextStyle(
        decoration: TextDecoration.underline,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.green,
      ),
    );
  }
}
