import 'package:flutter/material.dart';

// Models
class Order {
  final String title;
  final String status;

  const Order(this.title, this.status);
}

class Listing {
  final String name;
  final String tag;
  final Color tagColor;

  const Listing(this.name, this.tag, this.tagColor);
}

// OrderCard Widget
class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({required this.order, super.key});

  @override
  Widget build(BuildContext context) {
    Color color = {
      'Pending': Colors.red,
      'Delivered': Colors.green,
      'Accepted': Colors.blue
    }[order.status] ?? Colors.black;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(order.title, style: const TextStyle(fontSize: 16)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color),
          ),
          child: Text(order.status, style: TextStyle(color: color)),
        ),
      ],
    );
  }
}

// ListingCard Widget
class ListingCard extends StatelessWidget {
  final Listing listing;

  const ListingCard({required this.listing, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(listing.name, style: const TextStyle(fontSize: 16)),
        Text(listing.tag, style: TextStyle(color: listing.tagColor, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
