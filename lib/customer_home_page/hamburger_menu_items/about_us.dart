import 'package:flutter/material.dart';
import 'package:forms/customer_home_page/hamburger_menu_items/instagram_gradient_icon.dart';
import 'package:forms/final_vars.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({super.key});

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
          'About Us',
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
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Lottie.asset(
                "assets/animations/about_us.json",
                height: 200,
                repeat: true,
                reverse: false,
                animate: true,
              ),
              const SizedBox(height: 30),
              Text(
                aboutUsContent,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
              Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 20,
              children: [
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.facebook, color: Colors.blue,size: 30,),
                  onPressed: () => launchUrl(Uri.parse("https://facebook.com/farm2door")),
                ),
                const InstagramGradientIcon(),
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.xTwitter, color: Colors.black,size: 30,),
                  onPressed: () => launchUrl(Uri.parse("https://twitter.com/farm2door")),
                ),
                
              ],
            ),
            ],
          ),
        ),
      ),
    );
  }
}
