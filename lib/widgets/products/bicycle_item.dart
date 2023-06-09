import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../screens/product_detail_screen.dart';
import '../../screens/sell_product_screen.dart';

class BicycleItem extends StatefulWidget {
  final String id;
  final String color;
  final double price;
  final String size;
  final bool available;
  final GlobalKey scaffoldKey;

  const BicycleItem(this.id, this.color, this.price, this.size, this.available,
      {required this.scaffoldKey, Key? key})
      : super(key: key);

  @override
  State<BicycleItem> createState() => _BicycleItemState();
}

class _BicycleItemState extends State<BicycleItem> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(widget.id),
      background: Row(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            width: (MediaQuery.of(context).size.width / 2) - 15,
            padding: const EdgeInsets.only(
              left: 20.0,
            ),
            margin: const EdgeInsets.only(
              top: 4.0,
              left: 15.0,
              bottom: 4.0,
            ),
            color: Theme.of(context).colorScheme.secondary,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.attach_money,
                  color: Colors.white,
                  size: 28,
                ),
                Text(
                  'Rent',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.centerRight,
            width: (MediaQuery.of(context).size.width / 2) - 15,
            padding: const EdgeInsets.only(
              right: 20.0,
            ),
            margin: const EdgeInsets.only(
              top: 4.0,
              right: 15.0,
              bottom: 4.0,
            ),
            color: Theme.of(context).colorScheme.error,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.delete,
                  color: Colors.white,
                  size: 28,
                ),
                Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) {
        if (direction == DismissDirection.endToStart) {
          return Future.value(true);
        }

        FirebaseFirestore.instance.doc("bicycles/${widget.id}").set({
          "available": !widget.available,
        }, SetOptions(merge: true));

        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Bicycle status changed!', textAlign: TextAlign.center),
          duration: Duration(seconds: 3),
        ));

        return Future.value(false);
      },
      onDismissed: (direction) async {
        final deletedProduct =
            await FirebaseFirestore.instance.doc('bicycles/${widget.id}').get();
        FirebaseFirestore.instance
            .doc('bicycles/${widget.id}')
            .delete()
            .then((value) {
          ScaffoldMessenger.of(widget.scaffoldKey.currentContext!)
              .removeCurrentSnackBar();
          ScaffoldMessenger.of(widget.scaffoldKey.currentContext!)
              .showSnackBar(SnackBar(
            content: Text('${widget.color} has been deleted.'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
                label: 'UNDO',
                onPressed: () {
                  FirebaseFirestore.instance
                      .collection('bicycles')
                      .add(deletedProduct.data()!);
                }),
          ));
        });
      },
      child: Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        margin: const EdgeInsets.all(10.0),
        child: Material(
          color: widget.available ? Colors.green : Colors.amber[700]!,
          child: InkWell(
            borderRadius: BorderRadius.circular(15.0),
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    "${widget.color.toUpperCase()} Bicycle",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('\$${widget.price}'),
                  trailing: IconButton(
                    icon:
                        Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                    onPressed: () {
                      setState(() {
                        _expanded = !_expanded;
                      });
                    },
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  constraints: BoxConstraints(
                    minHeight: _expanded ? 40.0 : 0.0,
                    maxHeight: _expanded ? 80.0 : 0.0,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15.0,
                    vertical: 4.0,
                  ),
                  height: 40.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "Size: ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(widget.size),
                        ],
                      ),
                      Row(
                        children: [
                          const Text(
                            "Status: ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(widget.available ? "Available" : "Unavailable"),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
