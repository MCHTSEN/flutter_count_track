import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_count_track/features/order_management/presentation/notifiers/order_notifier.dart';

/// Sipariş listesi ekranı için UI işlemlerini içeren mixin
mixin OrderListScreenMixin {

  /// Onay dialog'u gösterme
  Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'Evet',
    String cancelText = 'Hayır',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelText),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  /// Loading dialog gösterme
  void showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Expanded(child: Text(message)),
            ],
          ),
        );
      },
    );
  }

  /// Loading dialog'u kapatma
  void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// Genel hata dialog'u gösterme
  void showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onRetry,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red[600]),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tamam'),
            ),
            if (onRetry != null)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onRetry();
                },
                child: const Text('Tekrar Dene'),
              ),
          ],
        );
      },
    );
  }

  /// Başarı dialog'u gösterme
  void showSuccessDialog(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onOk,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[600]),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onOk?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
              ),
              child: const Text('Tamam'),
            ),
          ],
        );
      },
    );
  }

  /// Filtreleri temizleme işlemi
  void clearFilters(VoidCallback onClear) {
    onClear();
  }

  /// Siparişleri yenileme işlemi
  void refreshOrders(WidgetRef ref) {
    ref.read(orderNotifierProvider.notifier).loadOrders();
  }
}
