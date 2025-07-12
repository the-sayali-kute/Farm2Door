import 'package:flutter/material.dart';
import 'package:forms/authentication/db_functions.dart';

class ProductGenerator extends StatelessWidget {
  const ProductGenerator({super.key});

  @override
  Widget build(BuildContext context) {
    final productNameController = TextEditingController();
    final mrpController = TextEditingController();
    final priceController = TextEditingController();
    final ratingController = TextEditingController();
    final qtyController = TextEditingController();
    final imgController = TextEditingController();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TextField(
              controller: productNameController,
              decoration: InputDecoration(
                hintText: "Enter your product name",
              ),
            ),
            TextField(
              controller: mrpController,
              decoration: InputDecoration(
                hintText: "mrp",
              ),
            ),
            TextField(
              controller: priceController,
              decoration: InputDecoration(
                hintText: "price",
              ),
            ),
            TextField(
              controller: ratingController,
              decoration: InputDecoration(
                hintText: "rating",
              ),
            ),
            TextField(
              controller: qtyController,
              decoration: InputDecoration(
                hintText: "qty",
              ),
            ),
            TextField(
              controller: imgController,
              decoration: InputDecoration(
                hintText: "img",
              ),
            ),
            ElevatedButton(
              onPressed: () {
                storeProductDetails(
                  productName: productNameController.text,
                  mrp: mrpController.text,
                  price: priceController.text,
                  rating: ratingController.text,
                  qty: qtyController.text,
                  img: imgController.text,
                );
              },
              child: Text("Generate"),
            ),
          ],
        ),
      ),
    );
  }
}