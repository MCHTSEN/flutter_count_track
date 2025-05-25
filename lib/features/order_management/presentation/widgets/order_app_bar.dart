import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onImportPressed;
  final VoidCallback onRefreshPressed;

  const OrderAppBar({
    super.key,
    required this.onImportPressed,
    required this.onRefreshPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        'Sipariş Yönetimi',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.blue[800],
      foregroundColor: Colors.white,
      toolbarHeight: 80,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: onImportPressed,
                icon: const Icon(Icons.file_upload, size: 28),
                label: const Text('Excel İçe Aktar',
                    style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: onRefreshPressed,
                icon: const Icon(Icons.refresh, size: 28),
                label: const Text('Yenile', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue[800],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
