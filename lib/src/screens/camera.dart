import 'dart:io' as io;

import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tb_vision/src/services/auth/auth.dart';
import 'package:tb_vision/src/services/database/collection.dart';
import 'package:tb_vision/src/services/database/database_service.dart';
import 'package:tb_vision/src/services/database/model.dart';
import 'package:tb_vision/src/services/storage/bucket.dart';
import 'package:tb_vision/src/services/storage/storage_service.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import 'package:ultralytics_yolo/yolo_model.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

class ImageInferencePage extends StatefulWidget {
  final Administration administrationData;
  const ImageInferencePage({super.key, required this.administrationData});

  @override
  State<ImageInferencePage> createState() => _ImageInferencePageState();
}

class _ImageInferencePageState extends State<ImageInferencePage> {
  late ObjectDetector objectDetector;
  XFile? _imageFile;
  List<DetectedObject?>? _detections;
  bool isLesionDetected = false;
  bool isCoinDetected = false;
  late DatabaseService dbService;
  late StorageService storageService;

  @override
  void initState() {
    super.initState();
    _initObjectDetectorWithLocalModel();
    dbService = DatabaseService(client, collections);
    storageService = StorageService(client, buckets);
  }

  Future<String> _copy(String assetPath) async {
    final path = '${(await getApplicationSupportDirectory()).path}/$assetPath';
    await io.Directory(dirname(path)).create(recursive: true);
    final file = io.File(path);
    if (!await file.exists()) {
      final byteData = await rootBundle.load(assetPath);
      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    }
    return file.path;
  }

  Future<void> _initObjectDetectorWithLocalModel() async {
    try {
      final modelPath = await _copy('assets/best.mlmodel');
      final model = LocalYoloModel(
        id: '',
        task: Task.detect,
        format: Format.coreml,
        modelPath: modelPath,
      );
      setState(() {
        objectDetector = ObjectDetector(model: model);
      });
      await objectDetector.loadModel();
      print("Object detector initialized successfully");
    } catch (e) {
      print("Error during initialize object detector");
      rethrow;
    }
  }

  Future<void> _runObjectDetection(XFile image) async {
    final detections = await objectDetector.detect(imagePath: image.path);
    print("Detections: $detections");
    setState(() {
      _detections =
          detections; // Check for lesion and coin labels in the detections
      isLesionDetected =
          _detections!.any((detection) => detection?.label == 'lesion');
      isCoinDetected =
          _detections!.any((detection) => detection?.label == 'coin');
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
        _detections = null; // Clear previous detections.
      });

      _runObjectDetection(pickedFile);
    }
  }

  Future<void> _verifyAndSubmit(BuildContext ctx) async {
    if (_detections != null && _detections!.isNotEmpty) {
      // Check if any detected object has the label "lesion"
      final hasLesion =
          _detections!.any((detection) => detection?.label == 'lesion');

      if (hasLesion) {
        print("Lesion detected!");
        // Perform actions if lesion is found

        await uploadImage();
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(
            content: Text("Analysis submitted successfully!"),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.greenAccent,
          ),
        );
      } else {
        // Perform actions if lesion is not found
        print("No lesion detected.");
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(
            content: Text("No lesion detected. Try Again"),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } else {
      print("No detections available.");
      // Handle case where no detections exist

      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(
          content: Text("No lesion detected. Try Again"),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> uploadImage() async {
    try {
      // Generate a unique ID for the image
      String imageId = ID.unique();

      // Upload the image to the storage bucket
      await storageService.createFile(
        "Analysis",
        InputFile.fromPath(path: _imageFile!.path),
        fileId: imageId,
      );
      print("Image uploaded successfully with ID: $imageId");

      // Create the analysis document with the uploaded image ID
      await createAnalysis(imageId);
    } catch (e) {
      print("Error during image upload: ${e.toString()}");
    }
  }

  Future<void> createAnalysis(String imageId) async {
    var payload = {
      "original_image_id": imageId,
    };

    try {
      // Create a document in the database for analysis
      final document = await dbService.createDocument("Analysis", payload);
      print("Analysis document created successfully with ID: ${document.$id}");
      await addAnalysisToAdministration(document.$id);
    } catch (e) {
      print("Error during analysis document creation: ${e.toString()}");
    }
  }

  Future<void> addAnalysisToAdministration(String analysisId) async {
    var payload = {
      "analysis": analysisId,
    };

    try {
      // Create a document in the database for analysis
      await dbService.updateDocument(
          "Administration", widget.administrationData.id, payload);
      print("Administration document updated successfully");
    } catch (e) {
      print("Error during administration document update: ${e.toString()}");
    }
  }

  Widget _buildDetectionIndicator(String label, bool detected) {
    return Row(
      children: [
        Icon(
          detected ? Icons.check_circle : Icons.cancel,
          color: detected ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 8),
        Text(
          "$label: ${detected ? 'Detected' : 'Not Detected'}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: detected ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Inference"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Status indicators
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDetectionIndicator("Lesion", isLesionDetected),
                  _buildDetectionIndicator("Coin", isCoinDetected),
                ],
              ),
            ),
            if (_imageFile != null)
              Column(
                children: [
                  Stack(
                    children: [
                      Image.file(
                        io.File(_imageFile!.path),
                        height: 300,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                      if (_detections != null)
                        ..._detections!.map((detection) {
                          final rect = detection?.boundingBox;
                          return Positioned(
                            left: rect?.left,
                            top: rect?.top,
                            width: rect?.width,
                            height: rect?.height,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.red, width: 2),
                              ),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Container(
                                  color: Colors.red,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 2),
                                  child: Text(
                                    detection!.label,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ],
              )
            else
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  "Pick or capture an image to start detection",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo),
                    label: const Text("Pick Image",
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      iconColor: Colors.white,
                      backgroundColor: Colors.deepPurple,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Capture Image",
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      iconColor: Colors.white,
                      backgroundColor: Colors.deepPurple,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _verifyAndSubmit(context),
                    icon: const Icon(Icons.check_circle),
                    label: const Text("Submit",
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      iconColor: Colors.white,
                      backgroundColor: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}