import 'package:flutter/material.dart';
import 'package:forms/customer_home_page/cart/inputs.dart';
import 'package:forms/customer_home_page/product_details.dart';

class ProductCard extends StatefulWidget {
  final String path;
  final String productId;
  final String productName;
  final String harvestedDate;
  final String farmerId;
  final String sellingPrice;
  final String stock;
  final String mrp;
  final String discountPercent;
  final String unit;
  // final bool isunder500meters;
  const ProductCard({
    super.key,
    required this.path,
    required this.productId,
    required this.productName,
    required this.harvestedDate,
    required this.farmerId,
    required this.stock,
    required this.sellingPrice,
    required this.discountPercent,
    required this.unit,
    required this.mrp,
    // required this.isunder500meters,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsPage(
              productName: widget.productName,
              productId: widget.productId,
              path: widget.path,
              sellingPrice: widget.sellingPrice,
              mrp: widget.mrp,
              unit: widget.unit,
              farmerId: widget.farmerId,
              harvestedDate: widget.harvestedDate,
              discountPercent: widget.discountPercent,
              stock: widget.stock,
            ),
          ),
        );
      },
      child: Container(
        // aspect ratio =  width/height = 110/250 = 0.44
        height: 250,
        width: 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // stack allows widgets to be stacked/placed on top of each other
            buildImgStack(widget.path, context, widget.productId,widget.productName,widget.unit,widget.sellingPrice,widget.farmerId,widget.mrp),

            SizedBox(height: 10),
            Row(
              children: [
                Text(
                  "₹${widget.sellingPrice}",
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                SizedBox(width: 5),
                Text(
                  "₹${widget.mrp}",
                  style: TextStyle(
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            Text(widget.unit.contains("gm") ? widget.unit : "1 ${widget.unit}"),
            Text(
              widget.productName,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "SAVE ₹${double.parse(widget.mrp).toInt() - double.parse(widget.sellingPrice).toInt()}",
              style: TextStyle(
                color: Color.fromRGBO(80, 140, 86, 1),
                fontWeight: FontWeight.w900,
              ),
            ),
            // Container(
            //   padding: EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
            //   decoration: BoxDecoration(
            //     borderRadius: BorderRadius.circular(10),
            //     color: const Color.fromARGB(255, 212, 234, 185),
            //   ),
            //   child: Row(
            //     mainAxisSize: MainAxisSize.min,
            //     children: [
            //       Icon(Icons.star, color: Colors.green, size: 15),
            //       Text("rating"),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}


