import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/products/bicycle_item.dart';
import '../widgets/global/main_drawer.dart';
import './edit_product_screen.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/';

  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Bicycles'),
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(EditProductScreen.routeName),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      drawer: const MainDrawer(),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('bicycles')
            .orderBy('price')
            .snapshots(),
        builder: (ctx, AsyncSnapshot<QuerySnapshot> productsSnapshot) {
          if (productsSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final documents = productsSnapshot.data!.docs;
          return ListView.builder(
            itemBuilder: (ctx, index) => BicycleItem(
              documents[index].id,
              documents[index]['color'],
              documents[index]['price'],
              documents[index]['size'],
              documents[index]['available'],
              scaffoldKey: _scaffoldKey,
              key: ValueKey(documents[index].id),
            ),
            itemCount: documents.length,
          );
        },
      ),
    );
  }
}
