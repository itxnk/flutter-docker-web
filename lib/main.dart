import 'package:flutter/material.dart';

void main() => runApp(const KhanFootwearApp());

class Product {
  final String name, category, image;
  final double price, oldPrice;
  final List<int> sizes;
  const Product({required this.name, required this.category, required this.image, required this.price, required this.oldPrice, this.sizes = const [40, 41, 42, 43, 44]});
  int get discount => ((1 - price / oldPrice) * 100).round();
}

const products = <Product>[
  Product(name: 'Royal Chelsea', category: 'Chelsea Boots', image: 'https://images.unsplash.com/photo-1638247025967-b4e38f787b76?auto=format&fit=crop&w=1000&q=90', price: 6999, oldPrice: 8999),
  Product(name: 'Urban Runner', category: 'Sneakers', image: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=1000&q=90', price: 5499, oldPrice: 6999),
  Product(name: 'Executive Oxford', category: 'Formal Shoes', image: 'https://images.unsplash.com/photo-1614252369475-531eba835eb1?auto=format&fit=crop&w=1000&q=90', price: 6299, oldPrice: 7999),
  Product(name: 'Desert Classic', category: 'Casual Boots', image: 'https://images.unsplash.com/photo-1520639888713-7851133b1ed0?auto=format&fit=crop&w=1000&q=90', price: 5799, oldPrice: 7499),
  Product(name: 'Signature Loafer', category: 'Loafers', image: 'https://images.unsplash.com/photo-1533867617858-e7b97e060509?auto=format&fit=crop&w=1000&q=90', price: 5199, oldPrice: 6499),
  Product(name: 'Street Flex', category: 'Running Shoes', image: 'https://images.unsplash.com/photo-1552346154-21d32810aba3?auto=format&fit=crop&w=1000&q=90', price: 4799, oldPrice: 5999),
  Product(name: 'Brown Heritage', category: 'Chelsea Boots', image: 'https://images.unsplash.com/photo-1605812860427-4024433a5c2d?auto=format&fit=crop&w=1000&q=90', price: 7299, oldPrice: 9499),
  Product(name: 'Canvas Essential', category: 'Sneakers', image: 'https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77?auto=format&fit=crop&w=1000&q=90', price: 3299, oldPrice: 4299),
  Product(name: 'Midnight Derby', category: 'Formal Shoes', image: 'https://images.unsplash.com/photo-1449255618147-768b0f3f5eeb?auto=format&fit=crop&w=1000&q=90', price: 6799, oldPrice: 8499),
  Product(name: 'Trail Pro', category: 'Running Shoes', image: 'https://images.unsplash.com/photo-1551107696-a4b0c5a0d9a2?auto=format&fit=crop&w=1000&q=90', price: 4999, oldPrice: 6299),
];

class KhanFootwearApp extends StatelessWidget {
  const KhanFootwearApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(debugShowCheckedModeBanner: false, title: 'Khan Footwear', theme: ThemeData(useMaterial3: true, scaffoldBackgroundColor: const Color(0xFFF7F5F1), colorSchemeSeed: Colors.black), home: const StorePage());
}

class StorePage extends StatefulWidget {
  const StorePage({super.key});
  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  final controller = ScrollController();
  final cart = <Product>[];
  String category = 'All';
  String search = '';

  List<Product> get filtered => products.where((p) => (category == 'All' || p.category == category) && (search.isEmpty || p.name.toLowerCase().contains(search.toLowerCase()))).toList();
  void add(Product p) { setState(() => cart.add(p)); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${p.name} added to bag'))); }
  void go(double y) => controller.animateTo(y, duration: const Duration(milliseconds: 700), curve: Curves.easeInOut);
  @override void dispose() { controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 800;
    return Scaffold(
      body: CustomScrollView(controller: controller, slivers: [
        SliverAppBar(pinned: true, backgroundColor: Colors.black, foregroundColor: Colors.white, title: const Text('KHAN FOOTWEAR', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)), actions: [if (wide) _nav('NEW ARRIVALS', () => go(650)), if (wide) _nav('MEN', () => setState(() => category = 'Formal Shoes')), if (wide) _nav('WOMEN', () => setState(() => category = 'Sneakers')), if (wide) _nav('SALE', () => go(650)), IconButton(onPressed: _login, icon: const Icon(Icons.person_outline)), Stack(children: [IconButton(onPressed: _cart, icon: const Icon(Icons.shopping_bag_outlined)), if (cart.isNotEmpty) Positioned(right: 3, top: 4, child: CircleAvatar(radius: 9, backgroundColor: const Color(0xFFD4A84F), child: Text('${cart.length}', style: const TextStyle(fontSize: 10))))])]),
        SliverToBoxAdapter(child: _hero(wide)),
        SliverToBoxAdapter(child: _announcement()),
        SliverToBoxAdapter(child: _heading('NEW ARRIVALS', 'Spring / Summer Collection', 'Comfort-led footwear for every occasion.')),
        SliverToBoxAdapter(child: _categories()),
        SliverToBoxAdapter(child: _search()),
        SliverPadding(padding: const EdgeInsets.all(20), sliver: SliverLayoutBuilder(builder: (_, c) { final n = c.crossAxisExtent >= 1200 ? 4 : c.crossAxisExtent >= 800 ? 3 : 2; return SliverGrid.builder(itemCount: filtered.length, gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: n, crossAxisSpacing: 18, mainAxisSpacing: 22, childAspectRatio: .68), itemBuilder: (_, i) => _card(filtered[i])); })),
        SliverToBoxAdapter(child: _featureBanner()),
        SliverToBoxAdapter(child: _heading('SHOP BY CATEGORY', 'Find your pair', 'Explore our most-loved footwear collections.')),
        SliverToBoxAdapter(child: _categoryTiles()),
        SliverToBoxAdapter(child: _heading('WHY KHAN FOOTWEAR', 'Comfort is the standard', 'Built around the way you live and move.')),
        SliverToBoxAdapter(child: _benefits()),
        SliverToBoxAdapter(child: _newsletter()),
        SliverToBoxAdapter(child: _footer()),
      ]),
    );
  }

  Widget _nav(String text, VoidCallback fn) => TextButton(onPressed: fn, child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)));

  Widget _hero(bool wide) => SizedBox(height: wide ? 650 : 560, child: Stack(fit: StackFit.expand, children: [Image.network('https://images.unsplash.com/photo-1495555961986-6d4c1ecb7be3?auto=format&fit=crop&w=1800&q=90', fit: BoxFit.cover), Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Color.fromRGBO(0,0,0,.82), Color.fromRGBO(0,0,0,.3), Colors.transparent]))), Positioned(left: wide ? 70 : 24, bottom: 65, right: 30, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('THE NEW STANDARD', style: TextStyle(color: Color(0xFFD4A84F), letterSpacing: 3, fontWeight: FontWeight.bold)), const SizedBox(height: 12), Text('STEP INTO\nYOUR STORY.', style: TextStyle(color: Colors.white, fontSize: wide ? 62 : 45, height: .95, fontWeight: FontWeight.w900)), const SizedBox(height: 15), const Text('Premium footwear. Everyday comfort.', style: TextStyle(color: Colors.white70, fontSize: 17)), const SizedBox(height: 25), FilledButton(onPressed: () => go(700), style: FilledButton.styleFrom(backgroundColor: const Color(0xFFD4A84F), foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 17)), child: const Text('SHOP NOW'))]))]));

  Widget _announcement() => Container(width: double.infinity, color: Colors.black, padding: const EdgeInsets.symmetric(vertical: 16), child: const Center(child: Text('FREE SHIPPING ON PREPAID ORDERS   •   EASY EXCHANGE   •   WHATSAPP SUPPORT', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: .8))));
  Widget _heading(String eyebrow, String title, String sub) => Padding(padding: const EdgeInsets.fromLTRB(20, 65, 20, 25), child: Column(children: [Text(eyebrow, style: const TextStyle(color: Color(0xFFB0873F), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 3)), const SizedBox(height: 8), Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900)), const SizedBox(height: 8), Text(sub, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey))]));

  Widget _categories() { const list = ['All', 'Chelsea Boots', 'Sneakers', 'Formal Shoes', 'Casual Boots', 'Loafers', 'Running Shoes']; return SizedBox(height: 65, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 20), children: list.map((c) => Padding(padding: const EdgeInsets.only(right: 10), child: ChoiceChip(label: Text(c), selected: category == c, onSelected: (_) => setState(() => category = c)))).toList())); }
  Widget _search() => Padding(padding: const EdgeInsets.fromLTRB(20, 25, 20, 10), child: TextField(onChanged: (v) => setState(() => search = v), decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: 'Search shoes, boots and sneakers', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none))));

  Widget _card(Product p) => Card(clipBehavior: Clip.antiAlias, elevation: 0, color: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), child: InkWell(onTap: () => _details(p), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: Stack(children: [Positioned.fill(child: Image.network(p.image, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.image_not_supported))), Positioned(left: 12, top: 12, child: Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: const Color(0xFFB83232), borderRadius: BorderRadius.circular(20)), child: Text('${p.discount}% OFF', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)))), Positioned(right: 8, top: 8, child: IconButton.filledTonal(onPressed: () {}, icon: const Icon(Icons.favorite_border))) ])), Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p.category.toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)), const SizedBox(height: 5), Text(p.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)), const SizedBox(height: 5), const Text('★★★★★', style: TextStyle(color: Color(0xFFD4A84F))), const SizedBox(height: 6), Row(children: [Text('Rs. ${p.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)), const SizedBox(width: 8), Text('Rs. ${p.oldPrice.toStringAsFixed(0)}', style: const TextStyle(color: Colors.grey, decoration: TextDecoration.lineThrough, fontSize: 12))]), const SizedBox(height: 9), SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () => add(p), child: const Text('ADD TO BAG')))]))]));

  Widget _featureBanner() => Container(margin: const EdgeInsets.only(top: 45), padding: const EdgeInsets.all(45), color: const Color(0xFF171717), child: Wrap(alignment: WrapAlignment.spaceAround, spacing: 30, runSpacing: 25, children: const [_Benefit(Icons.local_shipping_outlined, 'FAST DELIVERY', 'Nationwide shipping'), _Benefit(Icons.sync_alt, 'EASY EXCHANGE', 'Simple exchange support'), _Benefit(Icons.verified_outlined, 'QUALITY FIRST', 'Premium comfort'), _Benefit(Icons.lock_outline, 'SECURE CHECKOUT', 'Safe payment options')]));

  Widget _categoryTiles() => Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: LayoutBuilder(builder: (_, b) { final w = b.maxWidth >= 900 ? (b.maxWidth - 32) / 3 : (b.maxWidth - 12) / 2; final data = [('MEN', 'Formal Shoes', products[2].image), ('SNEAKERS', 'Everyday Style', products[1].image), ('BOOTS', 'Chelsea & Casual', products[0].image)]; return Wrap(spacing: 16, runSpacing: 16, children: data.map((x) => SizedBox(width: w, height: 300, child: Stack(fit: StackFit.expand, children: [ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.network(x.$3, fit: BoxFit.cover)), Container(decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(16)), gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black87]))), Positioned(left: 20, bottom: 20, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(x.$1, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)), Text(x.$2, style: const TextStyle(color: Colors.white70))]))]))).toList()); })); }

  Widget _benefits() => Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Wrap(alignment: WrapAlignment.center, spacing: 15, runSpacing: 15, children: const [_BenefitCard(Icons.air, 'LIGHTWEIGHT', 'Comfort that stays with you all day.'), _BenefitCard(Icons.favorite_border, 'MADE WITH CARE', 'Designed for modern everyday life.'), _BenefitCard(Icons.support_agent, 'CUSTOMER SUPPORT', 'Help when you need it.'), _BenefitCard(Icons.phone_android, 'EASY ORDERING', 'Shop from desktop or mobile.') ]));
  Widget _newsletter() => Container(margin: const EdgeInsets.only(top: 70), padding: const EdgeInsets.all(45), color: const Color(0xFFECE8E0), child: Column(children: const [Text('JOIN THE KHAN CLUB', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)), SizedBox(height: 8), Text('New arrivals, offers and footwear stories — straight to your inbox.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)), SizedBox(height: 18), SizedBox(width: 500, child: TextField(decoration: InputDecoration(filled: true, fillColor: Colors.white, hintText: 'Email address', suffixIcon: Icon(Icons.arrow_forward), border: OutlineInputBorder(borderSide: BorderSide.none))))]));
  Widget _footer() => Container(width: double.infinity, padding: const EdgeInsets.all(35), color: Colors.black, child: const Column(children: [Text('KHAN FOOTWEAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2)), SizedBox(height: 12), Text('Premium footwear for Pakistan', style: TextStyle(color: Colors.white60)), SizedBox(height: 20), Text('Customer Care   |   Shipping & Returns   |   Contact   |   Privacy   |   Terms', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)), SizedBox(height: 20), Text('© 2026 Khan Footwear', style: TextStyle(color: Colors.white38))]));

  void _login() => showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Login / Create Account'), content: const SizedBox(width: 380, child: Column(mainAxisSize: MainAxisSize.min, children: [TextField(decoration: InputDecoration(labelText: 'Email or phone')), SizedBox(height: 12), TextField(obscureText: true, decoration: InputDecoration(labelText: 'Password'))])), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Create account')), FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Login'))]));

  void _cart() => showDialog(context: context, builder: (_) => AlertDialog(title: Text('Shopping Bag (${cart.length})'), content: SizedBox(width: 430, child: cart.isEmpty ? const Text('Your bag is empty.') : Column(mainAxisSize: MainAxisSize.min, children: cart.map((p) => ListTile(title: Text(p.name), subtitle: Text(p.category), trailing: Text('Rs. ${p.price.toStringAsFixed(0)}'))).toList())), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Continue shopping')), if (cart.isNotEmpty) FilledButton(onPressed: () { Navigator.pop(context); _checkout(); }, child: const Text('Checkout'))]));

  void _checkout() => showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Checkout'), content: const SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [TextField(decoration: InputDecoration(labelText: 'Full name')), TextField(decoration: InputDecoration(labelText: 'Phone')), TextField(decoration: InputDecoration(labelText: 'Delivery address')), SizedBox(height: 15), ListTile(leading: Icon(Icons.account_balance_wallet_outlined), title: Text('JazzCash'), subtitle: Text('Payment option')), ListTile(leading: Icon(Icons.payments_outlined), title: Text('Easypaisa'), subtitle: Text('Payment option')), ListTile(leading: Icon(Icons.local_shipping_outlined), title: Text('Cash on Delivery'))])), actions: [FilledButton(onPressed: () => Navigator.pop(context), child: const Text('PLACE ORDER'))]));

  void _details(Product p) => showDialog(context: context, builder: (_) => Dialog(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 850), child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [ClipRRect(borderRadius: BorderRadius.circular(18), child: Image.network(p.image, height: 360, width: double.infinity, fit: BoxFit.cover)), const SizedBox(height: 20), Text(p.category.toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)), const SizedBox(height: 6), Text(p.name, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)), const SizedBox(height: 10), Text('Rs. ${p.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)), Text('Rs. ${p.oldPrice.toStringAsFixed(0)}', style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey)), const SizedBox(height: 20), const Text('Select size', style: TextStyle(fontWeight: FontWeight.bold)), Wrap(spacing: 8, children: p.sizes.map((s) => ChoiceChip(label: Text('$s'), selected: s == 41, onSelected: (_) {})).toList()), const SizedBox(height: 20), SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () { Navigator.pop(context); add(p); }, icon: const Icon(Icons.shopping_bag_outlined), label: const Text('ADD TO BAG')))]))));
}

class _Benefit extends StatelessWidget { final IconData icon; final String title, text; const _Benefit(this.icon, this.title, this.text); @override Widget build(BuildContext context) => SizedBox(width: 210, child: Row(children: [Icon(icon, color: const Color(0xFFD4A84F), size: 30), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)), Text(text, style: const TextStyle(color: Colors.white60, fontSize: 11))]))])); }
class _BenefitCard extends StatelessWidget { final IconData icon; final String title, text; const _BenefitCard(this.icon, this.title, this.text); @override Widget build(BuildContext context) => Container(width: 250, padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: Column(children: [Icon(icon, size: 32), const SizedBox(height: 12), Text(title, style: const TextStyle(fontWeight: FontWeight.w900)), const SizedBox(height: 7), Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, height: 1.4))])); }
