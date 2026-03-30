import 'package:flutter/material.dart';
import '../../domain/entities/cart_item.dart';
import 'cart_item_tile.dart';

class CartItemList extends StatelessWidget {
  const CartItemList({super.key, required this.items});

  final List<CartItem> items;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, index) => CartItemTile(item: items[index]),
    );
  }
}
