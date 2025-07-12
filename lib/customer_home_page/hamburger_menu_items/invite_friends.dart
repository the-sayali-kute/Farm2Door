import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:forms/final_vars.dart';
import 'package:lottie/lottie.dart';

class InviteFriends extends StatelessWidget {
  const InviteFriends({super.key});
 // You can generate dynamically too

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Invite Friends",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: "Nunito",
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        flexibleSpace: Container(decoration: BoxDecoration(gradient: gradient)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Lottie.asset(
              "assets/animations/invite_friends.json",
              height: 200,
              repeat: true,
              reverse: false,
              animate: true,
            ),

            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                children: [
                  Text(
                    "Help your friends discover fresh and quality produce directly from local farmers. 🌾",
                    // textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "By sharing this app, you're supporting a better food system!",
                    // textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),
            // Share App Button
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: gradient,
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  Share.share(
                    "Hey! Download this amazing app and use my referral code  to sign up! 🚀\n\n👉 https://yourapp.link",
                    subject: "Join me on this app!",
                  );
                },
                icon: const Icon(Icons.share, color: Colors.white),
                label: const Text(
                  "Share App",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: TextButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
