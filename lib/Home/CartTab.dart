import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

// Define Product class to match Firestore data
class Product {
  final String name;
  final String price;
  final String imageUrl;
  bool addToCart;
  final String docId;

  Product({
    required this.name,
    required this.price,
    required this.imageUrl,
    this.addToCart = false,
    required this.docId,
  });

  factory Product.fromFirestore(
      Map<String, dynamic> firestoreData, String docId) {
    return Product(
      name: firestoreData['name'] ?? '',
      price: firestoreData['price'] ?? '0.0',
      imageUrl: firestoreData['imageUrl'] ?? '',
      addToCart: firestoreData['add_to_cart'] ?? false,
      docId: docId,
    );
  }
}

class CartTab extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fetch cart items for the logged-in user
  Stream<List<Product>> getCartItems() {
    final userId = _auth.currentUser?.uid;

    if (userId == null) {
      return Stream.value([]); // Return empty stream if no user is logged in
    }

    return FirebaseFirestore.instance
        .collection('Cart') // Cart collection
        .where('userId', isEqualTo: userId) // Filter by current userId
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Product.fromFirestore(
                doc.data() as Map<String, dynamic>,
                doc.id, // Provide document ID
              ))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Product>>(
        stream: getCartItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return Center(child: Text('No items in the cart.'));
          }

          List<Product> cartItems = snapshot.data!;

          return ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              Product product = cartItems[index];

              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: Image.network(
                    product.imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                  title: Text(
                    product.name,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Row(
                    children: [
                      Text(
                        '₹${product.price}', // Display price with ₹
                        style: TextStyle(fontSize: 16),
                      ),
                      Spacer(),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.green, // Green color for the button
                        ),
                        child: Text("Buy"),
                        onPressed: () {
                          // Logic to buy the product (place order or go to checkout)
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content:
                                Text('${product.name} added to your order'),
                          ));

                          // Example: Navigate to checkout screen (if exists)
                          // Navigator.push(context, MaterialPageRoute(builder: (_) => CheckoutScreen()));
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    // Optional: Handle tap to view product details
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
