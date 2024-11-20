import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tb_vision/src/widgets/home/appointment_card.dart';
import 'package:tb_vision/src/widgets/home/assessment_card.dart';
import 'package:tb_vision/src/services/auth/auth.dart';
import 'package:tb_vision/src/widgets/home/progress_bar.dart';
import 'package:tb_vision/src/widgets/home/questionnaire_card.dart';
import 'package:appwrite/appwrite.dart';
import 'package:tb_vision/src/services/database/collection.dart';
import 'package:tb_vision/src/services/database/database_service.dart';
import 'package:tb_vision/src/services/database/model.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late DatabaseService dbService;
  Administration? administrationData;
  Hospital? hospitalData;
  Questionnaire? questionnaireData;
  bool isLoading = true;
  late bool isAnswerEmpty;
  @override
  void initState() {
    super.initState();

    // Initialize DatabaseService
    dbService = DatabaseService(client, collections);
    // Fetch data asynchronously
    fetchAdministrationData();
  }

  Future<void> fetchAdministrationData() async {
    try {
      // Retrieve user ID
      var user = await getUser();
      // Fetch patient document based on user ID
      var result = await dbService.listDocuments(
        'Administration',
        [Query.equal('patient_id', user?.$id)],
      );

      if (result.documents.isNotEmpty) {
        var adminDoc = result.documents.first;
        print(adminDoc.data);
        setState(() {
          administrationData = Administration.fromJson(adminDoc.data);
          questionnaireData = administrationData?.questionnaireData;
          hospitalData = administrationData?.hospitalData;
        });
      }
    } catch (e) {
      //print("Error fetching patient data: $e");
      rethrow;
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App title section
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "TB Vision",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      logoutUser();
                      Navigator.pushReplacementNamed(context, "/login");
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Logout"),
                  ),
                ],
              ),
            ),
            ProgressBar(
              isLoading: isLoading,
              administrationData: administrationData,
            ),
            // Upcoming Appointment section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Upcoming Appointment",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            AppointmentCard(
              administrationData: administrationData,
              hospitalData: hospitalData,
              isLoading: isLoading,
            ),
            const SizedBox(height: 16),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Action Item",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Patient action required. Please complete within the specified deadline.",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            QuestionnaireCard(
              administrationData: administrationData,
              questionnaireData: questionnaireData,
              isLoading: isLoading,
            ),
            AssessmentCard(
              administrationData: administrationData,
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
