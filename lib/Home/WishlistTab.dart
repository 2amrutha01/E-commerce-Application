import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Define Product class to match Firestore data
class Product {
  final String name;
  final String price;
  final String imageUrl;
  final String docId;
  final String userId; // User who added the product to the wishlist

  Product({
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.userId,
    required this.docId,
  });

  factory Product.fromFirestore(
      Map<String, dynamic> firestoreData, String docId) {
    return Product(
      name: firestoreData['name'] ?? '',
      price: firestoreData['price'] ?? '0.0',
      imageUrl: firestoreData['imageUrl'] ?? '',
      userId: firestoreData['userId'] ?? '',
      docId: docId,
    );
  }

  // Remove product from wishlist
  Future<void> removeFromWishlist() async {
    await FirebaseFirestore.instance
        .collection('Wishlist')
        .doc('$userId-$docId')
        .delete();
  }
}

class WishlistTab extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fetch wishlist items for the logged-in user
  Stream<List<Product>> getWishlistItems() {
    final userId = _auth.currentUser?.uid;

    if (userId == null) {
      return Stream.value([]); // No user, return empty stream
    }

    final wishlistCollection =
        FirebaseFirestore.instance.collection('Wishlist');
    return wishlistCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromFirestore(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Product>>(
        stream: getWishlistItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return Center(child: Text('No items in wishlist.'));
          }

          List<Product> wishlistItems = snapshot.data!;

          return ListView.builder(
            itemCount: wishlistItems.length,
            itemBuilder: (context, index) {
              Product product = wishlistItems[index];

              return Card(
                margin: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 4,
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 8, horizontal: 12), // Adjust padding here
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.imageUrl,
                      width: 50, // Adjust the image width
                      height: 50, // Adjust the image height
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 14, // Adjust font size for title
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      Text(
                        '₹${product.price}',
                        style: TextStyle(
                          fontSize: 12, // Adjust font size for price
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(
                          Icons.favorite,
                          color: Colors.red,
                        ),
                        onPressed: () async {
                          await product
                              .removeFromWishlist(); // Remove product from wishlist
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Removed from Wishlist'),
                          ));
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
