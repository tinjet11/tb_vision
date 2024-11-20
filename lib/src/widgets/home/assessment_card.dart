import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tb_vision/src/screens/capture_instructions_screen.dart';
import 'package:tb_vision/src/services/database/model.dart';
import 'package:tb_vision/src/services/utils.dart';

class AssessmentCard extends StatelessWidget {
  final Administration? administrationData;
  final bool isLoading;

  const AssessmentCard({
    super.key,
    required this.administrationData,
    required this.isLoading,
  });

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case "approve":
        return Colors.green;
      case "rejected":
        return Colors.red;
      case "pending":
        return Colors.orange;
      default:
        return Colors.grey; // Default color for unknown status
    }
  }

  FontWeight _getStatusFontWeight(String? status) {
    switch (status?.toLowerCase()) {
      case "approve":
        return FontWeight.bold;
      case "rejected":
        return FontWeight.bold;
      case "pending":
        return FontWeight.normal;
      default:
        return FontWeight.normal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enableSwitchAnimation: true,
      enabled: isLoading,
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
              // Title section
              const Text(
                "Capture Skin Lesion",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // Date section
              Text(
                "Complete before ${Utils.getFormattedDate(Utils.addDaysToDate(administrationData?.recordData?.datetime, 3))}",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Status: ${administrationData?.analysisData?.status?.toUpperCase()}",
                style: TextStyle(
                  color:
                      _getStatusColor(administrationData?.analysisData?.status),
                  fontWeight: _getStatusFontWeight(
                      administrationData?.analysisData?.status),
                ),
              ),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Skeleton.ignore(
                  child: _buildActionButton(context),
                ),
              ]),
              // Action button section
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    if (!Utils.isHibernationPeriodPassed(
        administrationData?.recordData?.datetime)) {
      return const Text(
        "Locked",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.grey,
        ),
      );
    }

    if (Utils.isAnalysisEmpty(administrationData?.analysisData) ||
        administrationData?.analysisData?.status == "rejected") {
      return OutlinedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CaptureInstructionsScreen(
                administrationData: administrationData!,
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
          "Start",
          style: TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return const Text(
      "Completed",
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.green,
      ),
    );
  }
}
