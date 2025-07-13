import 'package:flutter/material.dart';
import 'package:forms/customer_home_page/search_page.dart';
import 'package:forms/customer_home_page/wishlist/wishlist_page.dart';
import 'package:forms/farmer_home_page/add_product_page.dart';
import 'package:forms/final_vars.dart';

AppBar appBar(
  BuildContext context, {
  String? title,
  bool hamburger = false,
  bool logo = false,
  bool search = false,
  bool add = false,
  bool wishlist = false,
  bool backBtn = false,
}) {
  return AppBar(
    elevation: 0,
    toolbarHeight: 70,
    leading: hamburger
        ? Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.person_2_outlined), 
              color: Colors.white,
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          )
        : null,
    flexibleSpace: Container(decoration: BoxDecoration(gradient: gradient)),
    actions: [
      if (wishlist)
        IconButton(
          icon: Icon(Icons.favorite_border, size: 28),
          color: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WishlistPage()),
            );
          },
        ),
      if (search)
        IconButton(
          icon: Icon(Icons.search_rounded, size: 28),
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return SearchPage();
                },
              ),
            );
          },
        ),
      if (add)
        IconButton(
          icon: Icon(Icons.add_outlined, size: 28),
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return AddProductPage();
                },
              ),
            );
          },
        ),
      SizedBox(width: 8),
    ],
    title: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (logo)
          Container(
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Image.asset(
                "assets/images/image.png",
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
          ),
        SizedBox(width: 12),
        Text(
          title ?? "Farm2Door",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: "Nunito",
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    ),
    centerTitle: true,
    automaticallyImplyLeading: false,
  );
}
