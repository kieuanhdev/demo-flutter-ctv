import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartSummary extends StatelessWidget {
  const CartSummary({super.key, required this.totalPrice});

  final double totalPrice;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontSize: 18)),
              Text(
                totalPrice.toStringAsFixed(2),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Get.snackbar('Checkout', 'Not implemented');
              },
              child: const Text('Checkout'),
            ),
          ),
        ],
      ),
    );
  }
}
