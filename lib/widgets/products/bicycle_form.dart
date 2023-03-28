import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BicycleForm extends StatefulWidget {
  final String? bicycleId;

  const BicycleForm({Key? key, this.bicycleId}) : super(key: key);

  @override
  State<BicycleForm> createState() => _BicycleFormState();
}

class _BicycleFormState extends State<BicycleForm> {
  var _isAdd = true;
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _colorController = TextEditingController();
  final _priceController = TextEditingController();
  final _sizeController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _saveForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isAdd) {
      FirebaseFirestore.instance.collection('bicycles').add({
        'color': _colorController.text,
        'price': double.parse(_priceController.text),
        'size': _sizeController.text,
        "available": true,
      });

      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Bicycle added!', textAlign: TextAlign.center),
        duration: Duration(seconds: 3),
      ));
    } else {
      FirebaseFirestore.instance.doc('bicycles/${widget.bicycleId}').set({
        'color': _colorController.text,
        'price': _priceController.text,
        'size': _sizeController.text,
        "available": true,
      });

      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Bicycle edited!', textAlign: TextAlign.center),
        duration: Duration(seconds: 3),
      ));
    }

    Navigator.of(context).pop(true);
  }

  Widget _columnForm() {
    return Column(
      children: [
        TextFormField(
          key: const ValueKey('color'),
          controller: _colorController,
          autocorrect: true,
          enableSuggestions: true,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
            labelText: 'Color',
            labelStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return 'Color can\'t be empty!';
            }
            return null;
          },
          onSaved: (value) {},
        ),
        TextFormField(
          key: const ValueKey('Size'),
          controller: _sizeController,
          autocorrect: true,
          enableSuggestions: true,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
            labelText: 'Size',
            labelStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return 'Size can\'t be empty!';
            }
            return null;
          },
          onSaved: (value) {},
        ),
        TextFormField(
          key: const ValueKey('price'),
          controller: _priceController,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Price',
            labelStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return 'The price can\'t be empty!';
            }
            if (double.tryParse(value)! < 0.0) {
              return 'The price can\'t be negative!';
            }
            return null;
          },
        ),
        const SizedBox(height: 16.0),
        ElevatedButton(
          onPressed: _saveForm,
          child: const Text('Save bicycle'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: widget.bicycleId != null
            ? FutureBuilder(
                future: FirebaseFirestore.instance
                    .doc('products/${widget.bicycleId}')
                    .get(),
                builder: (ctx,
                    AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                        product) {
                  if (product.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                          color: Theme.of(ctx).colorScheme.secondary),
                    );
                  }
                  final productData = product.data!;
                  _colorController.text = productData['title'];
                  _priceController.text = productData['price'];
                  _sizeController.text = productData['trademark'];
                  _isAdd = false;
                  return Form(
                    key: _formKey,
                    child: _columnForm(),
                  );
                })
            : Form(
                key: _formKey,
                child: _columnForm(),
              ),
      ),
    );
  }
}
