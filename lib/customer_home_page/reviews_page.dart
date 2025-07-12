/*import 'package:flutter/material.dart';
import 'package:forms/customer_home_page/appbar.dart';

class ReviewsPage extends StatelessWidget {
  const ReviewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
        context,
        title: "Reviews",
        
      ),
      body: Column(
        children: [
          Text("Reviews"),
        ],
      ),
    );
  }
}*/


import 'package:flutter/material.dart';

class ReviewBottomSheet extends StatefulWidget {
  const ReviewBottomSheet({super.key});

  @override
  State<ReviewBottomSheet> createState() => _ReviewBottomSheetState();
}

class _ReviewBottomSheetState extends State<ReviewBottomSheet> {
  bool _showInput = false;
  double _currentRating = 0;
  final TextEditingController _reviewController = TextEditingController();

  List<Map<String, dynamic>> reviews = [];

  void _submitReview() {
    if (_reviewController.text.trim().isEmpty || _currentRating == 0) return;

    setState(() {
      reviews.add({
        'userId': '001',
        'name': 'You',
        'rating': _currentRating,
        'review': _reviewController.text.trim(),
      });
      _reviewController.clear();
      _currentRating = 0;
      _showInput = false;

        // ⬇️ Print the review to the terminal (controller logic)
      print('Review Added:');
      print('User ID: ${reviews[0]}');
      print('User Name: ${reviews[1]}');
      print('Rating: ${reviews[2]}');
      print('Review: ${reviews[3]}');

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

              // Toggle Review Input Section
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
                      child: const Text("Add Review",style: TextStyle(color: Colors.white),),
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






//list tile for individual reviews

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
        children: List.generate(
          5,
          (index) {
            if (rating >= index + 1) {
              return const Icon(Icons.star, size: 16, color: Colors.orange);
            } else if (rating > index && rating < index + 1) {
              return const Icon(Icons.star_half, size: 16, color: Colors.orange);
            } else {
              return const Icon(Icons.star_border, size: 16, color: Colors.orange);
            }
          },
        ),
      ),
    );
  }
}