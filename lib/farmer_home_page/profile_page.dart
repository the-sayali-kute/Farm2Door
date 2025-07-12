import 'package:flutter/material.dart';
import 'package:forms/farmer_home_page/farm2door_components.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: farm2DoorAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFa8e063), // light green
              Color(0xFF56ab2f),
            ], // cyan to indigo
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
           
          ),
        ),
         child :SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 20,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.arrow_back_outlined),
                    SizedBox(width: 10),
                    Text('Create Profile',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                  ]),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TitleText(title: 'Address'),
                        SizedBox(height: 10),
                        AddressContainer(),
                        SizedBox(height: 10),
                        TitleText(title: 'Type of Product'),
                        SizedBox(height: 10),
                        ProductTypeSelector(),
                        SizedBox(height: 10),
                        TitleText(title: 'Area Proximity'),
                        SizedBox(height: 10),
                        AreaProximitySelector(),
                        SizedBox(height: 10),
                        TitleText(title: 'Type of Delivery'),
                        SizedBox(height: 10),
                        TypeOfDeliverySelector(),
                        SizedBox(height: 20),
                        SelectProfilePhoto(),
                        SizedBox(height: 10),
                        CreateProfileButton(
                          onPressed: () {
                            ProfileDataCollector.collectAndPrintProfileData();
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}
