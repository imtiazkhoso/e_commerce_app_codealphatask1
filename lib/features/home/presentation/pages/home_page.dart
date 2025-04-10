import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/constants/colors.dart';
import '../widgets/product_card.dart';
import '../../data/models/product_model.dart';
import '../../../orders/presentation/pages/cart_page.dart';
import '../../../../routes.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Sample products data (in a real app, this would come from an API or database)
  final List<ProductModel> _allProducts = [
    ProductModel(
      id: '1',
      name: 'Wireless Earbuds',
      price: 79.99,
      description: 'High-quality wireless earbuds with noise cancellation.',
      imageUrl: 'https://source.unsplash.com/random/400x400/?earbuds',
      category: 'Electronics',
      rating: 4.5,
    ),
    ProductModel(
      id: '2',
      name: 'Smart Watch',
      price: 149.99,
      description: 'Feature-rich smartwatch with health tracking.',
      imageUrl: 'https://source.unsplash.com/random/400x400/?smartwatch',
      category: 'Electronics',
      rating: 4.2,
    ),
    ProductModel(
      id: '3',
      name: 'Running Shoes',
      price: 89.99,
      description: 'Comfortable running shoes with advanced cushioning.',
      imageUrl: 'https://source.unsplash.com/random/400x400/?running-shoes',
      category: 'Sports',
      rating: 4.7,
    ),
    ProductModel(
      id: '4',
      name: 'Backpack',
      price: 59.99,
      description: 'Durable backpack with multiple compartments.',
      imageUrl: 'https://source.unsplash.com/random/400x400/?backpack',
      category: 'Fashion',
      rating: 4.0,
    ),
    ProductModel(
      id: '5',
      name: 'Smartphone',
      price: 699.99,
      description: 'Latest smartphone with advanced camera system.',
      imageUrl: 'https://source.unsplash.com/random/400x400/?smartphone',
      category: 'Electronics',
      rating: 4.8,
    ),
    ProductModel(
      id: '6',
      name: 'Water Bottle',
      price: 24.99,
      description: 'Insulated water bottle that keeps drinks cold for 24 hours.',
      imageUrl: 'https://source.unsplash.com/random/400x400/?water-bottle',
      category: 'Lifestyle',
      rating: 4.3,
    ),
  ];

  List<ProductModel> get _filteredProducts {
    return _allProducts.where((product) {
      // Apply category filter
      final matchesCategory = _selectedCategory == 'All' || product.category == _selectedCategory;
      
      // Apply search filter
      final matchesSearch = _searchQuery.isEmpty || 
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.description.toLowerCase().contains(_searchQuery.toLowerCase());
      
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _showSearchModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _searchQuery = _searchController.text;
                  });
                  Navigator.pop(context);
                },
                child: const Text('Search'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    final categories = [
      'All',
      'Electronics',
      'Fashion',
      'Sports',
      'Home',
      'Beauty',
      'Lifestyle',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Commerce App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearchModal(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CartPage(),
                ),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(authProvider.user?.displayName ?? 'User'),
              accountEmail: Text(authProvider.user?.email ?? 'user@example.com'),
              currentAccountPicture: CircleAvatar(
                backgroundImage: authProvider.user?.photoURL != null
                    ? NetworkImage(authProvider.user!.photoURL!)
                    : null,
                child: authProvider.user?.photoURL == null
                    ? const Icon(Icons.person)
                    : null,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Categories'),
              onTap: () {
                Navigator.pop(context);
                // Show all categories
                setState(() {
                  _selectedCategory = 'All';
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag),
              title: const Text('My Orders'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.orders);
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Wishlist'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to wishlist
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.profile);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                await authProvider.signOut();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search indicator
          if (_searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
              child: Row(
                children: [
                  const Text('Search results for: '),
                  Expanded(
                    child: Text(
                      _searchQuery,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear, size: 16),
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _searchController.clear();
                      });
                    },
                  )
                ],
              ),
            ),
          
          // Categories horizontal list
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final category = categories[index];
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: category == _selectedCategory,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      }
                    },
                  ),
                );
              },
            ),
          ),
          
          // Products grid
          Expanded(
            child: _filteredProducts.isEmpty
                ? const Center(
                    child: Text('No products found'),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return ProductCard(product: product);
                    },
                  ),
          ),
        ],
      ),
    );
  }
} 