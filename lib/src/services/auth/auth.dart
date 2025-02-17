import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:tb_vision/env/env.dart';

Client client = Client()
    .setEndpoint(Env.appwriteEndpoint)
    .setProject(Env.appwriteProjectId);

Account account = Account(client);
var logger = Logger();

Future<bool> sendOTP(userId, phone) async {
  try {
    Account account = Account(client);
    await account.createPhoneToken(
      userId: userId,
      phone: phone,
    );
    return true;
  } catch (e) {
    logger.e("Error sending OTP to user", error: e);
    return false;
  }
}

Future<Map<String, dynamic>?> checkUserExists(String userId) async {
  if (userId == "") {
    return null;
  }

  final userUrl = Uri.parse("${Env.appwriteEndpoint}/users/$userId");

  try {
    final userResponse = await http.get(
      userUrl,
      headers: {
        "Content-Type": "application/json",
        "X-Appwrite-Response-Format": "1.6.0",
        "X-Appwrite-Project": Env.appwriteProjectId,
        "X-Appwrite-Key": Env.appwriteApiKey,
      },
    );
    if (userResponse.statusCode == 200) {
      final userData = json.decode(userResponse.body);
      logger.i("User exists: $userData");
      return userData;
    } else if (userResponse.statusCode == 404) {
      logger.i("User does not exist");
      return null;
    } else {
      logger.i("Error: ${userResponse.body}");
      return null;
    }
  } catch (error) {
    logger.e("Account fetch failed:", error: error);
    return null;
  }
}

Future<bool> loginWithOTP(userId, otp) async {
  try {
    Account account = Account(client);
    final result = await account.createSession(
      userId: userId,
      secret: otp,
    );
    logger.i('Login successful: $result');
    return true;
    // Navigate to home or dashboard
  } catch (e) {
    logger.e('Login failed: $e');
    return false;
  }
}

// check if user session is active or not
Future<bool> checkSessions() async {
  try {
    await account.getSession(sessionId: "current");
    return true;
  } catch (e) {
    logger.e("Error getting session info", error: e);
    return false;
  }
}

// logout the user delete the session
Future logoutUser() async {
  await account.deleteSession(sessionId: "current");
}

// get details of the user logged in
Future<User?> getUser() async {
  try {
    final user = await account.get();
    return user;
  } catch (e) {
    return null;
  }
}
