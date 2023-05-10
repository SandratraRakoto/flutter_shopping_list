import 'package:flutter/material.dart';

import 'package:shopping_list/models/grocery_item.dart';

class GroceryList extends StatelessWidget {
  const GroceryList({
    super.key,
    required this.groceryItems,
    required this.onRemoveItem,
  });

  final List<GroceryItem> groceryItems;
  final void Function(GroceryItem item) onRemoveItem;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: groceryItems.length,
      itemBuilder: (ctx, index) => Dismissible(
        key: ValueKey(groceryItems[index].id),
        onDismissed: (direction) {
          onRemoveItem(groceryItems[index]);
        },
        background: Container(
          color: Theme.of(context).focusColor,
        ),
        child: ListTile(
          title: Text(
            groceryItems[index].name,
          ),
          leading: Container(
            height: 24,
            width: 24,
            color: groceryItems[index].category.color,
          ),
          trailing: Text(
            groceryItems[index].quantity.toString(),
          ),
        ),
      ),
    );
  }
}
