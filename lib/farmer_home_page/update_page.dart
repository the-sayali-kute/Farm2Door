import 'package:flutter/material.dart';
import 'package:forms/farmer_home_page/farm2door_components.dart';
import 'package:forms/farmer_home_page/updates_screen_components.dart';

class UpdatePage extends StatefulWidget {
  const UpdatePage({super.key});

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  String selectedCategory = 'All'; // Now selectedCategory is defined and managed by state!

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: farm2DoorAppBar('Updates', Icons.update),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Chips Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  UpdateFilterChip(
                    label: 'All',
                    selected: selectedCategory == 'All',
                    onTap: () {
                      setState(() => selectedCategory = 'All');
                    },
                  ),
                  const SizedBox(width: 8),
                  UpdateFilterChip(
                    label: 'Weather',
                    selected: selectedCategory == 'Weather',
                    onTap: () {
                      setState(() => selectedCategory = 'Weather');
                    },
                  ),
                  const SizedBox(width: 8),
                  UpdateFilterChip(
                    label: 'Schemes',
                    selected: selectedCategory == 'Schemes',
                    onTap: () {
                      setState(() => selectedCategory = 'Schemes');
                    },
                  ),
                  const SizedBox(width: 8),
                  UpdateFilterChip(
                    label: 'Markets',
                    selected: selectedCategory == 'Markets',
                    onTap: () {
                      setState(() => selectedCategory = 'Markets');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Updates List
            Expanded(
              child: ListView(
                children: [
                  const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Weather Updates',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),                  UpdateCard(
        color: Colors.green[100]!,
        icon: Icons.cloud,
        title: 'Weather Alert',
        subtitle: 'Rain expected tomorrow afternoon. Humidity: 78%.',
        onMarkRead: () {
          print('Marked Weather Alert as read');
        },
        onSave: () {
          print('Saved Weather Alert');
        },
        onShare: () {
          print('Shared Weather Alert');
        },
      ),
      UpdateCard(
        color: Colors.blue[100]!,
        icon: Icons.thermostat,
        title: 'Temperature Update',
        subtitle: 'Max temp: 32°C, Min temp: 23°C for next 3 days.',
        onMarkRead: () {
          print('Marked Temperature Update as read');
        },
        onSave: () {
          print('Saved Temperature Update');
        },
        onShare: () {
          print('Shared Temperature Update');
        },
      ),

      // Section 2 - Government Schemes
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Government Schemes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      UpdateCard(
        color: Colors.yellow[100]!,
        icon: Icons.campaign,
        title: 'PM-Kisan Scheme Update',
        subtitle: '₹6000 yearly direct benefit credited to bank.',
        onMarkRead: () {
          print('Marked PM-Kisan as read');
        },
        onSave: () {
          print('Saved PM-Kisan');
        },
        onShare: () {
          print('Shared PM-Kisan');
        },
      ),
      UpdateCard(
        color: Colors.amber[100]!,
        icon: Icons.attach_money,
        title: 'Fertilizer Subsidy',
        subtitle: '50% subsidy available on organic fertilizers.',
        onMarkRead: () {
          print('Marked Fertilizer Subsidy as read');
        },
        onSave: () {
          print('Saved Fertilizer Subsidy');
        },
        onShare: () {
          print('Shared Fertilizer Subsidy');
        },
      ),

      // Section 3 - Market Trends
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Market Trends',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      UpdateCard(
        color: Colors.orange[100]!,
        icon: Icons.show_chart,
        title: 'Tomato Price Surge',
        subtitle: 'Tomato prices up 20% this week in Pune Mandi.',
        onMarkRead: () {
          print('Marked Tomato Price as read');
        },
        onSave: () {
          print('Saved Tomato Price');
        },
        onShare: () {
          print('Shared Tomato Price');
        },
      ),
      UpdateCard(
        color: Colors.deepOrange[100]!,
        icon: Icons.trending_down,
        title: 'Onion Price Drop',
        subtitle: 'Onion prices down 10% in Mumbai markets.',
        onMarkRead: () {
          print('Marked Onion Price as read');
        },
        onSave: () {
          print('Saved Onion Price');
        },
        onShare: () {
          print('Shared Onion Price');
        },
      ),

      // Section 4 - Farming Tips
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Farming Tips',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      UpdateCard(
        color: Colors.greenAccent[100]!,
        icon: Icons.eco,
        title: 'Crop Rotation Tip',
        subtitle: 'Rotate crops every season to improve soil fertility.',
        onMarkRead: () {
          print('Marked Crop Rotation Tip as read');
        },
        onSave: () {
          print('Saved Crop Rotation Tip');
        },
        onShare: () {
          print('Shared Crop Rotation Tip');
        },
      ),
      UpdateCard(
        color: Colors.lightGreen[100]!,
        icon: Icons.bug_report,
        title: 'Pest Control Tip',
        subtitle: 'Use neem oil spray for organic pest control.',
        onMarkRead: () {
          print('Marked Pest Control Tip as read');
        },
        onSave: () {
          print('Saved Pest Control Tip');
        },
        onShare: () {
          print('Shared Pest Control Tip');
        },
      ),
    ],
  ),
),
                ],
              ),
            ),
    );
  }
}
