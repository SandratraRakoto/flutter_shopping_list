import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/models/grocery_item.dart';

class NewGroceryItemScreen extends StatefulWidget {
  const NewGroceryItemScreen({super.key});

  @override
  State<NewGroceryItemScreen> createState() => _NewGroceryItemScreenState();
}

class _NewGroceryItemScreenState extends State<NewGroceryItemScreen> {
  final _formKey = GlobalKey<FormState>();

  var _enteredName = '';
  var _enteredQuantity = 1;
  Category _selectedCategory = categories[Categories.vegetables]!;
  var _isSending = false;

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isSending = true;
      });

      final url = Uri.https(
          'flutter-shopping-5ae4b-default-rtdb.firebaseio.com',
          'shopping-list.json');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': _enteredName,
          'quantity': _enteredQuantity,
          'category': _selectedCategory.title,
        }),
      );

      final createdItemID = json.decode(response.body)['name'];
      if (context.mounted &&
          response.statusCode == 200 &&
          createdItemID != null) {
        Navigator.of(context).pop(
          GroceryItem(
            id: createdItemID,
            name: _enteredName,
            quantity: _enteredQuantity,
            category: _selectedCategory,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add new grocery item')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _enteredName,
                maxLength: 50,
                decoration: const InputDecoration(label: Text('Name')),
                validator: (value) => (value == null ||
                        value.isEmpty ||
                        value.trim().length <= 1 ||
                        value.trim().length > 50)
                    ? 'Must be between 1 and 50 characters.'
                    : null,
                onSaved: (value) {
                  _enteredName = value!;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        label: Text('Quantity'),
                      ),
                      initialValue: _enteredQuantity.toString(),
                      keyboardType: TextInputType.number,
                      validator: (value) => (value == null ||
                              value.isEmpty ||
                              int.tryParse(value) == null ||
                              int.tryParse(value)! <= 0)
                          ? 'Must be a valid, positive number.'
                          : null,
                      onSaved: (value) {
                        _enteredQuantity = int.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedCategory,
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                              value: category.value,
                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    color: category.value.color,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(category.value.title),
                                ],
                              ))
                      ],
                      onChanged: (value) {
                        _selectedCategory = value!;
                      },
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: !_isSending
                          ? () {
                              _formKey.currentState!.reset();
                            }
                          : null,
                      child: const Text('Reset')),
                  const SizedBox(width: 8),
                  ElevatedButton(
                      onPressed: !_isSending ? _saveItem : null,
                      child: _isSending
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator())
                          : const Text('Save item'))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
