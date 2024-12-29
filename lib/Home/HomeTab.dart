import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Define Product class to match Firestore data
class Product {
  final String name;
  final String price;
  final String imageUrl;
  bool wishlist;
  bool addToCart;
  final String docId; // Store document ID to properly reference it

  Product({
    required this.name,
    required this.price,
    required this.imageUrl,
    this.wishlist = false,
    this.addToCart = false,
    required this.docId,
  });

  factory Product.fromFirestore(
      Map<String, dynamic> firestoreData, String docId) {
    return Product(
      name: firestoreData['name'] ?? '',
      price: firestoreData['price'] ?? '0.0',
      imageUrl: firestoreData['image'] ?? '',
      wishlist: firestoreData['wishlist'] ?? false,
      addToCart: firestoreData['add_to_cart'] ?? false,
      docId: docId, // Assign document ID
    );
  }

  // Update wishlist status
  Future<void> updateWishlistStatus(String userId) async {
    final wishlistCollection =
        FirebaseFirestore.instance.collection('Wishlist');

    if (wishlist) {
      // Add to Wishlist
      await wishlistCollection.doc('$userId-$docId').set({
        'userId': userId,
        'productId': docId,
        'name': name,
        'price': price,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      // Remove from Wishlist
      await wishlistCollection.doc('$userId-$docId').delete();
    }
  }

  // Update cart status
  Future<void> updateCartStatus(String userId) async {
    final cartCollection = FirebaseFirestore.instance.collection('Cart');

    if (addToCart) {
      // Add to Cart
      await cartCollection.doc('$userId-$docId').set({
        'userId': userId,
        'productId': docId,
        'name': name,
        'price': price,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      // Remove from Cart
      await cartCollection.doc('$userId-$docId').delete();
    }
  }
}

class HomeTab extends StatelessWidget {
  final CollectionReference productCollection =
      FirebaseFirestore.instance.collection('Product_List');

  // Fetch products from Firestore
  Stream<List<Product>> getProducts() {
    return productCollection.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Product.fromFirestore(doc.data() as Map<String, dynamic>,
            doc.id)) // Passing document ID here
        .toList());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Product>>(
      stream: getProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.data == null || snapshot.data!.isEmpty) {
          return Center(child: Text('No products available.'));
        }

        List<Product> products = snapshot.data!;

        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            Product product = products[index];

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
                      '₹${product.price}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(
                        product.wishlist
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: product.wishlist ? Colors.red : null,
                      ),
                      onPressed: () async {
                        try {
                          final user = FirebaseAuth.instance.currentUser;

                          if (user == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'You must be logged in to use the Wishlist')),
                            );
                            return;
                          }

                          final userId = user.uid;

                          // Toggle wishlist status
                          product.wishlist = !product.wishlist;
                          await product.updateWishlistStatus(userId);

                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(product.wishlist
                                ? 'Added to Wishlist'
                                : 'Removed from Wishlist'),
                          ));

                          // Trigger UI update
                          (context as Element).reassemble();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Failed to update Wishlist: $e'),
                          ));
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        product.addToCart
                            ? Icons.shopping_cart
                            : Icons.add_shopping_cart,
                      ),
                      onPressed: () async {
                        try {
                          final user = FirebaseAuth.instance.currentUser;

                          if (user == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'You must be logged in to use the Cart')),
                            );
                            return;
                          }

                          final userId = user.uid;

                          // Toggle cart status
                          product.addToCart = !product.addToCart;
                          await product.updateCartStatus(userId);

                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(product.addToCart
                                ? 'Added to Cart'
                                : 'Removed from Cart'),
                          ));

                          // Trigger UI update
                          (context as Element).reassemble();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Failed to update Cart: $e'),
                          ));
                        }
                      },
                    ),
                  ],
                ),
                onTap: () {
                  // Add any onTap actions you need (like navigating to a product detail page)
                },
              ),
            );
          },
        );
      },
    );
  }
}
