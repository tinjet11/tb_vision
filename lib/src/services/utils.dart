import 'package:intl/intl.dart';
import 'package:tb_vision/src/services/database/model.dart';

class Utils {
  /// Checks if the given [administrationDate] is before the current date.
  static bool hasAdministrationDatePassed(String? administrationDate) {
    try {
      DateTime parsedDate = DateTime.parse(
          administrationDate ?? DateTime.now().toIso8601String());
      return parsedDate.isBefore(DateTime.now());
    } catch (e) {
      // Handle invalid date format
      return false;
    }
  }

  static String getFormattedDate(String? dateTimeString) {
    if (dateTimeString != null && dateTimeString != "") {
      DateTime dateTime = DateTime.parse(dateTimeString);
      return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
    }

    return "";
  }

    /// Adds [days] to a given [dateTimeString] and returns the resulting date.
  static String addDaysToDate(String? dateTimeString, int days) {
    if (dateTimeString != null) {
      try {
        DateTime dateTime = DateTime.parse(dateTimeString);
        DateTime updatedDate = dateTime.add(Duration(days: days));
        return getFormattedDate(updatedDate.toIso8601String()); // Format the updated date
      } catch (e) {
        // Handle any invalid date parsing
        return "";
      }
    }
    return "";
  }


  static bool isQuestionnaireAnswerEmpty(List<String>? answer) {
    return answer == null || answer.isEmpty == true || answer == [];
  }

  static bool isAnalysisEmpty(Analysis? analysis) {
    return analysis == null ;
  }

  static bool isHibernationPeriodPassed(String? recordDateTime) {
    if (recordDateTime != null) {
      final now = DateTime.now();
      final recordDate = DateTime.parse(recordDateTime);

      final today = DateTime(now.year, now.month, now.day);
      final recordDay =
          DateTime(recordDate.year, recordDate.month, recordDate.day);

      final difference = today.difference(recordDay).inDays;

      if (difference >= 2) {
        return true;
      }
    }

    return false;
  }
}
