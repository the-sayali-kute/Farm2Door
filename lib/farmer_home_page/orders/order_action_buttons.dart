import 'package:flutter/material.dart';

class OrderActionButtons extends StatefulWidget {
  final Future<void> Function() onAccept;
  final Future<void> Function() onReject;
  final Future<void> Function() onGetLocation;
  final Future<void> Function() onCompleted;
  final String status;

  const OrderActionButtons({
    super.key,
    required this.onAccept,
    required this.onReject,
    required this.onGetLocation,
    required this.onCompleted,
    required this.status,
  });

  @override
  State<OrderActionButtons> createState() => _OrderActionButtonsState();
}

class _OrderActionButtonsState extends State<OrderActionButtons> {
  late String _status;

  @override
  void initState() {
    super.initState();
    _status = widget.status;
  }

  void _handleAccept() async {
    await widget.onAccept(); // wait for Firestore update
    setState(() => _status = 'accepted');
  }

  void _handleReject() async {
    await widget.onReject(); // wait for Firestore update
    setState(() => _status = 'rejected');
  }

  void _handleCompleted() async {
    await widget.onCompleted(); // wait for Firestore update
    setState(() => _status = 'completed');
  }

  @override
  Widget build(BuildContext context) {
    if (_status == "pending") {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _handleReject,
              icon: const Icon(Icons.cancel),
              label: const Text("Reject"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _handleAccept,
              icon: const Icon(Icons.check_circle),
              label: const Text("Accept"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      );
    } else if (_status == "accepted") {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton.icon(
            onPressed: widget.onGetLocation,
            icon: const Icon(Icons.location_on),
            label: const Text("Get Location"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _handleCompleted,
            icon: Icon(Icons.done_all),
            label: Text("Completed"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      );
    } else if (_status == "rejected") {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cancel, color: Colors.red),
            SizedBox(width: 8),
            Text(
              "Order Rejected",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    } else if (_status == "completed") {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.done, color: Colors.green),
            SizedBox(width: 8),
            Text(
              "Order Completed",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}


    // ✅ Accepted: Show Get Location Button
    // if (_status == 'accepted') {
    //   return Center(
    //     child: ElevatedButton.icon(
    //       onPressed: widget.onGetLocation,
    //       icon: const Icon(Icons.location_on),
    //       label: const Text("Get Location"),
    //       style: ElevatedButton.styleFrom(
    //         backgroundColor: Colors.blue,
    //         foregroundColor: Colors.white,
    //         padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
    //         shape: RoundedRectangleBorder(
    //           borderRadius: BorderRadius.circular(12),
    //         ),
    //         textStyle: const TextStyle(
    //           fontWeight: FontWeight.bold,
    //           fontSize: 16,
    //         ),
    //       ),
    //     ),
    //   );
    // }


    // ⏳ Pending: Show Accept + Reject Buttons
    // return Row(
    //   children: [
    //     Expanded(
    //       child: ElevatedButton.icon(
    //         onPressed: _handleReject,
    //         icon: const Icon(Icons.cancel),
    //         label: const Text("Reject"),
    //         style: ElevatedButton.styleFrom(
    //           backgroundColor: Colors.red,
    //           foregroundColor: Colors.white,
    //           padding: const EdgeInsets.symmetric(vertical: 14),
    //           shape: RoundedRectangleBorder(
    //             borderRadius: BorderRadius.circular(12),
    //           ),
    //           textStyle: const TextStyle(
    //             fontWeight: FontWeight.bold,
    //             fontSize: 16,
    //           ),
    //         ),
    //       ),
    //     ),
    //     const SizedBox(width: 12),
    //     Expanded(
    //       child: ElevatedButton.icon(
    //         onPressed: _handleAccept,
    //         icon: const Icon(Icons.check_circle),
    //         label: const Text("Accept"),
    //         style: ElevatedButton.styleFrom(
    //           backgroundColor: Colors.green,
    //           foregroundColor: Colors.white,
    //           padding: const EdgeInsets.symmetric(vertical: 14),
    //           shape: RoundedRectangleBorder(
    //             borderRadius: BorderRadius.circular(12),
    //           ),
    //           textStyle: const TextStyle(
    //             fontWeight: FontWeight.bold,
    //             fontSize: 16,
    //           ),
    //         ),
    //       ),
    //     ),
    //   ],
    // );

    // ❌ Rejected: Show Rejected Label
    // if (_status == 'rejected') {
    //   return Container(
    //     padding: const EdgeInsets.all(14),
    //     decoration: BoxDecoration(
    //       color: Colors.red.withOpacity(0.1),
    //       borderRadius: BorderRadius.circular(12),
    //     ),
    //     child: const Row(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: [
    //         Icon(Icons.cancel, color: Colors.red),
    //         SizedBox(width: 8),
    //         Text(
    //           "Order Rejected",
    //           style: TextStyle(
    //             color: Colors.red,
    //             fontWeight: FontWeight.bold,
    //             fontSize: 16,
    //           ),
    //         ),
    //       ],
    //     ),
    //   );
    // }

// class OrderActionButtons extends StatelessWidget {
//   final Future<void> Function() onAccept;
//   final Future<void> Function() onReject;
//   final Future<void> Function() onGetLocation;
//   final Future<void> Function() onCompleted;

//   final String status;

//   const OrderActionButtons({
//     super.key,
//     required this.onAccept,
//     required this.onReject,
//     required this.onGetLocation,
//     required this.onCompleted,
//     required this.status,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (status == "pending") {
//       return Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           ElevatedButton.icon(
//             onPressed: onAccept,
//             icon: Icon(Icons.check),
//             label: Text("Accept"),
//           ),
//           ElevatedButton.icon(
//             onPressed: onReject,
//             icon: Icon(Icons.close),
//             label: Text("Reject"),
//           ),
//         ],
//       );
//     } else if (status == "accepted") {
//       return Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           ElevatedButton.icon(
//             onPressed: onGetLocation,
//             icon: Icon(Icons.location_on),
//             label: Text("Get Location"),
//           ),
//           ElevatedButton.icon(
//             onPressed: onCompleted,
//             icon: Icon(Icons.done_all),
//             label: Text("Completed"),
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//           ),
//         ],
//       );
//     } else {
//       return const SizedBox.shrink(); // No buttons for rejected/completed orders
//     }
//   }
// }

