import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReviewBottomSheet extends StatefulWidget {
  final String productId;

  const ReviewBottomSheet({super.key, required this.productId});

  @override
  State<ReviewBottomSheet> createState() => _ReviewBottomSheetState();
}

class _ReviewBottomSheetState extends State<ReviewBottomSheet> {
  bool _showInput = false;
  double _currentRating = 0;
  final TextEditingController _reviewController = TextEditingController();

  List<Map<String, dynamic>> reviews = [];

  @override
  void initState() {
    super.initState();
    _loadProductReviews();
  }

  Future<void> _loadProductReviews() async {
    final productDoc = await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId)
        .get();

    final data = productDoc.data();
    if (data == null) return;

    final reviewList = List<Map<String, dynamic>>.from(data['reviews'] ?? []);
    final usersCollection = FirebaseFirestore.instance.collection('users');

    final enrichedReviews = await Future.wait(reviewList.map((r) async {
      final userId = r['userId'] ?? '';
      String name = 'User';

      if (userId.isNotEmpty) {
        final userSnap = await usersCollection.doc(userId).get();
        name = userSnap.data()?['name'] ?? 'User';
      }

      return {
        'userId': userId,
        'name': name,
        'review': r['review'],
        'rating': (r['rating'] ?? 0).toDouble(),
      };
    }).toList());

    setState(() {
      reviews = enrichedReviews;
    });
  }

  Future<void> _submitReview() async {
    if (_reviewController.text.trim().isEmpty || _currentRating == 0) return;

    final reviewText = _reviewController.text.trim();
    final rating = _currentRating;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final userId = user.uid;
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
    final productDoc = FirebaseFirestore.instance.collection('products').doc(widget.productId);

    await userDoc.set({
      'review': reviewText,
      'rating': rating,
    }, SetOptions(merge: true));

    final newReview = {
      'review': reviewText,
      'rating': rating,
      'userId': userId,
    };

    await productDoc.update({
      'reviews': FieldValue.arrayUnion([newReview]),
    });

    final userSnap = await userDoc.get();
    final userName = userSnap.data()?['name'] ?? 'You';

    setState(() {
      reviews.add({
        'userId': userId,
        'name': userName,
        'rating': rating,
        'review': reviewText,
      });
      _reviewController.clear();
      _currentRating = 0;
      _showInput = false;
    });
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(5, (index) {
        final i = index + 1;
        return IconButton(
          onPressed: () => setState(() => _currentRating = i.toDouble()),
          icon: Icon(
            _currentRating >= i ? Icons.star : Icons.star_border,
            color: Colors.orange,
          ),
          iconSize: 24,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 1,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const Text("User Reviews", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              const Text("See what others are saying about this product", style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 15),
              !_showInput
                  ? ElevatedButton(
                      onPressed: () => setState(() => _showInput = true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("Add Review", style: TextStyle(color: Colors.white)),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Your Rating:"),
                        _buildStarRating(),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _reviewController,
                                decoration: const InputDecoration(
                                  hintText: 'Write your review...',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.send, color: Colors.green),
                              onPressed: _submitReview,
                            ),
                          ],
                        ),
                      ],
                    ),
              const SizedBox(height: 15),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    final r = reviews[index];
                    return ReviewItem(
                      userId: r['userId'],
                      name: r['name'],
                      rating: r['rating'],
                      review: r['review'],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ReviewItem extends StatelessWidget {
  final String userId;
  final String name;
  final double rating;
  final String review;

  const ReviewItem({
    super.key,
    required this.userId,
    required this.name,
    required this.rating,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(name[0]),
      ),
      title: Text(name),
      subtitle: Text(review),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (index) {
          if (rating >= index + 1) {
            return const Icon(Icons.star, size: 16, color: Colors.orange);
          } else if (rating > index && rating < index + 1) {
            return const Icon(Icons.star_half, size: 16, color: Colors.orange);
          } else {
            return const Icon(Icons.star_border, size: 16, color: Colors.orange);
          }
        }),
      ),
    );
  }
}
