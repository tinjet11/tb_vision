import 'package:flutter/material.dart';
import 'package:tb_vision/src/screens/camera.dart';
import 'package:tb_vision/src/services/database/model.dart';

class CaptureInstructionsScreen extends StatelessWidget {
  final Administration administrationData;
  const CaptureInstructionsScreen({super.key, required this.administrationData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Capture Instructions"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title of the page
              const Text(
                "Important Guidelines for Capturing Lesions",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Introduction or description text
              const Text(
                "Follow the steps below to ensure accurate image capture of the Mantoux test site. Make sure the surrounding setup and posture of the hand are properly arranged to achieve the best result.",
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 30),

              // First step: Placing the coin
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.attach_money, color: Colors.green),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "1. Place a RM0.20 or RM0.50 Coin",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Ensure a RM0.20 sen or RM0.50 sen coin is placed flat on the table next to the arm. The coin will serve as a reference object for measuring the lesion's size.",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Second step: Hand posture
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.pan_tool, color: Colors.blue),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "2. Proper Hand Posture",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Place your arm flat on a table, palm facing upward. Ensure the lesion area is clearly visible and not obstructed by clothing or accessories.",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Third step: Lighting conditions
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.light_mode, color: Colors.orange),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "3. Good Lighting",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Ensure that the room has proper lighting. Avoid shadows over the lesion area by adjusting the light source, and make sure the lesion is illuminated clearly.",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Fourth step: Keep camera steady
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.photo_camera, color: Colors.red),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "4. Hold Camera Steady",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Hold your phone steady while taking the picture, ensuring that the entire lesion and the coin are captured clearly within the frame.",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Button to start capturing
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to camera page or start capturing process
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageInferencePage(
                          administrationData: administrationData,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Start Capturing",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
