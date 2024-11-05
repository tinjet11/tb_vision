import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'auth.dart';

class OTPPage extends StatefulWidget {
  const OTPPage({super.key});

  @override
  State<OTPPage> createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  bool isResendAllowed = false;
  int _resendCountdown = 10;
  Timer? _timer;
  bool isFirstLogin = true; // Set this based on login status

  @override
  void initState() {
    super.initState();
    if (isFirstLogin) {
      _startResendCountdown();
    }
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startResendCountdown() {
    setState(() {
      _resendCountdown = 10;
      isResendAllowed = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _resendCountdown--;
      });

      if (_resendCountdown <= 0) {
        timer.cancel();
        setState(() {
          isResendAllowed = true;
        });
      }
    });
  }

  Future<void> _resendOTP(userId, phone) async {
    await sendOTP(userId, phone).then((value) => {
          if (value)
            {
              _startResendCountdown(),
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("OTP sent successfully"),
                  duration: Duration(seconds: 3),
                ),
              ),
            }
          else
            {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Fail to send OTP. Please try again later."),
                  duration: Duration(seconds: 3),
                ),
              ),
            }
        });
  }

  Future<void> _verifyOTP(userId) async {
    String otp = _otpControllers.map((controller) => controller.text).join();
    if (otp.length == 6) {
      // Handle OTP verification
      bool loginSuccessful = await loginWithOTP(userId, otp);

      if (loginSuccessful) {
        Navigator.pushNamed(
          context,
          '/',
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid OTP. Please Try Again'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a 6-digit OTP'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // Dismisses the keyboard
        },
        child: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/otp_illustration.png',
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "OTP Verification",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          "Please enter the 6-digit code sent to your registered number ${userData['phone']}",
                          textAlign: TextAlign.start,
                          style:
                              const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 50,
                        height: 60,
                        child: TextField(
                          controller: _otpControllers[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            counterText: '',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Colors.blue, width: 2),
                            ),
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              if (index < 5) {
                                FocusScope.of(context).nextFocus();
                              }
                            } else if (value.isEmpty && index > 0) {
                              FocusScope.of(context).previousFocus();
                            }
                          },
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isResendAllowed) const Text("Don't receive the OTP?"),
                      TextButton(
                        onPressed: isResendAllowed
                            ? () async {
                                await _resendOTP(
                                    userData["\$id"], userData['phone']);
                              }
                            : null,
                        child: Text(
                          isResendAllowed
                              ? "Resend"
                              : "Resend in $_resendCountdown seconds",
                          style: TextStyle(
                            color: isResendAllowed ? Colors.blue : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await _verifyOTP(userData["\$id"]);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(300, 60),
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Verify OTP",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
