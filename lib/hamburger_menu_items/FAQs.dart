import 'package:flutter/material.dart';
import 'package:forms/reusables/final_vars.dart';
import 'package:lottie/lottie.dart';

class FAQs extends StatelessWidget {
  const FAQs({super.key});

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
          'FAQs',
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Lottie.asset(
                  "assets/animations/FAQs.json",
                  height: 200,
                  repeat: true,
                  reverse: false,
                  animate: true,
                  
                ),
              ),
              const SizedBox(height: 20),
              ListView(
                shrinkWrap:
                    true, // ✅ Required to prevent unbounded height error
                physics:
                    NeverScrollableScrollPhysics(), // ✅ Prevent nested scrolling
                children: faqs
                    .map(
                      (faq) => ExpansionTile(
                        title: Text(
                          faq['question']!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(faq['answer']!),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
