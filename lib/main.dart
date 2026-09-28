import 'package:flutter/material.dart';

void main() => runApp(const KhanFootwearApp());

class Product {
  final String name;
  final String category;
  final String image;
  final double price;
  final double oldPrice;
  final String color;
  const Product({required this.name, required this.category, required this.image, required this.price, required this.oldPrice, required this.color});
  int get discount => ((1 - price / oldPrice) * 100).round();
}

const products = <Product>[
  Product(name: 'Royal Chelsea', category: 'Chelsea Boots', image: 'https://images.unsplash.com/photo-1638247025967-b4e38f787b76?auto=format&fit=crop&w=1000&q=90', price: 6999, oldPrice: 8999, color: 'Black'),
  Product(name: 'Urban Runner', category: 'Sneakers', image: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=1000&q=90', price: 5499, oldPrice: 6999, color: 'Red'),
  Product(name: 'Executive Oxford', category: 'Formal Shoes', image: 'https://images.unsplash.com/photo-1614252369475-531eba835eb1?auto=format&fit=crop&w=1000&q=90', price: 6299, oldPrice: 7999, color: 'Brown'),
  Product(name: 'Desert Classic', category: 'Casual Boots', image: 'https://images.unsplash.com/photo-1520639888713-7851133b1ed0?auto=format&fit=crop&w=1000&q=90', price: 5799, oldPrice: 7499, color: 'Tan'),
  Product(name: 'Signature Loafer', category: 'Loafers', image: 'https://images.unsplash.com/photo-1533867617858-e7b97e060509?auto=format&fit=crop&w=1000&q=90', price: 5199, oldPrice: 6499, color: 'Brown'),
  Product(name: 'Street Flex', category: 'Running Shoes', image: 'https://images.unsplash.com/photo-1552346154-21d32810aba3?auto=format&fit=crop&w=1000&q=90', price: 4799, oldPrice: 5999, color: 'White'),
  Product(name: 'Heritage Chelsea', category: 'Chelsea Boots', image: 'https://images.unsplash.com/photo-1605812860427-4024433a5c2d?auto=format&fit=crop&w=1000&q=90', price: 7299, oldPrice: 9499, color: 'Dark Brown'),
  Product(name: 'Canvas Essential', category: 'Sneakers', image: 'https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77?auto=format&fit=crop&w=1000&q=90', price: 3299, oldPrice: 4299, color: 'White'),
  Product(name: 'Midnight Derby', category: 'Formal Shoes', image: 'https://images.unsplash.com/photo-1449255618147-768b0f3f5eeb?auto=format&fit=crop&w=1000&q=90', price: 6799, oldPrice: 8499, color: 'Black'),
  Product(name: 'Trail Pro', category: 'Running Shoes', image: 'https://images.unsplash.com/photo-1551107696-a4b0c5a0d9a2?auto=format&fit=crop&w=1000&q=90', price: 4999, oldPrice: 6299, color: 'Grey'),
  Product(name: 'Classic Monk', category: 'Formal Shoes', image: 'https://images.unsplash.com/photo-1614252369475-531eba835eb1?auto=format&fit=crop&w=1000&q=85', price: 5999, oldPrice: 7599, color: 'Black'),
  Product(name: 'Weekend Low', category: 'Casual Shoes', image: 'https://images.unsplash.com/photo-1549298916-b41d501d3772?auto=format&fit=crop&w=1000&q=90', price: 3999, oldPrice: 4999, color: 'White'),
];

class KhanFootwearApp extends StatelessWidget {
  const KhanFootwearApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Khan Footwear',
    theme: ThemeData(useMaterial3: true, scaffoldBackgroundColor: const Color(0xFFF7F6F2), colorSchemeSeed: Colors.black, fontFamily: 'Arial'),
    home: const HomePage(),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final scroll = ScrollController();
  final searchController = TextEditingController();
  final cart = <Product>[];
  final wishlist = <Product>[];
  String selectedCategory = 'All';
  String search = '';
  bool showSearch = false;

  List<Product> get visibleProducts => products.where((p) {
    final cat = selectedCategory == 'All' || p.category == selectedCategory;
    final q = search.trim().isEmpty || p.name.toLowerCase().contains(search.toLowerCase()) || p.category.toLowerCase().contains(search.toLowerCase());
    return cat && q;
  }).toList();

  void jump(double y) => scroll.animateTo(y, duration: const Duration(milliseconds: 700), curve: Curves.easeOutCubic);
  void add(Product p) {
    setState(() => cart.add(p));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration: const Duration(seconds: 1), content: Text('${p.name} added to bag')));
  }
  void toggleWish(Product p) => setState(() => wishlist.contains(p) ? wishlist.remove(p) : wishlist.add(p));

  @override
  void dispose() { scroll.dispose(); searchController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final desktop = width >= 1000;
    return Scaffold(
      body: CustomScrollView(controller: scroll, slivers: [
        SliverToBoxAdapter(child: _topStrip()),
        SliverAppBar(pinned: true, toolbarHeight: 76, backgroundColor: Colors.white, surfaceTintColor: Colors.white, titleSpacing: desktop ? 42 : 12, title: GestureDetector(onTap: () => jump(0), child: const Text('KHAN', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900, letterSpacing: 5))),
          actions: desktop ? _desktopNav() : [IconButton(onPressed: () => setState(() => showSearch = !showSearch), icon: const Icon(Icons.search)), _cartButton()],),
        if (showSearch) SliverToBoxAdapter(child: _searchBar()),
        SliverToBoxAdapter(child: _hero()),
        SliverToBoxAdapter(child: _quickLinks()),
        SliverToBoxAdapter(child: _sectionTitle('NEW SEASON', 'Made for every move', 'Fresh silhouettes, premium materials and everyday comfort.')),
        SliverToBoxAdapter(child: _categoryChips()),
        SliverToBoxAdapter(child: _productToolbar()),
        SliverPadding(padding: const EdgeInsets.fromLTRB(24, 12, 24, 55), sliver: SliverLayoutBuilder(builder: (context, constraints) {
          final n = constraints.crossAxisExtent >= 1400 ? 4 : constraints.crossAxisExtent >= 900 ? 3 : 2;
          return SliverGrid.builder(itemCount: visibleProducts.length, gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: n, crossAxisSpacing: 18, mainAxisSpacing: 25, childAspectRatio: .68), itemBuilder: (_, i) => _productCard(visibleProducts[i]));
        })),
        SliverToBoxAdapter(child: _splitCampaign()),
        SliverToBoxAdapter(child: _sectionTitle('THE EDIT', 'Shop the look', 'Curated collections for workdays, weekends and nights out.')),
        SliverToBoxAdapter(child: _lookbook()),
        SliverToBoxAdapter(child: _marquee()),
        SliverToBoxAdapter(child: _sectionTitle('BESTSELLERS', 'The pairs everyone wants', 'Our most-loved styles, selected by customers.')),
        SliverToBoxAdapter(child: _horizontalProducts()),
        SliverToBoxAdapter(child: _story()),
        SliverToBoxAdapter(child: _reviews()),
        SliverToBoxAdapter(child: _serviceBar()),
        SliverToBoxAdapter(child: _newsletter()),
        SliverToBoxAdapter(child: _footer()),
      ]),
      bottomNavigationBar: width < 700 ? NavigationBar(selectedIndex: 0, destinations: const [NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'), NavigationDestination(icon: Icon(Icons.grid_view_outlined), label: 'Shop'), NavigationDestination(icon: Icon(Icons.favorite_border), label: 'Saved'), NavigationDestination(icon: Icon(Icons.person_outline), label: 'Account')]) : null,
    );
  }

  List<Widget> _desktopNav() => [
    _nav('MEN', () => _setCategory('Formal Shoes')),
    _nav('WOMEN', () => _setCategory('Sneakers')),
    _nav('BOOTS', () => _setCategory('Chelsea Boots')),
    _nav('SNEAKERS', () => _setCategory('Running Shoes')),
    _nav('SALE', () => jump(900)),
    IconButton(onPressed: () => setState(() => showSearch = !showSearch), icon: const Icon(Icons.search)),
    IconButton(onPressed: () => _showLogin(), icon: const Icon(Icons.person_outline)),
    _cartButton(),
    const SizedBox(width: 25),
  ];

  Widget _nav(String text, VoidCallback fn) => TextButton(onPressed: fn, child: Text(text, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1)));
  Widget _cartButton() => Stack(children: [IconButton(onPressed: _showCart, icon: const Icon(Icons.shopping_bag_outlined)), if (cart.isNotEmpty) Positioned(right: 4, top: 4, child: CircleAvatar(radius: 9, backgroundColor: Colors.black, foregroundColor: Colors.white, child: Text('${cart.length}', style: const TextStyle(fontSize: 9))))]);
  void _setCategory(String c) { setState(() => selectedCategory = c); jump(750); }

  Widget _topStrip() => Container(height: 34, color: Colors.black, alignment: Alignment.center, child: const Text('FREE SHIPPING OVER RS. 5,000  •  EASY EXCHANGE  •  WHATSAPP SUPPORT', style: TextStyle(color: Colors.white, fontSize: 10, letterSpacing: .7, fontWeight: FontWeight.bold)));
  Widget _searchBar() => Container(color: Colors.white, padding: const EdgeInsets.fromLTRB(30, 10, 30, 18), child: TextField(controller: searchController, autofocus: true, onChanged: (v) => setState(() => search = v), decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: 'Search products, categories and collections...', filled: true, fillColor: const Color(0xFFF4F3EF), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))));

  Widget _hero() => SizedBox(height: 670, child: Stack(fit: StackFit.expand, children: [
    Image.network('https://images.unsplash.com/photo-1495555961986-6d4c1ecb7be3?auto=format&fit=crop&w=1900&q=90', fit: BoxFit.cover),
    Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Color.fromRGBO(0, 0, 0, 0.82), Color.fromRGBO(0, 0, 0, 0.35), Colors.transparent]))),
    Positioned(left: MediaQuery.sizeOf(context).width * 0.075, bottom: 75, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('AUTUMN / WINTER 2026', style: TextStyle(color: Color(0xFFE0B96B), letterSpacing: 3, fontWeight: FontWeight.bold)), const SizedBox(height: 16), const Text('WALK YOUR\nOWN WAY.', style: TextStyle(color: Colors.white, fontSize: 65, height: .9, fontWeight: FontWeight.w900)), const SizedBox(height: 18), const SizedBox(width: 430, child: Text('A new collection of confident classics and modern essentials, designed in Pakistan for everyday life.', style: TextStyle(color: Colors.white70, fontSize: 17, height: 1.5))), const SizedBox(height: 28), Row(children: [FilledButton(onPressed: () => jump(730), style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18)), child: const Text('SHOP MEN')), const SizedBox(width: 12), OutlinedButton(onPressed: () => _setCategory('Sneakers'), style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white), padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 17)), child: const Text('EXPLORE SNEAKERS'))])]))
  ]));

  Widget _quickLinks() => Container(padding: const EdgeInsets.symmetric(vertical: 24), color: Colors.white, child: Wrap(alignment: WrapAlignment.spaceEvenly, spacing: 25, runSpacing: 20, children: const [_MiniFeature(Icons.local_shipping_outlined, 'FREE DELIVERY', 'On qualifying orders'), _MiniFeature(Icons.autorenew, 'EASY EXCHANGE', 'Simple 7-day exchange'), _MiniFeature(Icons.verified_outlined, 'AUTHENTIC QUALITY', 'Made to last'), _MiniFeature(Icons.support_agent, 'WHATSAPP CARE', 'We are here to help')]);

  Widget _sectionTitle(String eyebrow, String title, String subtitle) => Padding(padding: const EdgeInsets.fromLTRB(20, 72, 20, 32), child: Column(children: [Text(eyebrow, style: const TextStyle(color: Color(0xFF9A763C), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 3)), const SizedBox(height: 10), Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w900, letterSpacing: -.7)), const SizedBox(height: 10), Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 15))]));

  Widget _categoryChips() { const cats = ['All', 'Chelsea Boots', 'Sneakers', 'Formal Shoes', 'Casual Boots', 'Loafers', 'Running Shoes', 'Casual Shoes']; return SizedBox(height: 58, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 24), children: cats.map((c) => Padding(padding: const EdgeInsets.only(right: 9), child: ChoiceChip(label: Text(c), selected: selectedCategory == c, onSelected: (_) => setState(() => selectedCategory = c)))).toList())); }
  Widget _productToolbar() => Padding(padding: const EdgeInsets.fromLTRB(24, 20, 24, 5), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('${visibleProducts.length} products', style: const TextStyle(color: Colors.grey, fontSize: 13)), OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.tune, size: 17), label: const Text('FILTER & SORT'))]));

  Widget _productCard(Product p) => Card(color: Colors.white, elevation: 0, clipBehavior: Clip.antiAlias, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), child: InkWell(onTap: () => _showProduct(p), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: Stack(children: [Positioned.fill(child: Image.network(p.image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.image_not_supported)))), Positioned(left: 12, top: 12, child: Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(3)), child: Text('${p.discount}% OFF', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))), Positioned(right: 8, top: 8, child: IconButton.filledTonal(onPressed: () => toggleWish(p), icon: Icon(wishlist.contains(p) ? Icons.favorite : Icons.favorite_border))) ])), Padding(padding: const EdgeInsets.all(15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p.category.toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 9, letterSpacing: 1, fontWeight: FontWeight.bold)), const SizedBox(height: 6), Text(p.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)), const SizedBox(height: 7), const Text('★★★★★', style: TextStyle(color: Color(0xFFB88939), fontSize: 12)), const SizedBox(height: 7), Row(children: [Text('Rs. ${p.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)), const SizedBox(width: 8), Text('Rs. ${p.oldPrice.toStringAsFixed(0)}', style: const TextStyle(color: Colors.grey, fontSize: 12, decoration: TextDecoration.lineThrough))]), const SizedBox(height: 10), SizedBox(width: double.infinity, child: FilledButton(onPressed: () => add(p), child: const Text('ADD TO BAG')))]))]));

  Widget _splitCampaign() => LayoutBuilder(builder: (context, b) { final vertical = b.maxWidth < 800; final children = [_campaignImage('https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=1200&q=90', 'THE SNEAKER EDIT', 'Clean lines. Daily comfort.', 'SHOP SNEAKERS'), _campaignImage('https://images.unsplash.com/photo-1638247025967-b4e38f787b76?auto=format&fit=crop&w=1200&q=90', 'THE BOOT ROOM', 'Built for colder days.', 'SHOP BOOTS')]; return Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Flex(direction: vertical ? Axis.vertical : Axis.horizontal, children: children.map((x) => Expanded(flex: 1, child: Padding(padding: EdgeInsets.only(bottom: vertical ? 16 : 0, right: (!vertical && x != children.last) ? 8 : 0, left: (!vertical && x != children.first) ? 8 : 0), child: x))).toList())); });
  Widget _campaignImage(String image, String eyebrow, String title, String button) => SizedBox(height: 520, child: Stack(fit: StackFit.expand, children: [Image.network(image, fit: BoxFit.cover), Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Color.fromRGBO(0, 0, 0, 0.8)]))), Positioned(left: 30, bottom: 32, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(eyebrow, style: const TextStyle(color: Color(0xFFE0B96B), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2)), const SizedBox(height: 8), Text(title, style: const TextStyle(color: Colors.white, fontSize: 29, fontWeight: FontWeight.w900)), const SizedBox(height: 16), OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white)), child: Text(button))]))]));

  Widget _lookbook() => SizedBox(height: 500, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 24), children: [_look('https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77?auto=format&fit=crop&w=1000&q=90', 'WEEKEND'), _look('https://images.unsplash.com/photo-1614252369475-531eba835eb1?auto=format&fit=crop&w=1000&q=90', 'WORKWEAR'), _look('https://images.unsplash.com/photo-1520639888713-7851133b1ed0?auto=format&fit=crop&w=1000&q=90', 'OUTDOOR'), _look('https://images.unsplash.com/photo-1549298916-b41d501d3772?auto=format&fit=crop&w=1000&q=90', 'EVERYDAY')]);
  Widget _look(String image, String title) => Container(width: 340, margin: const EdgeInsets.only(right: 16), child: Stack(fit: StackFit.expand, children: [Image.network(image, fit: BoxFit.cover), Align(alignment: Alignment.bottomCenter, child: Container(width: double.infinity, padding: const EdgeInsets.all(24), color: Colors.black54, child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900, letterSpacing: 2))))]));
  Widget _marquee() => Container(color: Colors.black, padding: const EdgeInsets.symmetric(vertical: 22), child: const Center(child: Text('KHAN FOOTWEAR   •   WALK YOUR OWN WAY   •   KHAN FOOTWEAR   •   WALK YOUR OWN WAY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2))));
  Widget _horizontalProducts() => SizedBox(height: 475, child: ListView(padding: const EdgeInsets.symmetric(horizontal: 24), scrollDirection: Axis.horizontal, children: products.take(6).map((p) => SizedBox(width: 290, child: Padding(padding: const EdgeInsets.only(right: 16), child: _productCard(p)))).toList());

  Widget _story() => Container(margin: const EdgeInsets.only(top: 70), padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 80), color: const Color(0xFFE9E4DB), child: LayoutBuilder(builder: (context, b) { final vertical = b.maxWidth < 800; final text = Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [const Text('OUR STORY', style: TextStyle(color: Color(0xFF9A763C), fontWeight: FontWeight.bold, letterSpacing: 3)), const SizedBox(height: 14), const Text('Designed for real life.', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900)), const SizedBox(height: 16), const Text('Khan Footwear brings timeless design together with practical comfort. From the office to the weekend, every pair is made to become part of your everyday story.', style: TextStyle(color: Colors.black54, fontSize: 16, height: 1.7)), const SizedBox(height: 25), OutlinedButton(onPressed: () {}, child: const Text('DISCOVER KHAN'))]); final image = ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.network('https://images.unsplash.com/photo-1449247709967-d4461a6a6103?auto=format&fit=crop&w=1200&q=90', height: 440, width: double.infinity, fit: BoxFit.cover)); return Flex(direction: vertical ? Axis.vertical : Axis.horizontal, children: [Expanded(flex: 5, child: text), const SizedBox(width: 45, height: 35), Expanded(flex: 6, child: image)]); }));

  Widget _reviews() => Padding(padding: const EdgeInsets.fromLTRB(24, 65, 24, 75), child: Wrap(alignment: WrapAlignment.center, spacing: 18, runSpacing: 18, children: const [_Review('“Excellent quality and very comfortable. The Chelsea boots look even better in person.”', 'HAMZA K.', 'Lahore'), _Review('“Fast delivery and the size guide was accurate. Will definitely order again.”', 'ALI R.', 'Islamabad'), _Review('“The formal shoes are perfect for office wear. Great value for the price.”', 'AHMAD S.', 'Peshawar') ]));
  Widget _serviceBar() => Container(color: Colors.white, padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 20), child: Wrap(alignment: WrapAlignment.spaceEvenly, spacing: 30, runSpacing: 25, children: const [_MiniFeature(Icons.credit_card, 'SECURE PAYMENTS', 'JazzCash • Easypaisa • Cards'), _MiniFeature(Icons.location_on_outlined, 'PAKISTAN WIDE', 'Delivery across Pakistan'), _MiniFeature(Icons.phone_in_talk_outlined, 'NEED HELP?', 'WhatsApp our team'), _MiniFeature(Icons.verified_user_outlined, 'TRUSTED SHOP', 'Secure checkout') ]));
  Widget _newsletter() => Container(padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 65), color: Colors.black, child: Column(children: [const Text('JOIN THE KHAN CLUB', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 1)), const SizedBox(height: 10), const Text('Get first access to new drops, private offers and stories.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white60)), const SizedBox(height: 22), SizedBox(width: 520, child: TextField(decoration: InputDecoration(filled: true, fillColor: Colors.white, hintText: 'Your email address', suffixIcon: IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_forward)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(2), borderSide: BorderSide.none))))]));
  Widget _footer() => Container(color: const Color(0xFF111111), padding: const EdgeInsets.fromLTRB(30, 55, 30, 30), child: Column(children: [Wrap(alignment: WrapAlignment.spaceBetween, runSpacing: 35, children: const [_FooterCol('SHOP', ['Men', 'Women', 'Boots', 'Sneakers', 'New Arrivals', 'Sale']), _FooterCol('HELP', ['Contact Us', 'Shipping', 'Returns', 'Size Guide', 'FAQs', 'Track Order']), _FooterCol('ABOUT', ['Our Story', 'Journal', 'Stores', 'Careers', 'Privacy', 'Terms']), _FooterCol('CONNECT', ['Instagram', 'Facebook', 'TikTok', 'WhatsApp', 'Email', 'Customer Care'])]), const SizedBox(height: 50), Divider(color: Colors.white24), const SizedBox(height: 20), Text('© 2026 KHAN FOOTWEAR. ALL RIGHTS RESERVED.', style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1))]));

  void _showLogin() => showDialog(context: context, builder: (d) => AlertDialog(title: const Text('Welcome back'), content: const SizedBox(width: 390, child: Column(mainAxisSize: MainAxisSize.min, children: [TextField(decoration: InputDecoration(labelText: 'Email or mobile number')), SizedBox(height: 12), TextField(obscureText: true, decoration: InputDecoration(labelText: 'Password')), SizedBox(height: 12), Align(alignment: Alignment.centerLeft, child: Text('Forgot password?', style: TextStyle(color: Colors.grey)))])), actions: [TextButton(onPressed: () {}, child: const Text('CREATE ACCOUNT')), FilledButton(onPressed: () => Navigator.pop(d), child: const Text('LOGIN'))]));

  void _showCart() => showDialog(context: context, builder: (d) { final total = cart.fold<double>(0, (sum, p) => sum + p.price); return AlertDialog(title: Text('Shopping Bag (${cart.length})'), content: SizedBox(width: 450, child: cart.isEmpty ? const Padding(padding: EdgeInsets.all(20), child: Text('Your bag is empty. Start shopping and your selected items will appear here.')) : Column(mainAxisSize: MainAxisSize.min, children: [for (final p in cart) ListTile(contentPadding: EdgeInsets.zero, leading: Image.network(p.image, width: 48, height: 48, fit: BoxFit.cover), title: Text(p.name), subtitle: Text(p.category), trailing: Text('Rs. ${p.price.toStringAsFixed(0)}')), const Divider(), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold)), Text('Rs. ${total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w900))])])), actions: [TextButton(onPressed: () => Navigator.pop(d), child: const Text('CONTINUE SHOPPING')), if (cart.isNotEmpty) FilledButton(onPressed: () { Navigator.pop(d); _checkout(); }, child: const Text('CHECKOUT'))])); });

  void _checkout() => showDialog(context: context, builder: (d) => AlertDialog(title: const Text('Secure Checkout'), content: const SizedBox(width: 480, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [TextField(decoration: InputDecoration(labelText: 'Full name')), TextField(decoration: InputDecoration(labelText: 'Phone / WhatsApp')), TextField(decoration: InputDecoration(labelText: 'City')), TextField(decoration: InputDecoration(labelText: 'Complete delivery address')), SizedBox(height: 18), Align(alignment: Alignment.centerLeft, child: Text('PAYMENT METHOD', style: TextStyle(fontWeight: FontWeight.bold))), RadioListTile(value: 1, groupValue: 1, onChanged: null, title: Text('JazzCash'), subtitle: Text('Mobile wallet')), RadioListTile(value: 2, groupValue: 1, onChanged: null, title: Text('Easypaisa'), subtitle: Text('Mobile wallet')), RadioListTile(value: 3, groupValue: 1, onChanged: null, title: Text('Cash on Delivery'))])), actions: [FilledButton(onPressed: () => Navigator.pop(d), child: const Text('PLACE ORDER'))]));

  void _showProduct(Product p) => showDialog(context: context, builder: (d) => Dialog(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 900), child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(4)), child: Image.network(p.image, height: 430, width: double.infinity, fit: BoxFit.cover)), Padding(padding: const EdgeInsets.all(28), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p.category.toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 2)), const SizedBox(height: 8), Text(p.name, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900)), const SizedBox(height: 10), Row(children: [Text('Rs. ${p.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)), const SizedBox(width: 10), Text('Rs. ${p.oldPrice.toStringAsFixed(0)}', style: const TextStyle(color: Colors.grey, decoration: TextDecoration.lineThrough))]), const SizedBox(height: 20), const Text('Available sizes', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 10), Wrap(spacing: 8, children: [40, 41, 42, 43, 44, 45].map((s) => ChoiceChip(label: Text('$s'), selected: s == 42, onSelected: (_) {})).toList()), const SizedBox(height: 25), SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () { Navigator.pop(d); add(p); }, icon: const Icon(Icons.shopping_bag_outlined), label: const Text('ADD TO BAG')))]))]))));
}


class _MiniFeature extends StatelessWidget {
  final IconData icon; final String title, text;
  const _MiniFeature(this.icon, this.title, this.text);
  @override Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 28), const SizedBox(width: 11), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11)), const SizedBox(height: 3), Text(text, style: const TextStyle(color: Colors.grey, fontSize: 11))])]);
}

class _Review extends StatelessWidget {
  final String quote, name, city;
  const _Review(this.quote, this.name, this.city);
  @override Widget build(BuildContext context) => SizedBox(width: 350, child: Card(elevation: 0, color: Colors.white, child: Padding(padding: const EdgeInsets.all(25), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('★★★★★', style: TextStyle(color: Color(0xFFB88939))), const SizedBox(height: 14), Text(quote, style: const TextStyle(fontSize: 15, height: 1.6)), const SizedBox(height: 18), Text(name, style: const TextStyle(fontWeight: FontWeight.bold)), Text(city, style: const TextStyle(color: Colors.grey, fontSize: 12))])));
}

class _FooterCol extends StatelessWidget {
  final String title; final List<String> links;
  const _FooterCol(this.title, this.links);
  @override Widget build(BuildContext context) => SizedBox(width: 190, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)), const SizedBox(height: 15), ...links.map((x) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(x, style: const TextStyle(color: Colors.white54, fontSize: 12))))]));
}
