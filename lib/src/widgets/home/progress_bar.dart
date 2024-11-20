import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tb_vision/src/services/database/model.dart';
import 'package:tb_vision/src/services/utils.dart';

class ProgressBar extends StatefulWidget {
  final Administration? administrationData;
  final bool isLoading;
  const ProgressBar(
      {super.key, required this.administrationData, required this.isLoading});

  @override
  State<ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar> {
  // Track the current stage index
  int currentStage = 1;

  // Define the stages for progress
  final List<String> stages = [
    "Awaiting Administration",
    "Complete Questionnaire",
    "Hibernation Period",
    "Self-Capture Lesion",
    "Pending Result"
  ];

  final List<String> stagesInfo = [
    "You have symptoms that may indicate latent tuberculosis. Please visit the hospital stated on your appointment card at the specified date and time to undergo the Mantoux Tuberculin Skin Test (TST).",
    "Complete the questionnaire on the day of your appointment. If you are uncertain about any questions, consult a healthcare professional for guidance. Your responses are essential for accurately interpreting the skin test results, so please complete it carefully.",
    "A waiting period of 48 hours is required after undergoing the skin test. During this time, avoid performing any self-assessment until the waiting period is over.",
    "Perform the self-assessment as outlined in the provided guidelines. Ensure you complete this step before the stated deadline for accurate results. Follow the instructions carefully to avoid errors.",
    "Congratulations! You have completed all the required steps. Please stay alert for further updates from your doctor. Note that you may need to recapture the photo if it does not meet the doctor’s requirements."
  ];

  @override
  void initState() {
    super.initState();
    calculateCurrentStage();
  }

  @override
  void didUpdateWidget(covariant ProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only recalculate if the data has changed
    if (oldWidget.administrationData != widget.administrationData) {
      calculateCurrentStage();
    }
  }

  void calculateCurrentStage() {
    final administrationData = widget.administrationData;

    int updatedStage = 1; // Default to the first stage

    if (administrationData == null) {
      updatedStage = 1; // No data, stay at the first stage
    } else {
      if (Utils.hasAdministrationDatePassed(administrationData.datetime)) {
        updatedStage = 1;
      } else if (Utils.isQuestionnaireAnswerEmpty(
          administrationData.questionnaireData?.answer)) {
        updatedStage = 2;
      } else if (administrationData.recordData != null) {
        updatedStage = 3;

        if (Utils.isHibernationPeriodPassed(
            administrationData.recordData?.datetime)) {
          updatedStage = 4;
        }
      }

      if (!Utils.isAnalysisEmpty(administrationData.analysisData)) {
        updatedStage = 5;
      }
    }

    // Only update and trigger a rebuild if the stage changes
    if (currentStage != updatedStage) {
      setState(() {
        currentStage = updatedStage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double progressValue = (currentStage - 1) / (stages.length - 1);
    return Skeletonizer(
      enabled: widget.isLoading,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Column(
          children: [
            // Stage label and info button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Stage $currentStage : ${stages[currentStage - 1]}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon:
                      const Icon(Icons.info_outline, color: Color(0xFF003366)),
                  onPressed: () {
                    // Show information about the current stage
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Stage Information"),
                        content: Text(stagesInfo[currentStage - 1]),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Close"),
                          ),
                        ],
                      ),
                    );
                  },
                  tooltip: 'Information about this stage',
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Progress bar with circular indicators
            Stack(
              alignment: Alignment.centerLeft,
              children: [
                LinearProgressIndicator(
                  value: progressValue,
                  backgroundColor: Colors.grey.shade300,
                  color: const Color(0xFF003366),
                  minHeight: 8.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(stages.length, (index) {
                    bool isReached = index + 1 <= currentStage;
                    return Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isReached
                            ? const Color(0xFF003366)
                            : Colors.grey.shade300,
                        border: Border.all(
                          color: isReached
                              ? const Color(0xFF003366)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: isReached
                          ? const Icon(Icons.check,
                              size: 16, color: Colors.white)
                          : null,
                    );
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
