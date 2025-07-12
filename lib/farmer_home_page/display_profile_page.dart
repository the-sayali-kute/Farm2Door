import 'package:flutter/material.dart';
import 'package:forms/farmer_home_page/farm2door_components.dart';

class DisplayProfilePage extends StatefulWidget {
  const DisplayProfilePage({super.key});

  @override
  State<DisplayProfilePage> createState() => _DisplayProfilePageState();
}

class _DisplayProfilePageState extends State<DisplayProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: farm2DoorAppBar('Farmer Profile', Icons.person),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 4, 105, 16),
              //image : DecorationImage(image: AssetImage('assets/profile_background.jpg'),
              //fit: BoxFit.cover),
            ),
          ),
          // Fade Gradient Overlay at bottom
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height:
                    MediaQuery.of(context).size.height / 1, // lower one-third
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromARGB(44, 139, 204, 114),
                      Color.fromARGB(
                        230,
                        247,
                        247,
                        247,
                      ), // or any darkening color
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 80,
            left: 20,
            right: 20,
            child: Card(
              elevation: 15,
              borderOnForeground: true,
              color: const Color.fromARGB(255, 27, 145, 6),
              child: Padding(
                padding: EdgeInsetsGeometry.all(20),
                child: Row(
                  children: [
                    SizedBox(width: 10),
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: ProfileDataCollector.profilePhoto != null
                          ? FileImage(ProfileDataCollector.profilePhoto!)
                          : const AssetImage('assets/user.png')
                                as ImageProvider,
                    ),
                    SizedBox(width: 10),
                    Column(
                      children: [
                        Text(
                          '   Mr. Farmer',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 34,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'ID : 0000000001',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 280,
            left: 20,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
                backgroundBlendMode: BlendMode.overlay,
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  Text(
                    "Address : 06, xyz street ,Nashik ,Maharashtra ",
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Crops: Cotton, Soyabean",
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Area of Proximity : 30 km ",
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Delivery mode : Self",
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Positioned(
            top: 550,
            left: 20,
            right: 20,
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  elevation: 20,
                  padding: EdgeInsets.all(14),
                ),
                onPressed: () {
                  debugPrint('edit profile button clicked');
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit, size: 24, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      'Edit Profile ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      //     bottomNavigationBar:  MyBottomNavigationBar(
      //   currentIndex: 1, // example index, set accordingly
      //   onTap: (index) {
      //     // handle tap if you want
      //   },
      // ),
    );
  }
} 
        
     /* Row(
        children: [
          SizedBox(width: 10,),
           CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[300],
              backgroundImage: ProfileDataCollector.profilePhoto != null
                  ? FileImage(ProfileDataCollector.profilePhoto!)
                  : const AssetImage('assets/default_profile.png') as ImageProvider,
            ),
            SizedBox(width: 10,),
            Column(
              children: [
                Text('Mr. Farmer',
                style :TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
                ),
                SizedBox(height: 10,),
                Text('ID : 0000000001',
                style :TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                ),
              
              ],
            )
        ],
      )*/
       
            
          