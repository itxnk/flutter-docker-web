import 'package:flutter/material.dart';

void main() => runApp(const ShoeStoreApp());

class Product {
  final String name, category, image, description;
  final double price, oldPrice;
  final List<int> sizes;
  const Product({required this.name, required this.category, required this.image, required this.description, required this.price, required this.oldPrice, required this.sizes});
  int get discount => (((oldPrice - price) / oldPrice) * 100).round();
}

const products = <Product>[
  Product(name: 'Classic Chelsea Boot', category: 'Chelsea Boots', image: 'https://images.unsplash.com/photo-1638247025967-b4e38f787b76?auto=format&fit=crop&w=900&q=85', description: 'Premium leather Chelsea boots with elastic side panels.', price: 6999, oldPrice: 8999, sizes: [40,41,42,43,44]),
  Product(name: 'Urban Leather Sneaker', category: 'Sneakers', image: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=900&q=85', description: 'Minimal sneakers for daily wear and smart casual outfits.', price: 5499, oldPrice: 6999, sizes: [39,40,41,42,43,44]),
  Product(name: 'Executive Formal Shoe', category: 'Formal Shoes', image: 'https://images.unsplash.com/photo-1614252369475-531eba835eb1?auto=format&fit=crop&w=900&q=85', description: 'Classic polished footwear for office and special occasions.', price: 6299, oldPrice: 7999, sizes: [40,41,42,43,44]),
  Product(name: 'Street Runner', category: 'Running Shoes', image: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=900&q=85', description: 'Lightweight running shoes with a cushioned sole.', price: 4799, oldPrice: 5999, sizes: [39,40,41,42,43]),
  Product(name: 'Desert Casual Boot', category: 'Casual Boots', image: 'https://images.unsplash.com/photo-1520639888713-7851133b1ed0?auto=format&fit=crop&w=900&q=85', description: 'Rugged casual boots with a comfortable durable sole.', price: 5799, oldPrice: 7499, sizes: [40,41,42,43,44]),
  Product(name: 'Premium Loafer', category: 'Loafers', image: 'https://images.unsplash.com/photo-1533867617858-e7b97e060509?auto=format&fit=crop&w=900&q=85', description: 'Smart slip-on loafers for a polished everyday look.', price: 5199, oldPrice: 6499, sizes: [40,41,42,43]),
  Product(name: 'Classic Brown Chelsea', category: 'Chelsea Boots', image: 'https://images.unsplash.com/photo-1605812860427-4024433a5c2d?auto=format&fit=crop&w=900&q=85', description: 'Brown Chelsea boots with a premium finish.', price: 7299, oldPrice: 9499, sizes: [40,41,42,43,44]),
  Product(name: 'Everyday Canvas', category: 'Sneakers', image: 'https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77?auto=format&fit=crop&w=900&q=85', description: 'Comfortable casual sneakers for everyday outfits.', price: 3299, oldPrice: 4299, sizes: [39,40,41,42,43]),
];

class ShoeStoreApp extends StatelessWidget {
  const ShoeStoreApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(debugShowCheckedModeBanner: false, title: 'Khan Footwear', theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF111827))), home: const StoreHomePage());
}

class StoreHomePage extends StatefulWidget {
  const StoreHomePage({super.key});
  @override State<StoreHomePage> createState() => _StoreHomePageState();
}

class _StoreHomePageState extends State<StoreHomePage> {
  final cart = <Product>[];
  String category = 'All';
  String search = '';
  List<Product> get visibleProducts => products.where((p) => (category == 'All' || p.category == category) && (search.isEmpty || p.name.toLowerCase().contains(search.toLowerCase()))).toList();

  void addToCart(Product p) { setState(() => cart.add(p)); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${p.name} added to cart'))); }
  void showProduct(Product p) => showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => ProductDetails(product: p, onAdd: () => addToCart(p)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: const Color(0xFF111827), foregroundColor: Colors.white, title: const Row(children: [Icon(Icons.shopping_bag_outlined), SizedBox(width: 10), Text('KHAN FOOTWEAR', style: TextStyle(fontWeight: FontWeight.w800))]), actions: [if (MediaQuery.sizeOf(context).width > 750) ...[TextButton(onPressed: () {}, child: const Text('Home', style: TextStyle(color: Colors.white))), TextButton(onPressed: () {}, child: const Text('Shop', style: TextStyle(color: Colors.white))), TextButton(onPressed: () {}, child: const Text('Sale', style: TextStyle(color: Colors.white)))], IconButton(onPressed: () => _login(context), icon: const Icon(Icons.person_outline)), Stack(children: [IconButton(onPressed: () => _cart(context), icon: const Icon(Icons.shopping_cart_outlined)), if (cart.isNotEmpty) Positioned(right: 5, top: 5, child: CircleAvatar(radius: 9, child: Text('${cart.length}', style: const TextStyle(fontSize: 10))))]), const SizedBox(width: 10)]),
      body: CustomScrollView(slivers: [SliverToBoxAdapter(child: _hero()), SliverToBoxAdapter(child: _categories()), SliverToBoxAdapter(child: _header()), SliverPadding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 50), sliver: SliverLayoutBuilder(builder: (_, c) { final w = c.crossAxisExtent; final cols = w >= 1200 ? 4 : w >= 800 ? 3 : w >= 520 ? 2 : 1; return SliverGrid.builder(itemCount: visibleProducts.length, gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cols, crossAxisSpacing: 18, mainAxisSpacing: 18, childAspectRatio: w < 520 ? .82 : .72), itemBuilder: (_, i) => ProductCard(product: visibleProducts[i], onTap: () => showProduct(visibleProducts[i]), onAdd: () => addToCart(visibleProducts[i]))); })), SliverToBoxAdapter(child: _footer())]),
    );
  }

  Widget _hero() => Container(height: 420, padding: const EdgeInsets.all(28), decoration: const BoxDecoration(image: DecorationImage(image: NetworkImage('https://images.unsplash.com/photo-1520256862855-398228c41684?auto=format&fit=crop&w=1800&q=85'), fit: BoxFit.cover)), child: Align(alignment: Alignment.centerLeft, child: Container(constraints: const BoxConstraints(maxWidth: 650), padding: const EdgeInsets.all(28), decoration: BoxDecoration(color: Color.fromRGBO(0,0,0,.58), borderRadius: BorderRadius.all(Radius.circular(18))), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('NEW SEASON COLLECTION', style: TextStyle(color: Color(0xFFFBBF24), fontWeight: FontWeight.bold, letterSpacing: 2)), const SizedBox(height: 12), const Text('Walk in your\nown style.', style: TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w900)), const SizedBox(height: 12), const Text('Chelsea boots, sneakers, formal shoes and everyday footwear.', style: TextStyle(color: Colors.white70, fontSize: 17)), const SizedBox(height: 20), FilledButton(onPressed: () => setState(() => category = 'All'), child: const Text('Shop Collection'))]))));

  Widget _categories() { const cs = ['All','Chelsea Boots','Sneakers','Formal Shoes','Casual Boots','Loafers','Running Shoes']; return Padding(padding: const EdgeInsets.fromLTRB(20,28,20,12), child: Wrap(spacing: 10, runSpacing: 10, alignment: WrapAlignment.center, children: cs.map((c) => ChoiceChip(label: Text(c), selected: category == c, onSelected: (_) => setState(() => category = c)).toList())); }

  Widget _header() => Padding(padding: const EdgeInsets.fromLTRB(20,18,20,20), child: Row(children: [const Expanded(child: Text('Shop our collection', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900))), SizedBox(width: 240, child: TextField(onChanged: (v) => setState(() => search = v), decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: 'Search shoes', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))))]));

  Widget _footer() => Container(width: double.infinity, color: const Color(0xFF111827), padding: const EdgeInsets.all(35), child: const Wrap(alignment: WrapAlignment.spaceEvenly, spacing: 60, runSpacing: 25, children: [_FooterItem(Icons.local_shipping_outlined,'Fast Delivery','Nationwide delivery'), _FooterItem(Icons.lock_outline,'Secure Checkout','Protected data'), _FooterItem(Icons.chat_outlined,'WhatsApp Support','Talk to our team'), _FooterItem(Icons.verified_outlined,'Quality Footwear','Built for style')]));

  void _login(BuildContext context) => showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Login / Create Account'), content: const SizedBox(width: 360, child: Column(mainAxisSize: MainAxisSize.min, children: [TextField(decoration: InputDecoration(labelText: 'Email or phone')), SizedBox(height: 12), TextField(obscureText: true, decoration: InputDecoration(labelText: 'Password'))])), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Login'))]);

  void _cart(BuildContext context) => showDialog(context: context, builder: (_) => AlertDialog(title: Text('Your Cart (${cart.length})'), content: SizedBox(width: 420, child: cart.isEmpty ? const Text('Your cart is empty.') : Column(mainAxisSize: MainAxisSize.min, children: cart.map((p) => ListTile(title: Text(p.name), trailing: Text('Rs. ${p.price.toStringAsFixed(0)}'))).toList())), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')), if (cart.isNotEmpty) FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Checkout'))]);
}

class ProductCard extends StatelessWidget {
  final Product product; final VoidCallback onTap; final VoidCallback onAdd;
  const ProductCard({super.key, required this.product, required this.onTap, required this.onAdd});
  @override
  Widget build(BuildContext context) => Card(clipBehavior: Clip.antiAlias, child: InkWell(onTap: onTap, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: Stack(children: [Positioned.fill(child: Image.network(product.image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.shopping_bag, size: 70)))), Positioned(top: 12, left: 12, child: Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: const Color(0xFFDC2626), borderRadius: BorderRadius.circular(20)), child: Text('${product.discount}% OFF', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))), Positioned(top: 10, right: 10, child: IconButton.filled(onPressed: () {}, icon: const Icon(Icons.favorite_border), style: IconButton.styleFrom(backgroundColor: Colors.white))) ])), Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(product.category.toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(product.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)), const SizedBox(height: 5), const Text('★★★★★', style: TextStyle(color: Color(0xFFF59E0B))), const SizedBox(height: 5), Row(children: [Text('Rs. ${product.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)), const SizedBox(width: 8), Text('Rs. ${product.oldPrice.toStringAsFixed(0)}', style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey))]), const SizedBox(height: 10), SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: onAdd, icon: const Icon(Icons.add_shopping_cart, size: 18), label: const Text('Add to Cart'))]))])));
}

class ProductDetails extends StatefulWidget {
  final Product product; final VoidCallback onAdd;
  const ProductDetails({super.key, required this.product, required this.onAdd});
  @override State<ProductDetails> createState() => _ProductDetailsState();
}
class _ProductDetailsState extends State<ProductDetails> {
  int? size;
  @override
  Widget build(BuildContext context) => SafeArea(child: SingleChildScrollView(child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [ClipRRect(borderRadius: BorderRadius.circular(18), child: Image.network(widget.product.image, height: 300, width: double.infinity, fit: BoxFit.cover)), const SizedBox(height: 20), Text(widget.product.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)), Text(widget.product.description, style: const TextStyle(color: Colors.grey, fontSize: 16)), const SizedBox(height: 14), Row(children: [Text('Rs. ${widget.product.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)), const SizedBox(width: 10), Text('Rs. ${widget.product.oldPrice.toStringAsFixed(0)}', style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey))]), const SizedBox(height: 18), const Text('Select size', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)), const SizedBox(height: 8), Wrap(spacing: 8, children: widget.product.sizes.map((s) => ChoiceChip(label: Text('$s'), selected: size == s, onSelected: (_) => setState(() => size = s))).toList()), const SizedBox(height: 20), Row(children: [Expanded(child: FilledButton.icon(onPressed: size == null ? null : () { widget.onAdd(); Navigator.pop(context); }, icon: const Icon(Icons.add_shopping_cart), label: const Text('Add to Cart'))), const SizedBox(width: 10), OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.chat), label: const Text('WhatsApp'))]), const SizedBox(height: 12), const Text('WhatsApp number is a placeholder. Replace 923000000000 with your business number.', style: TextStyle(color: Colors.grey, fontSize: 12))]))));
}

class _FooterItem extends StatelessWidget {
  final IconData icon; final String title; final String subtitle;
  const _FooterItem(this.icon, this.title, this.subtitle);
  @override Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: Colors.white, size: 32), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12))])]);
}
