import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    dbService = DatabaseService(client, collections);
    fetchAdministrationData();
  }

  Future<void> fetchAdministrationData() async {
    setState(() {
      isLoading = true;
    });

    try {
      var user = await getUser();
      var result = await dbService.listDocuments(
        'Administration',
        [Query.equal('patient', user?.$id)],
      );

      if (result.documents.isNotEmpty) {
        var patientDoc = result.documents.first;
        setState(() {
          administrationData = Administration.fromJson(patientDoc.data);
          questionnaireData = administrationData?.questionnaireData;
          hospitalData = administrationData?.hospitalData;
        });
      }
    } catch (e) {
      logger.e("Error fetching patient data: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: RefreshIndicator(
        onRefresh: fetchAdministrationData, // Pull-to-refresh
        child: SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(), // Allows scroll even if content is short
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "TB Vision",
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
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
                  isLoading: isLoading, administrationData: administrationData),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  "Upcoming Appointment",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Patient action required. Please complete within the specified deadline.",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey.shade600),
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
      ),
    );
  }
}
