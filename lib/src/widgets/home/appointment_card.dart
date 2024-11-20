import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tb_vision/src/screens/capture_instructions_screen.dart';
import 'package:tb_vision/src/services/database/model.dart';
import 'package:tb_vision/src/services/utils.dart';

class AppointmentCard extends StatefulWidget {
  final Administration? administrationData;
  final Hospital? hospitalData;
  final bool isLoading;

  const AppointmentCard({
    super.key,
    required this.administrationData,
    required this.isLoading,
    this.hospitalData,
  });

  @override
  State<AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard> {

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: widget.isLoading,
      child: Utils.hasAdministrationDatePassed(
                  widget.administrationData?.datetime) ||
              widget.isLoading == true
          ? const Center(child: Text("No upcoming appointment found."))
          : Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              shadowColor: Colors.black.withOpacity(0.1),
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Section
                    Text(
                      widget.hospitalData?.name ??
                          "Unable to load hospital name",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Text(
                      widget.administrationData?.datetime != null
                          ? "On ${Utils.getFormattedDate(widget.administrationData!.datetime)}"
                          : "Unable to load appointment time",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Skeleton.ignore(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CaptureInstructionsScreen(
                                    administrationData:
                                        widget.administrationData!,
                                  ),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: const Color(0xFF003366),
                              side: const BorderSide(
                                  color: Color(0xFF003366), width: 1.5),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
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
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
