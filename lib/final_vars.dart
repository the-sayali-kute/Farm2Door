import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forms/customer_home_page/hamburger_menu_items/FAQs.dart';
import 'package:forms/customer_home_page/hamburger_menu_items/about_us.dart';
import 'package:forms/customer_home_page/hamburger_menu_items/delete_account.dart';
import 'package:forms/customer_home_page/hamburger_menu_items/invite_friends.dart';
import 'package:forms/customer_home_page/hamburger_menu_items/logout.dart';
import 'package:forms/customer_home_page/hamburger_menu_items/privacy_policy.dart';
import 'package:forms/customer_home_page/hamburger_menu_items/terms_and_conditions.dart';

final gradient = LinearGradient(
  colors: [
    Color.fromRGBO(123, 182, 97, 1), // Fresh leaf green
    Color.fromRGBO(76, 163, 48, 1), // Natural green
    Color.fromRGBO(44, 94, 30, 1), // Deep forest green
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  stops: [0.0, 0.5, 1.0],
  tileMode: TileMode.clamp,
);


final buttonStyle = TextButton.styleFrom(
  backgroundColor: Colors.black,
  foregroundColor: Colors.white,
  minimumSize: Size(double.infinity, 50),
);

final buttonTextStyle = TextStyle(
  fontFamily: "Nunito",
  fontSize: 15,
  fontWeight: FontWeight.bold,
);

final border = OutlineInputBorder(
  borderSide: BorderSide(color: Colors.black),
  borderRadius: BorderRadius.circular(10),
);

final loading = (BuildContext context) => showDialog(
  context: context,
  barrierDismissible: false,
  builder: (context) => Center(child: CircularProgressIndicator()),
);

final inputFormatters = [
  FilteringTextInputFormatter.digitsOnly,
  LengthLimitingTextInputFormatter(10),
];

final List<Map<String, String>> faqs = [
  {
    "question": "What is Farm2Door?",
    "answer": "Farm2Door is a platform that connects local farmers directly with customers within a 10km radius, enabling you to buy fresh farm products without middlemen."
  },
  {
    "question": "How does Farm2Door work?",
    "answer": "You can browse available products from nearby farmers, add them to your cart, and place an order. The farmer will then contact you directly to coordinate delivery or pickup."
  },
  {
    "question": "Does Farm2Door deliver the products?",
    "answer": "No, Farm2Door does not provide delivery services. The farmer will contact you after the order is placed to arrange delivery."
  },
  {
    "question": "How will I receive my order?",
    "answer": "The farmer will contact you to finalize delivery or pickup details. You can mutually decide how the product will reach you."
  },
  {
    "question": "Is there any delivery charge?",
    "answer": "Delivery charges, if any, are decided by the farmer. Some may offer free delivery, while others may charge a small fee."
  },
  {
    "question": "Can I cancel my order?",
    "answer": "Yes, since the order is not prepaid, you can cancel it by contacting the farmer directly. Please cancel responsibly."
  },
  {
    "question": "Is online payment available?",
    "answer": "Currently, all payments are handled offline between you and the farmer. Online payment may be supported in the future."
  },
  {
    "question": "How do I trust the farmer's product quality?",
    "answer": "You can check ratings and reviews from other customers. We encourage fair feedback to maintain quality and trust."
  },
  {
    "question": "What if the farmer doesn’t contact me after placing an order?",
    "answer": "You can try contacting the farmer from the order page. If the issue persists, report it through the app."
  },
  {
    "question": "Can I share this app with friends and family?",
    "answer": "Yes! You can invite friends using the 'Invite Friends' section in the menu and help them discover fresh, local produce."
  },
];

final List<Map<String, String>> privacyPolicy = [
  {
    "title": "1. Data We Collect",
    "content":
        "We collect essential user information including name, email address, phone number, and real-time location to facilitate local connections between farmers and consumers."
  },
  {
    "title": "2. Purpose of Data Collection",
    "content":
        "Your data is collected to match you with farmers within a 10 km radius, enable seamless communication, and personalize your in-app experience."
  },
  {
    "title": "3. Location Tracking",
    "content":
        "Your current location is collected only once during login to match you with nearby farmers. We do not continuously track or share your live location."
  },
  {
    "title": "4. Firebase Authentication",
    "content":
        "We use Firebase Authentication to securely log users in using email and password. Firebase handles credentials securely and we never store raw passwords."
  },
  {
    "title": "5. Data Storage & Security",
    "content":
        "All data is securely stored on Google Firebase Firestore. We follow best practices to prevent unauthorized access, including Firestore rules and Google-backed infrastructure."
  },
  {
    "title": "6. Data Sharing",
    "content":
        "We do not share your personal data or location with third parties. Your data is only used within the app to enable intended features."
  },
  {
    "title": "7. Communication",
    "content":
        "We may send you essential updates about your account or product availability in your area. We do not send promotional emails or SMS without consent."
  },
  {
    "title": "8. User Control",
    "content":
        "You have full control over your data. You may request to update or delete your account and associated data by emailing us at farm2door.help@gmail.com."
  },
  {
    "title": "9. Children’s Privacy",
    "content":
        "Farm2Door is intended for users aged 13 and above. We do not knowingly collect personal data from children under 13."
  },
  {
    "title": "10. Retention Policy",
    "content":
        "We retain your data as long as your account is active or as required for compliance purposes. Upon deletion, your data is permanently removed from our database."
  },
  {
    "title": "11. External Links",
    "content":
        "Our app does not currently contain external links or advertisements that collect data through third-party SDKs."
  },
  {
    "title": "12. Updates to this Policy",
    "content":
        "We may revise this Privacy Policy from time to time. Continued use of the app implies acceptance of the updated policy."
  },
  {
    "title": "13. Contact Us",
    "content":
        "For questions or concerns about this Privacy Policy, contact us at farm2door.help@gmail.com."
  },
];

final List<Map<String, String>> termsAndConditions = [
  {
    "title": "1. Acceptance of Terms",
    "content":
        "By using Farm2Door, you agree to comply with and be legally bound by these Terms & Conditions. If you do not agree, please do not use the app."
  },
  {
    "title": "2. Nature of the Platform",
    "content":
        "Farm2Door is a digital platform that connects local farmers and consumers within a 10 km radius. We facilitate product listings and communication, but we do not handle payments, delivery, or logistics."
  },
  {
    "title": "3. User Eligibility",
    "content":
        "You must be at least 13 years old to create an account on Farm2Door. By registering, you confirm that you meet this requirement."
  },
  {
    "title": "4. Account Responsibility",
    "content":
        "Users are responsible for maintaining the confidentiality of their login credentials. Farm2Door is not liable for any unauthorized access resulting from user negligence."
  },
  {
    "title": "5. Accuracy of Information",
    "content":
        "Users agree to provide accurate and updated information during registration and when uploading products (for farmers). Misleading or false information may lead to account suspension."
  },
  {
    "title": "6. User Conduct",
    "content":
        "You agree not to misuse the app in any way including spam, harassment, abuse, or illegal activity. Violations may result in permanent ban."
  },
  {
    "title": "7. Product Responsibility",
    "content":
        "All product details (including price, quantity, and availability) are posted by farmers. Farm2Door does not verify or guarantee product quality or pricing."
  },
  {
    "title": "8. Communication Between Users",
    "content":
        "Farm2Door enables communication between consumers and farmers through basic contact and notification mechanisms. Any agreements or transactions made offline are the responsibility of the involved parties."
  },
  {
    "title": "9. Location Usage",
    "content":
        "Your location is accessed once at login to show you farmers in your nearby area. We do not track your live location after login."
  },
  {
    "title": "10. Intellectual Property",
    "content":
        "All content, logos, and design elements of the Farm2Door app are owned by the Farm2Door team and protected by applicable copyright laws."
  },
  {
    "title": "11. Limitation of Liability",
    "content":
        "Farm2Door is not liable for any direct or indirect loss or damage resulting from app usage, including disputes between users or failed transactions."
  },
  {
    "title": "12. Account Suspension",
    "content":
        "We reserve the right to suspend or terminate accounts that violate these terms, engage in harmful behavior, or attempt to manipulate the system."
  },
  {
    "title": "13. Modifications to Terms",
    "content":
        "We may update these Terms from time to time. Continued use of the app indicates your acceptance of any updated terms."
  },
  {
    "title": "14. Contact Information",
    "content":
        "For questions or legal concerns related to these Terms, email us at farm2door.help@gmail.com."
  },
];

final List<Map<String,dynamic>> menuItems = [
  {
    "title": "Invite Friends",
    "onTap": (BuildContext context) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>InviteFriends()));
    },
  },
  {
    "title": "FAQs",
    "onTap": (BuildContext context) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>FAQs()));
    },
  },
  {
    "title": "Rate Us",
    "onTap": (BuildContext context) {
      //  Navigator.of(context).push(MaterialPageRoute(builder: (context)=>PrivacyPolicy()));
    },
  },
  {
    "title": "Privacy Policy",
    "onTap": (BuildContext context) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>PrivacyPolicy()));
    },
  },
  {
    "title": "Terms & Conditions",
    "onTap": (BuildContext context) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>TermsAndConditions()));
    },
  },
  {
    "title": "About Us",
    "onTap": (BuildContext context) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>AboutUs()));
    },
  },
  {
    "title": "Delete Account",
    "onTap": (BuildContext context) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>DeleteAccount()));
    },
  },
  {
    "title": "Log Out",
    "onTap": (BuildContext context) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>LogOut()));
    },
  },
];

final String aboutUsContent = '''
Farm2Door is a community-driven platform that bridges the gap between local farmers and nearby consumers — directly, transparently, and affordably.

Our mission is simple: empower farmers by giving them a digital voice, and enable consumers to buy fresh, local produce straight from the source — all within a 10 km radius.

Built with love ❤️ by a passionate student team
''';

final formKey = GlobalKey<FormState>();
final emailController = TextEditingController();
final passwordController = TextEditingController();
final phoneController = TextEditingController();
final fullNameController = TextEditingController();
final addressController = TextEditingController();
final firstNameController = TextEditingController();
final lastNameController = TextEditingController();