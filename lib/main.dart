import 'package:flutter/material.dart';

void main() => runApp(const ShoeStoreApp());

class Product {
  final String name, category, image, description;
  final double price, oldPrice;
  final List<int> sizes;
  final int rating;

  const Product({
    required this.name,
    required this.category,
    required this.image,
    required this.description,
    required this.price,
    required this.oldPrice,
    required this.sizes,
    this.rating = 5,
  });

  int get discount => (((oldPrice - price) / oldPrice) * 100).round();
}

const products = <Product>[
  Product(
    name: 'Classic Chelsea Boot',
    category: 'Chelsea Boots',
    image: 'https://images.unsplash.com/photo-1638247025967-b4e38f787b76?auto=format&fit=crop&w=900&q=85',
    description: 'Premium leather Chelsea boots with elastic side panels and a clean everyday silhouette.',
    price: 6999,
    oldPrice: 8999,
    sizes: [40, 41, 42, 43, 44],
  ),
  Product(
    name: 'Urban Leather Sneaker',
    category: 'Sneakers',
    image: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=900&q=85',
    description: 'Minimal leather sneakers designed for daily wear, travel and smart-casual outfits.',
    price: 5499,
    oldPrice: 6999,
    sizes: [39, 40, 41, 42, 43, 44],
  ),
  Product(
    name: 'Executive Formal Shoe',
    category: 'Formal Shoes',
    image: 'https://images.unsplash.com/photo-1614252369475-531eba835eb1?auto=format&fit=crop&w=900&q=85',
    description: 'Classic formal footwear with a polished finish for office, weddings and special occasions.',
    price: 6299,
    oldPrice: 7999,
    sizes: [40, 41, 42, 43, 44],
  ),
  Product(
    name: 'Street Runner',
    category: 'Running Shoes',
    image: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=900&q=85',
    description: 'Lightweight running shoes with a cushioned sole for everyday movement.',
    price: 4799,
    oldPrice: 5999,
    sizes: [39, 40, 41, 42, 43],
  ),
  Product(
    name: 'Desert Casual Boot',
    category: 'Casual Boots',
    image: 'https://images.unsplash.com/photo-1520639888713-7851133b1ed0?auto=format&fit=crop&w=900&q=85',
    description: 'Rugged casual boots with a comfortable sole and timeless desert-boot styling.',
    price: 5799,
    oldPrice: 7499,
    sizes: [40, 41, 42, 43, 44],
  ),
  Product(
    name: 'Premium Loafer',
    category: 'Loafers',
    image: 'https://images.unsplash.com/photo-1533867617858-e7b97e060509?auto=format&fit=crop&w=900&q=85',
    description: 'Smart slip-on loafers for a polished look without sacrificing comfort.',
    price: 5199,
    oldPrice: 6499,
    sizes: [40, 41, 42, 43],
  ),
  Product(
    name: 'Classic Brown Chelsea',
    category: 'Chelsea Boots',
    image: 'https://images.unsplash.com/photo-1605812860427-4024433a5c2d?auto=format&fit=crop&w=900&q=85',
    description: 'Brown Chelsea boots with a premium finish and durable construction.',
    price: 7299,
    oldPrice: 9499,
    sizes: [40, 41, 42, 43, 44],
  ),
  Product(
    name: 'Everyday Canvas',
    category: 'Sneakers',
    image: 'https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77?auto=format&fit=crop&w=900&q=85',
    description: 'Comfortable casual sneakers for everyday outfits and weekend trips.',
    price: 3299,
    oldPrice: 4299,
    sizes: [39, 40, 41, 42, 43],
  ),
];

class ShoeStoreApp extends StatelessWidget {
  const ShoeStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Khan Footwear',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF111827)),
        scaffoldBackgroundColor: const Color(0xFFF7F7F5),
      ),
      home: const StoreHomePage(),
    );
  }
}

class StoreHomePage extends StatefulWidget {
  const StoreHomePage({super.key});

  @override
  State<StoreHomePage> createState() => _StoreHomePageState();
}

class _StoreHomePageState extends State<StoreHomePage> {
  final cart = <Product>[];
  String category = 'All';
  String search = '';

  List<Product> get visibleProducts {
    return products.where((p) {
      final categoryMatch = category == 'All' || p.category == category;
      final searchMatch = search.isEmpty || p.name.toLowerCase().contains(search.toLowerCase());
      return categoryMatch && searchMatch;
    }).toList();
  }

  void addToCart(Product product) {
    setState(() => cart.add(product));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} added to cart')),
    );
  }

  void showProduct(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (_) => ProductDetails(product: product, onAdd: () => addToCart(product)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF111827),
        foregroundColor: Colors.white,
        title: const Row(children: [
          Icon(Icons.shopping_bag_outlined),
          SizedBox(width: 10),
          Text('KHAN FOOTWEAR', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1)),
        ]),
        actions: [
          if (MediaQuery.sizeOf(context).width > 750) ...[
            TextButton(onPressed: () {}, child: const Text('Home', style: TextStyle(color: Colors.white))),
            TextButton(onPressed: () {}, child: const Text('Shop', style: TextStyle(color: Colors.white))),
            TextButton(onPressed: () {}, child: const Text('Sale', style: TextStyle(color: Colors.white))),
          ],
          IconButton(onPressed: () => _loginDialog(context), icon: const Icon(Icons.person_outline)),
          Stack(children: [
            IconButton(onPressed: () => _cartDialog(context), icon: const Icon(Icons.shopping_cart_outlined)),
            if (cart.isNotEmpty) Positioned(right: 5, top: 5, child: CircleAvatar(radius: 9, child: Text('${cart.length}', style: const TextStyle(fontSize: 10)))),
          ]),
          const SizedBox(width: 10),
        ],
      ),
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: _hero()),
        SliverToBoxAdapter(child: _categories()),
        SliverToBoxAdapter(child: _shopHeader()),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 50),
          sliver: SliverLayoutBuilder(builder: (context, constraints) {
            final width = constraints.crossAxisExtent;
            final columns = width >= 1200 ? 4 : width >= 800 ? 3 : width >= 520 ? 2 : 1;
            return SliverGrid.builder(
              itemCount: visibleProducts.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
                childAspectRatio: width < 520 ? .82 : .72,
              ),
              itemBuilder: (_, i) => ProductCard(product: visibleProducts[i], onTap: () => showProduct(visibleProducts[i]), onAdd: () => addToCart(visibleProducts[i])),
            );
          }),
        ),
        SliverToBoxAdapter(child: _footer()),
      ]),
    );
  }

  Widget _hero() => Container(
    height: 440,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 55),
    decoration: const BoxDecoration(
      image: DecorationImage(
        image: NetworkImage('https://images.unsplash.com/photo-1520256862855-398228c41684?auto=format&fit=crop&w=1800&q=85'),
        fit: BoxFit.cover,
      ),
    ),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 650),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: Colors.black.withOpacity(.55), borderRadius: BorderRadius.circular(18)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          const Text('NEW SEASON COLLECTION', style: TextStyle(color: Color(0xFFFBBF24), fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height: 12),
          const Text('Walk in your\nown style.', style: TextStyle(color: Colors.white, fontSize: 46, height: 1.05, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          const Text('Chelsea boots, sneakers, formal shoes and everyday footwear — made for your next step.', style: TextStyle(color: Colors.white70, fontSize: 17)),
          const SizedBox(height: 22),
          FilledButton(onPressed: () => setState(() => category = 'All'), child: const Text('Shop Collection')),
        ]),
      ),
    ),
  );

  Widget _categories() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
    child: Wrap(spacing: 10, runSpacing: 10, alignment: WrapAlignment.center, children: [
      'All', 'Chelsea Boots', 'Sneakers', 'Formal Shoes', 'Casual Boots', 'Loafers', 'Running Shoes'
    ].map((c) => ChoiceChip(label: Text(c), selected: category == c, onSelected: (_) => setState(() => category = c))).toList()),
  );

  Widget _shopHeader() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
    child: Row(children: [
      const Expanded(child: Text('Shop our collection', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF111827)))),
      SizedBox(width: 240, child: TextField(onChanged: (v) => setState(() => search = v), decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: 'Search shoes', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)))),
    ]),
  );

  Widget _footer() => Container(
    width: double.infinity,
    color: const Color(0xFF111827),
    padding: const EdgeInsets.all(35),
    child: const Wrap(alignment: WrapAlignment.spaceEvenly, spacing: 60, runSpacing: 25, children: [
      _FooterItem(Icons.local_shipping_outlined, 'Fast Delivery', 'Nationwide delivery'),
      _FooterItem(Icons.lock_outline, 'Secure Checkout', 'Your data stays protected'),
      _FooterItem(Icons.chat_outlined, 'WhatsApp Support', 'Talk to our team'),
      _FooterItem(Icons.verified_outlined, 'Quality Footwear', 'Built for everyday style'),
    ]),
  );

  void _loginDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Login / Create Account'),
      content: const SizedBox(width: 360, child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(decoration: InputDecoration(labelText: 'Email or phone', prefixIcon: Icon(Icons.person_outline))),
        SizedBox(height: 12),
        TextField(obscureText: true, decoration: InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline))),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Login'))],
    ));
  }

  void _cartDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text('Your Cart (${cart.length})'),
      content: SizedBox(width: 420, child: cart.isEmpty ? const Text('Your cart is empty.') : Column(mainAxisSize: MainAxisSize.min, children: cart.map((p) => ListTile(title: Text(p.name), trailing: Text('Rs. ${p.price.toStringAsFixed(0)}'))).toList())),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')), if (cart.isNotEmpty) FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Checkout'))],
    ));
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap, onAdd;
  const ProductCard({super.key, required this.product, required this.onTap, required this.onAdd});

  @override
  Widget build(BuildContext context) => Card(
    elevation: 1,
    clipBehavior: Clip.antiAlias,
    child: InkWell(onTap: onTap, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: Stack(children: [
        Positioned.fill(child: Image.network(product.image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.shopping_bag, size: 70)))),
        Positioned(top: 12, left: 12, child: Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: const Color(0xFFDC2626), borderRadius: BorderRadius.circular(20)), child: Text('${product.discount}% OFF', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)))),
        Positioned(top: 10, right: 10, child: IconButton.filled(onPressed: () {}, icon: const Icon(Icons.favorite_border), style: IconButton.styleFrom(backgroundColor: Colors.white))),
      ])),
      Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(product.category.toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(product.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        const SizedBox(height: 5),
        const Text('★★★★★', style: TextStyle(color: Color(0xFFF59E0B))),
        const SizedBox(height: 5),
        Row(children: [Text('Rs. ${product.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)), const SizedBox(width: 8), Text('Rs. ${product.oldPrice.toStringAsFixed(0)}', style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey))]),
        const SizedBox(height: 10),
        SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: onAdd, icon: const Icon(Icons.add_shopping_cart, size: 18), label: const Text('Add to Cart'))),
      ])),
    ])),
  );
}

class ProductDetails extends StatefulWidget {
  final Product product;
  final VoidCallback onAdd;
  const ProductDetails({super.key, required this.product, required this.onAdd});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  int? selectedSize;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final whatsapp = 'https://wa.me/923000000000?text=${Uri.encodeComponent('Hi, I am interested in ${p.name} - Rs. ${p.price.toStringAsFixed(0)}')}';
    return SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ClipRRect(borderRadius: BorderRadius.circular(18), child: AspectRatio(aspectRatio: 1.5, child: Image.network(p.image, fit: BoxFit.cover))),
      const SizedBox(height: 20),
      Text(p.category, style: const TextStyle(color: Colors.grey)),
      Text(p.name, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      Row(children: [Text('Rs. ${p.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)), const SizedBox(width: 12), Text('Rs. ${p.oldPrice.toStringAsFixed(0)}', style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey)), const SizedBox(width: 12), Chip(label: Text('${p.discount}% OFF'))]),
      const SizedBox(height: 12),
      Text(p.description, style: const TextStyle(fontSize: 16, height: 1.5)),
      const SizedBox(height: 20),
      const Text('Select size', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 10),
      Wrap(spacing: 8, children: p.sizes.map((s) => ChoiceChip(label: Text('$s'), selected: selectedSize == s, onSelected: (_) => setState(() => selectedSize = s))).toList()),
      const SizedBox(height: 22),
      Wrap(spacing: 12, runSpacing: 12, children: [
        FilledButton.icon(onPressed: widget.onAdd, icon: const Icon(Icons.shopping_cart), label: const Text('Add to Cart')),
        OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.payment), label: const Text('Buy Now')),
        OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.chat), label: const Text('WhatsApp')),
      ]),
      const SizedBox(height: 14),
      const Text('WhatsApp number is a placeholder. Replace 923000000000 with your business number.', style: TextStyle(color: Colors.grey, fontSize: 12)),
    ]));
  }
}

class _FooterItem extends StatelessWidget {
  final IconData icon; final String title, subtitle;
  const _FooterItem(this.icon, this.title, this.subtitle);
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: Colors.white, size: 32), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12))]));
}
