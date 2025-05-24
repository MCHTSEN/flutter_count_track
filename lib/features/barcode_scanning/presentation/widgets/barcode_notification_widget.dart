import 'package:flutter/material.dart';
import 'package:flutter_count_track/features/barcode_scanning/presentation/notifiers/barcode_notifier.dart';

class BarcodeNotificationWidget extends StatelessWidget {
  final BarcodeState state;

  const BarcodeNotificationWidget({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    if (state.status == BarcodeStatus.none) {
      return const SizedBox.shrink();
    }

    Color backgroundColor;
    IconData iconData;

    switch (state.status) {
      case BarcodeStatus.success:
        backgroundColor = Colors.green;
        iconData = Icons.check_circle;
        break;
      case BarcodeStatus.warning:
        backgroundColor = Colors.orange;
        iconData = Icons.warning;
        break;
      case BarcodeStatus.error:
        backgroundColor = Colors.red;
        iconData = Icons.error;
        break;
      default:
        backgroundColor = Colors.grey;
        iconData = Icons.info;
        break;
    }

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            iconData,
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              state.message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
