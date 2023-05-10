import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/screens/new_grocery_item_screen.dart';
import 'package:shopping_list/widgets/grocery_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https('flutter-shopping-5ae4b-default-rtdb.firebaseio.com',
        'shopping-list.json');
    try {
      final response = await http.get(url);
      if (response.statusCode >= 400) {
        setState(() {
          _errorMessage = 'Failed to fetch data. Please try again later.';
          _isLoading = false;
        });
      } else {
        if (response.body == 'null') {
          setState(() {
            _isLoading = false;
          });
          return;
        }
        final Map<String, dynamic> listData = json.decode(response.body);
        List<GroceryItem> items = [];
        for (final item in listData.entries) {
          items.add(
            GroceryItem(
              id: item.key,
              name: item.value['name'],
              quantity: item.value['quantity'],
              category: categories.values.firstWhere(
                  (category) => category.title == item.value['category']),
            ),
          );
        }
        setState(() {
          _groceryItems = items;
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Something went wrong! Please try again later.';
      });
    }
  }

  void _addNewGroceryItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(builder: (ctx) => const NewGroceryItemScreen()),
    );

    if (newItem != null) {
      setState(() {
        _groceryItems.add(newItem);
      });
    }
  }

  void _remevoGroceryItem(GroceryItem item) async {
    final indexOfItem = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });

    final url = Uri.https('flutter-shopping-5ae4b-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error occurs when deleting the item.')),
        );
      }
      setState(() {
        _groceryItems.insert(indexOfItem, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent = const Center(child: Text('You got no items yet'));

    if (_isLoading) {
      bodyContent = const Center(child: CircularProgressIndicator());
    }

    if (_groceryItems.isNotEmpty) {
      bodyContent = GroceryList(
        groceryItems: _groceryItems,
        onRemoveItem: _remevoGroceryItem,
      );
    }

    if (_errorMessage != null) {
      bodyContent = Center(child: Text(_errorMessage!));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(onPressed: _addNewGroceryItem, icon: const Icon(Icons.add))
        ],
      ),
      body: bodyContent,
    );
  }
}
