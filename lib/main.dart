import 'package:flutter/material.dart';

void main() => runApp(const BoatShopApp());

class BoatShopApp extends StatelessWidget {
  const BoatShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BoatShop',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7FAFC),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1477E8)),
        fontFamily: 'Arial',
      ),
      home: const BoatHomePage(),
    );
  }
}

class BoatHomePage extends StatelessWidget {
  const BoatHomePage({super.key});

  static const products = [
    ['Luxury Yacht 60ft', 'https://images.unsplash.com/photo-1567899378494-47b22a2ae96a?auto=format&fit=crop&w=900&q=80', '\$1,200,000'],
    ['Speed Boat 22ft', 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?auto=format&fit=crop&w=900&q=80', '\$85,000'],
    ['Fishing Boat 28ft', 'https://images.unsplash.com/photo-1535024966842-1e5a0d4e2c9d?auto=format&fit=crop&w=900&q=80', '\$120,000'],
    ['Jet Ski GTX 300', 'https://images.unsplash.com/photo-1569263979104-865ab7cd8d13?auto=format&fit=crop&w=900&q=80', '\$12,500'],
    ['Inflatable Boat 10ft', 'https://images.unsplash.com/photo-1605281317010-fe5ffe798166?auto=format&fit=crop&w=900&q=80', '\$1,200'],
  ];

  static const categories = [
    ['Yachts', Icons.directions_boat],
    ['Speed Boats', Icons.speed],
    ['Fishing Boats', Icons.phishing],
    ['Jet Skis', Icons.surfing],
    ['Inflatable Boats', Icons.air],
    ['Engines', Icons.settings],
    ['Accessories', Icons.safety_check],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF123456),
        foregroundColor: Colors.white,
        toolbarHeight: 76,
        titleSpacing: 24,
        title: Row(children: [
          const Icon(Icons.directions_boat, size: 38),
          const SizedBox(width: 10),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('BoatShop', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
            Text('Explore. Sail. Live.', style: TextStyle(fontSize: 11)),
          ]),
        ]),
        actions: [
          if (MediaQuery.sizeOf(context).width > 700) ...[
            TextButton(onPressed: () {}, child: const Text('Home', style: TextStyle(color: Colors.white))),
            TextButton(onPressed: () {}, child: const Text('Shop', style: TextStyle(color: Colors.white))),
            TextButton(onPressed: () {}, child: const Text('About', style: TextStyle(color: Colors.white))),
            TextButton(onPressed: () {}, child: const Text('Contact', style: TextStyle(color: Colors.white))),
          ],
          IconButton(onPressed: () {}, icon: const Icon(Icons.person_outline)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.shopping_cart_outlined)),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          _hero(context),
          _categories(),
          _featured(context),
          _footer(),
        ]),
      ),
    );
  }

  Widget _hero(BuildContext context) => Container(
        height: 370,
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage('https://images.unsplash.com/photo-1569263979104-865ab7cd8d13?auto=format&fit=crop&w=1800&q=85'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 55),
          decoration: BoxDecoration(color: Colors.white.withOpacity(.32)),
          child: Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('PREMIUM BOATS & ACCESSORIES', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF123456), letterSpacing: 1)),
                const SizedBox(height: 14),
                const Text('Your Next Adventure\nStarts Here', style: TextStyle(fontSize: 42, height: 1.1, fontWeight: FontWeight.w800, color: Color(0xFF123456))),
                const SizedBox(height: 16),
                const Text('Discover boats, accessories and gear for your next journey on the water.', style: TextStyle(fontSize: 17, color: Color(0xFF123456))),
                const SizedBox(height: 24),
                FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.arrow_forward), label: const Text('Shop Now'), style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16))),
              ]),
            ),
          ),
        ),
      );

  Widget _categories() => Padding(
        padding: const EdgeInsets.fromLTRB(7, 30, 7, 10),
        child: Wrap(
          spacing: 18,
          runSpacing: 18,
          alignment: WrapAlignment.center,
          children: categories.map((c) => SizedBox(width: 125, child: Column(children: [
            Container(width: 112, height: 82, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(blurRadius: 10, color: Color(0x12000000))]), child: Icon(c[1] as IconData, size: 42, color: const Color(0xFF1477E8))),
            const SizedBox(height: 8), Text(c[0] as String, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
          ]))).toList(),
        ),
      );

  Widget _featured(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(7, 25, 7, 40),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Featured Boats', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFF123456))),
          const SizedBox(height: 18),
          LayoutBuilder(builder: (context, constraints) {
            final width = constraints.maxWidth < 650 ? constraints.maxWidth : (constraints.maxWidth - 64) / 5;
            return Wrap(spacing: 16, runSpacing: 18, children: products.map((p) => SizedBox(width: width.clamp(210, 280), child: _product(p))).toList());
          }),
        ]),
      );

  Widget _product(List<String> p) => Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(height: 170, width: double.infinity, child: Image.network(p[1], fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.directions_boat, size: 70))),
          Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p[0], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 6),
            const Text('★★★★★  4.8 (24)', style: TextStyle(color: Color(0xFFFFA000))),
            const SizedBox(height: 6),
            Text(p[2], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF123456))),
            const SizedBox(height: 10),
            SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.add_shopping_cart), label: const Text('Add to Cart'))),
          ])),
        ],
      );

  Widget _footer() => Container(
        width: double.infinity,
        color: const Color(0xFF123456),
        padding: const EdgeInsets.all(28),
        child: const Wrap(alignment: WrapAlignment.spaceEvenly, spacing: 50, runSpacing: 25, children: [
          _FooterItem(Icons.local_shipping, 'Free Shipping', 'Orders over \$500'),
          _FooterItem(Icons.security, 'Secure Payment', '100% secure checkout'),
          _FooterItem(Icons.headset_mic, '24/7 Support', 'We are here to help'),
          _FooterItem(Icons.verified_user, 'Trusted by Boaters', 'Quality & service guaranteed'),
        ]),
      );
}

class _FooterItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _FooterItem(this.icon, this.title, this.subtitle);

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ]),
      ]);
}
