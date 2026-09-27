import 'package:flutter/material.dart';

void main() => runApp(const KhanFootwearApp());

class Product {
  final String name, category, image, description;
  final double price, oldPrice;
  final List<int> sizes;
  const Product({required this.name, required this.category, required this.image, required this.description, required this.price, required this.oldPrice, required this.sizes});
  int get discount => (((oldPrice - price) / oldPrice) * 100).round();
}

const products = <Product>[
  Product(name: 'Royal Chelsea', category: 'Chelsea Boots', image: 'https://images.unsplash.com/photo-1638247025967-b4e38f787b76?auto=format&fit=crop&w=1000&q=90', description: 'Premium leather Chelsea boots with a refined silhouette.', price: 6999, oldPrice: 8999, sizes: [40,41,42,43,44]),
  Product(name: 'Urban Runner', category: 'Sneakers', image: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=1000&q=90', description: 'Lightweight everyday sneakers with modern comfort.', price: 5499, oldPrice: 6999, sizes: [39,40,41,42,43,44]),
  Product(name: 'Executive Oxford', category: 'Formal Shoes', image: 'https://images.unsplash.com/photo-1614252369475-531eba835eb1?auto=format&fit=crop&w=1000&q=90', description: 'Polished formal shoes made for important occasions.', price: 6299, oldPrice: 7999, sizes: [40,41,42,43,44]),
  Product(name: 'Desert Classic', category: 'Casual Boots', image: 'https://images.unsplash.com/photo-1520639888713-7851133b1ed0?auto=format&fit=crop&w=1000&q=90', description: 'Durable casual boots with an effortless premium look.', price: 5799, oldPrice: 7499, sizes: [40,41,42,43,44]),
  Product(name: 'Signature Loafer', category: 'Loafers', image: 'https://images.unsplash.com/photo-1533867617858-e7b97e060509?auto=format&fit=crop&w=1000&q=90', description: 'Smart slip-on loafers for work and weekend style.', price: 5199, oldPrice: 6499, sizes: [40,41,42,43]),
  Product(name: 'Street Flex', category: 'Running Shoes', image: 'https://images.unsplash.com/photo-1552346154-21d32810aba3?auto=format&fit=crop&w=1000&q=90', description: 'Responsive running shoes designed for active days.', price: 4799, oldPrice: 5999, sizes: [39,40,41,42,43]),
  Product(name: 'Brown Heritage', category: 'Chelsea Boots', image: 'https://images.unsplash.com/photo-1605812860427-4024433a5c2d?auto=format&fit=crop&w=1000&q=90', description: 'Warm brown Chelsea boots with a heritage finish.', price: 7299, oldPrice: 9499, sizes: [40,41,42,43,44]),
  Product(name: 'Canvas Essential', category: 'Sneakers', image: 'https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77?auto=format&fit=crop&w=1000&q=90', description: 'Clean canvas sneakers for relaxed everyday outfits.', price: 3299, oldPrice: 4299, sizes: [39,40,41,42,43]),
  Product(name: 'Midnight Derby', category: 'Formal Shoes', image: 'https://images.unsplash.com/photo-1449255618147-768b0f3f5eeb?auto=format&fit=crop&w=1000&q=90', description: 'Sharp black derby shoes with a timeless profile.', price: 6799, oldPrice: 8499, sizes: [40,41,42,43,44]),
  Product(name: 'Trail Pro', category: 'Running Shoes', image: 'https://images.unsplash.com/photo-1551107696-a4b0c5a0d9a2?auto=format&fit=crop&w=1000&q=90', description: 'Sporty footwear with cushioning for everyday movement.', price: 4999, oldPrice: 6299, sizes: [39,40,41,42,43]),
];

class KhanFootwearApp extends StatelessWidget {
  const KhanFootwearApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Khan Footwear',
      theme: ThemeData(useMaterial3: true, scaffoldBackgroundColor: const Color(0xFFF7F5F1), colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF171717)), fontFamily: 'Arial'),
      home: const StorePage(),
    );
  }
}

class StorePage extends StatefulWidget {
  const StorePage({super.key});
  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  final ScrollController scroll = ScrollController();
  final List<Product> cart = [];
  String category = 'All';
  String search = '';
  bool menuOpen = false;

  List<Product> get filtered => products.where((p) {
    final a = category == 'All' || p.category == category;
    final b = search.isEmpty || p.name.toLowerCase().contains(search.toLowerCase());
    return a && b;
  }).toList();

  void jumpTo(double position) => scroll.animateTo(position, duration: const Duration(milliseconds: 800), curve: Curves.easeInOutCubic);
  void add(Product p) { setState(() => cart.add(p)); ScaffoldMessenger.of(context).showSnackBar(SnackBar(behavior: SnackBarBehavior.floating, content: Text('${p.name} added to cart'))); }

  @override
  void dispose() { scroll.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 800;
    return Scaffold(
      body: Stack(children: [
        CustomScrollView(controller: scroll, slivers: [
          SliverAppBar(
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF121212),
            foregroundColor: Colors.white,
            expandedHeight: 0,
            title: GestureDetector(onTap: () => jumpTo(0), child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.auto_awesome, size: 20), SizedBox(width: 9), Text('KHAN FOOTWEAR', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5))])),
            actions: [
              if (wide) ...[
                _nav('HOME', () => jumpTo(0)), _nav('SHOP', () => jumpTo(720)), _nav('SALE', () { setState(() => category = 'Chelsea Boots'); jumpTo(720); }),
              ],
              IconButton(onPressed: _login, icon: const Icon(Icons.person_outline)),
              Stack(children: [IconButton(onPressed: _showCart, icon: const Icon(Icons.shopping_bag_outlined)), if (cart.isNotEmpty) Positioned(right: 4, top: 5, child: CircleAvatar(radius: 9, backgroundColor: const Color(0xFFD4A84F), child: Text('${cart.length}', style: const TextStyle(fontSize: 10, color: Colors.black))))]),
              const SizedBox(width: 10),
            ],
          ),
          SliverToBoxAdapter(child: _hero(wide)),
          SliverToBoxAdapter(child: _trustBar(wide)),
          SliverToBoxAdapter(child: _sectionTitle('CURATED COLLECTION', 'Find your signature pair', 'Premium styles for every occasion.')),
          SliverToBoxAdapter(child: _categoryRail()),
          SliverToBoxAdapter(child: _searchBar()),
          SliverPadding(padding: const EdgeInsets.fromLTRB(20, 10, 20, 80), sliver: SliverLayoutBuilder(builder: (_, c) {
            final w = c.crossAxisExtent;
            final cols = w >= 1200 ? 4 : w >= 820 ? 3 : w >= 540 ? 2 : 1;
            return SliverGrid.builder(itemCount: filtered.length, gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cols, crossAxisSpacing: 20, mainAxisSpacing: 24, childAspectRatio: w < 540 ? .76 : .68), itemBuilder: (_, i) => _card(filtered[i]));
          })),
          SliverToBoxAdapter(child: _promo(wide)),
          SliverToBoxAdapter(child: _story(wide)),
          SliverToBoxAdapter(child: _newsletter(wide)),
          SliverToBoxAdapter(child: _footer()),
        ]),
        if (menuOpen) Positioned.fill(child: GestureDetector(onTap: () => setState(() => menuOpen = false), child: Container(color: Colors.black54))),
      ]),
    );
  }

  Widget _nav(String text, VoidCallback action) => TextButton(onPressed: action, child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)));

  Widget _hero(bool wide) {
    return SizedBox(height: wide ? 650 : 560, child: Stack(fit: StackFit.expand, children: [
      Image.network('https://images.unsplash.com/photo-1495555961986-6d4c1ecb7be3?auto=format&fit=crop&w=1800&q=90', fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(color: const Color(0xFF272727))),
      Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Color.fromRGBO(0,0,0,.78), Color.fromRGBO(0,0,0,.30), Color.fromRGBO(0,0,0,.05)]))),
      Positioned(left: wide ? 8 * 5.0 : 24, bottom: 70, right: wide ? 500 : 24, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('THE NEW STANDARD', style: TextStyle(color: Color(0xFFE2B968), fontWeight: FontWeight.bold, letterSpacing: 4, fontSize: 12)),
        const SizedBox(height: 16),
        Text('Step into\nyour story.', style: TextStyle(color: Colors.white, fontSize: wide ? 64 : 46, height: .98, fontWeight: FontWeight.w900)),
        const SizedBox(height: 18),
        const Text('Premium footwear designed for confidence, comfort and everyday style.', style: TextStyle(color: Colors.white70, fontSize: 17, height: 1.5)),
        const SizedBox(height: 28),
        Wrap(spacing: 12, children: [FilledButton(style: FilledButton.styleFrom(backgroundColor: const Color(0xFFD4A84F), foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 17)), onPressed: () => jumpTo(720), child: const Text('SHOP COLLECTION')), OutlinedButton(style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white54), padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 17)), onPressed: () => _showWhatsApp(), child: const Text('CONTACT US'))]),
      ])),
      Positioned(right: 28, bottom: 24, child: Row(children: [const Icon(Icons.keyboard_double_arrow_down, color: Colors.white70), const SizedBox(width: 6), Text('SCROLL TO EXPLORE', style: TextStyle(color: Colors.white.withOpacity(.7), fontSize: 10, letterSpacing: 2))])),
    ]));
  }

  Widget _trustBar(bool wide) => Container(color: const Color(0xFF171717), padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25), child: Wrap(alignment: WrapAlignment.spaceEvenly, spacing: 45, runSpacing: 22, children: const [_Trust(Icons.local_shipping_outlined, 'NATIONWIDE DELIVERY', 'Fast & reliable'), _Trust(Icons.verified_outlined, 'PREMIUM QUALITY', 'Made to last'), _Trust(Icons.sync_alt, 'EASY EXCHANGE', 'Simple process'), _Trust(Icons.support_agent, 'WHATSAPP SUPPORT', 'We are here') ]));

  Widget _sectionTitle(String eyebrow, String title, String sub) => Padding(padding: const EdgeInsets.fromLTRB(22, 80, 22, 30), child: Column(children: [Text(eyebrow, style: const TextStyle(color: Color(0xFFB0873F), fontWeight: FontWeight.bold, letterSpacing: 3, fontSize: 11)), const SizedBox(height: 10), Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w900)), const SizedBox(height: 9), Text(sub, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 15))]));

  Widget _categoryRail() => SizedBox(height: 150, child: ListView(padding: const EdgeInsets.symmetric(horizontal: 20), scrollDirection: Axis.horizontal, children: ['All','Chelsea Boots','Sneakers','Formal Shoes','Casual Boots','Loafers','Running Shoes'].map((c) => GestureDetector(onTap: () => setState(() => category = c), child: Container(width: 150, margin: const EdgeInsets.only(right: 14), decoration: BoxDecoration(color: category == c ? const Color(0xFF171717) : Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE7E2D9))), child: Center(child: Padding(padding: const EdgeInsets.all(15), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(c == 'All' ? Icons.grid_view_rounded : Icons.hiking_outlined, color: category == c ? const Color(0xFFD4A84F) : Colors.black87, size: 30), const SizedBox(height: 10), Text(c, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: category == c ? Colors.white : Colors.black87))]))))).toList()));

  Widget _searchBar() => Padding(padding: const EdgeInsets.fromLTRB(20, 35, 20, 15), child: Row(children: [const Expanded(child: Text('Latest arrivals', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900))), SizedBox(width: 260, child: TextField(onChanged: (v) => setState(() => search = v), decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: 'Search footwear', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none))))]));

  Widget _card(Product p) => TweenAnimationBuilder<double>(tween: Tween(begin: .96, end: 1), duration: const Duration(milliseconds: 500), builder: (_, scale, child) => Transform.scale(scale: scale, child: child), child: Card(elevation: 0, clipBehavior: Clip.antiAlias, color: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)), child: InkWell(onTap: () => _details(p), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: Stack(children: [Positioned.fill(child: Hero(tag: p.name, child: Image.network(p.image, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Center(child: Icon(Icons.image_not_supported_outlined, size: 60))))), Positioned(top: 14, left: 14, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFB83232), borderRadius: BorderRadius.circular(20)), child: Text('${p.discount}% OFF', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)))), Positioned(top: 10, right: 10, child: Material(color: Colors.white, shape: const CircleBorder(), child: IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border))))])), Padding(padding: const EdgeInsets.fromLTRB(16,15,16,16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p.category.toUpperCase(), style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.2)), const SizedBox(height: 6), Text(p.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), const SizedBox(height: 6), const Text('★★★★★', style: TextStyle(color: Color(0xFFD4A84F), letterSpacing: 2)), const SizedBox(height: 8), Row(children: [Text('Rs. ${p.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)), const SizedBox(width: 8), Text('Rs. ${p.oldPrice.toStringAsFixed(0)}', style: const TextStyle(color: Colors.grey, decoration: TextDecoration.lineThrough, fontSize: 12))]), const SizedBox(height: 12), SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () => add(p), child: const Text('ADD TO BAG')))]))]))));

  Widget _promo(bool wide) => Container(margin: const EdgeInsets.symmetric(vertical: 40), height: wide ? 400 : 500, decoration: const BoxDecoration(image: DecorationImage(image: NetworkImage('https://images.unsplash.com/photo-1549298916-b41d501d3772?auto=format&fit=crop&w=1800&q=90'), fit: BoxFit.cover)), child: Container(color: Colors.black54, padding: const EdgeInsets.all(35), child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('LIMITED SEASON OFFER', style: TextStyle(color: Color(0xFFE2B968), letterSpacing: 3, fontWeight: FontWeight.bold)), const SizedBox(height: 15), const Text('UP TO 30% OFF', style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900)), const SizedBox(height: 12), const Text('Upgrade your rotation before the collection moves on.', style: TextStyle(color: Colors.white70, fontSize: 16)), const SizedBox(height: 25), FilledButton(onPressed: () { setState(() => category = 'All'); jumpTo(720); }, child: const Text('SHOP THE SALE'))]))));

  Widget _story(bool wide) => Padding(padding: const EdgeInsets.fromLTRB(25, 80, 25, 70), child: Flex(direction: wide ? Axis.horizontal : Axis.vertical, crossAxisAlignment: CrossAxisAlignment.center, children: [Expanded(flex: wide ? 5 : 0, child: ClipRRect(borderRadius: BorderRadius.circular(25), child: Image.network('https://images.unsplash.com/photo-1551488831-00ddcb6c6bd3?auto=format&fit=crop&w=1200&q=90', height: wide ? 480 : 320, width: double.infinity, fit: BoxFit.cover))), SizedBox(width: wide ? 70 : 0, height: wide ? 0 : 35), Expanded(flex: wide ? 4 : 0, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('OUR PHILOSOPHY', style: TextStyle(color: Color(0xFFB0873F), fontWeight: FontWeight.bold, letterSpacing: 3)), const SizedBox(height: 14), const Text('Style should feel\neffortless.', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, height: 1)), const SizedBox(height: 18), const Text('Khan Footwear brings together timeless silhouettes and modern everyday comfort. Choose your pair, make it yours, and step forward with confidence.', style: TextStyle(color: Colors.grey, fontSize: 16, height: 1.7)), const SizedBox(height: 25), OutlinedButton(onPressed: _showWhatsApp, child: const Text('TALK TO US ON WHATSAPP'))]))]));

  Widget _newsletter(bool wide) => Container(color: const Color(0xFFE9E2D6), padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 70), child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 700), child: Column(children: [const Text('GET FIRST ACCESS', style: TextStyle(color: Color(0xFF9A7537), fontWeight: FontWeight.bold, letterSpacing: 3)), const SizedBox(height: 12), const Text('New drops. Private offers.', textAlign: TextAlign.center, style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900)), const SizedBox(height: 10), const Text('Join our list for new collections and special discounts.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)), const SizedBox(height: 25), Row(children: [const Expanded(child: TextField(decoration: InputDecoration(hintText: 'Your email address', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderSide: BorderSide.none)))), const SizedBox(width: 10), FilledButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thanks! You are on the list.'))), child: const Text('JOIN'))]))));

  Widget _footer() => Container(color: const Color(0xFF121212), padding: const EdgeInsets.fromLTRB(25, 55, 25, 30), child: Column(children: [Wrap(alignment: WrapAlignment.spaceBetween, spacing: 80, runSpacing: 35, children: [const SizedBox(width: 260, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('KHAN FOOTWEAR', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1.5)), SizedBox(height: 14), Text('Premium footwear for your everyday story.', style: TextStyle(color: Colors.white54, height: 1.5))]), _footerLinks('SHOP', ['Chelsea Boots','Sneakers','Formal Shoes','Loafers']), _footerLinks('HELP', ['Shipping','Returns','Contact','WhatsApp'])]), const SizedBox(height: 45), const Divider(color: Colors.white12), const SizedBox(height: 18), const Text('© 2026 Khan Footwear • All rights reserved', style: TextStyle(color: Colors.white38, fontSize: 12))]));

  Widget _footerLinks(String title, List<String> links) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Color(0xFFD4A84F), fontWeight: FontWeight.bold, letterSpacing: 2)), const SizedBox(height: 12), ...links.map((x) => Padding(padding: const EdgeInsets.only(bottom: 7), child: Text(x, style: const TextStyle(color: Colors.white60))))]);

  void _details(Product p) => showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => ProductDetails(product: p, onAdd: () { add(p); Navigator.pop(context); }));

  void _login() => showDialog(context: context, builder: (_) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)), title: const Text('Welcome back', style: TextStyle(fontWeight: FontWeight.w900)), content: SizedBox(width: 380, child: Column(mainAxisSize: MainAxisSize.min, children: [const Text('Login or create your Khan Footwear account.', style: TextStyle(color: Colors.grey)), const SizedBox(height: 20), const TextField(decoration: InputDecoration(labelText: 'Email or phone', prefixIcon: Icon(Icons.person_outline), border: OutlineInputBorder())), const SizedBox(height: 14), const TextField(obscureText: true, decoration: InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline), border: OutlineInputBorder()))]), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login UI ready — connect your backend next.'))); }, child: const Text('LOGIN'))]));

  void _showCart() => showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => SafeArea(child: Padding(padding: const EdgeInsets.all(22), child: Column(mainAxisSize: MainAxisSize.min, children: [Row(children: [Text('Your Bag (${cart.length})', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)), const Spacer(), IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close))]), const Divider(), if (cart.isEmpty) const Padding(padding: EdgeInsets.all(35), child: Column(children: [Icon(Icons.shopping_bag_outlined, size: 55), SizedBox(height: 12), Text('Your bag is empty')])) else ...cart.map((p) => ListTile(leading: CircleAvatar(backgroundImage: NetworkImage(p.image)), title: Text(p.name), subtitle: Text(p.category), trailing: Text('Rs. ${p.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)))), if (cart.isNotEmpty) SizedBox(width: double.infinity, child: FilledButton(onPressed: () { Navigator.pop(context); _payment(); }, child: const Text('PROCEED TO CHECKOUT')))])));

  void _payment() => showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Choose payment method'), content: Column(mainAxisSize: MainAxisSize.min, children: [ListTile(leading: const Icon(Icons.account_balance_wallet), title: const Text('JazzCash'), onTap: () => Navigator.pop(context)), ListTile(leading: const Icon(Icons.account_balance_wallet_outlined), title: const Text('Easypaisa'), onTap: () => Navigator.pop(context)), ListTile(leading: const Icon(Icons.credit_card), title: const Text('Card / Online Payment'), onTap: () => Navigator.pop(context))]));

  void _showWhatsApp() => showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Contact Khan Footwear'), content: const Text('WhatsApp: +92 300 0000000\n\nReplace this demo number with your real WhatsApp number before launch.'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))]));
}

class ProductDetails extends StatefulWidget {
  final Product product;
  final VoidCallback onAdd;
  const ProductDetails({super.key, required this.product, required this.onAdd});
  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  int selectedSize = 42;
  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return Container(height: MediaQuery.sizeOf(context).height * .88, decoration: const BoxDecoration(color: Color(0xFFF7F5F1), borderRadius: BorderRadius.vertical(top: Radius.circular(28))), child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(height: 430, child: Hero(tag: p.name, child: Image.network(p.image, width: double.infinity, fit: BoxFit.cover))), Padding(padding: const EdgeInsets.all(26), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p.category.toUpperCase(), style: const TextStyle(color: Color(0xFFB0873F), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2)), const SizedBox(height: 8), Text(p.name, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900)), const SizedBox(height: 10), Row(children: [Text('Rs. ${p.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900)), const SizedBox(width: 12), Text('Rs. ${p.oldPrice.toStringAsFixed(0)}', style: const TextStyle(color: Colors.grey, decoration: TextDecoration.lineThrough)), const SizedBox(width: 12), Text('${p.discount}% OFF', style: const TextStyle(color: Color(0xFFB83232), fontWeight: FontWeight.bold))]), const SizedBox(height: 18), Text(p.description, style: const TextStyle(color: Colors.grey, fontSize: 15, height: 1.6)), const SizedBox(height: 22), const Text('SELECT SIZE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)), const SizedBox(height: 12), Wrap(spacing: 9, children: p.sizes.map((size) => ChoiceChip(label: Text('$size'), selected: selectedSize == size, onSelected: (_) => setState(() => selectedSize = size))).toList()), const SizedBox(height: 25), SizedBox(width: double.infinity, height: 52, child: FilledButton.icon(onPressed: widget.onAdd, icon: const Icon(Icons.shopping_bag_outlined), label: Text('ADD SIZE $selectedSize TO BAG')))]))]));
  }
}

class _Trust extends StatelessWidget { final IconData icon; final String title, sub; const _Trust(this.icon, this.title, this.sub); @override Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: const Color(0xFFD4A84F)), const SizedBox(width: 10), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)), Text(sub, style: const TextStyle(color: Colors.white38, fontSize: 10))])]); }

class _FooterItem extends StatelessWidget { final IconData icon; final String title, sub; const _FooterItem(this.icon, this.title, this.sub); @override Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: const Color(0xFFD4A84F)), const SizedBox(width: 10), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), Text(sub, style: const TextStyle(color: Colors.white54, fontSize: 12))])]); }
