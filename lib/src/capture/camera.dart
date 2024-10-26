import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class Camera extends StatefulWidget {
  const Camera({super.key});

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  late CameraController controller;
  bool _isInited = false;

  @override
  void initState() {
    super.initState();

    // Initialize cameras after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final cameras = await availableCameras(); // Fetch available cameras
        controller = CameraController(cameras[0], ResolutionPreset.ultraHigh);

        await controller.initialize();
        setState(() {
          _isInited = true; // Camera initialized successfully
        });
      } catch (e) {
        print("Error initializing camera: $e"); // Handle error here
      }
    });
  }

  @override
  void dispose() {
    // Dispose the camera controller when the widget is removed
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Camera"),
      ),
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Column(
          children: [
            Expanded(
              child: _isInited
                  ? AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: CameraPreview(controller),
                    )
                  : const Center(child: Text("Initializing Camera")),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.camera),
        //TODO
        onPressed: () async {
          // Use Yolo to detect whether lesion and coin is detected

          //If No, Promt a dialog to tell user what is not detected, ask user to try again

          // If Yes, Prompt a dialog to inform user, then upload to storage and start segmentation and lesion size calculation
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
