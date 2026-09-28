import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main()=>runApp(const KhanApp());

class Product{
 final int id,stock; final String name,category,image,description; final double price,oldPrice;
 Product({required this.id,required this.name,required this.category,required this.image,required this.price,required this.oldPrice,required this.description,required this.stock});
 int get discount=>oldPrice>0?((1-price/oldPrice)*100).round():0;
 factory Product.fromJson(Map<String,dynamic> j)=>Product(id:j['id'],name:j['name'],category:j['category'],image:j['image'],price:double.parse(j['price'].toString()),oldPrice:double.parse(j['old_price'].toString()),description:j['description']??'',stock:j['stock']??0);
}

class KhanApp extends StatelessWidget{
 const KhanApp({super.key});
 @override Widget build(BuildContext c)=>MaterialApp(debugShowCheckedModeBanner:false,title:'Khan Footwear',
 theme:ThemeData(useMaterial3:true,colorSchemeSeed:Colors.black,scaffoldBackgroundColor:const Color(0xFFF6F4EF),fontFamily:'Arial'),home:const Store());
}

class Store extends StatefulWidget{const Store({super.key});@override State<Store> createState()=>_StoreState();}

class _StoreState extends State<Store>{
 final scroll=ScrollController(),search=TextEditingController();
 List<Product> products=[],cart=[]; String category='All',query='',token='',user='';
 bool loading=true,logged=false,searchOpen=false;
 static const cats=['All','Chelsea Boots','Sneakers','Formal Shoes','Casual Boots','Loafers','Running Shoes','Sandals','Slides','Hiking Boots','Driving Shoes'];

 @override void initState(){super.initState();load();}
 @override void dispose(){scroll.dispose();search.dispose();super.dispose();}
 List<Product> get shown=>products.where((p)=>(category=='All'||p.category==category)&&(query.isEmpty||p.name.toLowerCase().contains(query.toLowerCase())||p.category.toLowerCase().contains(query.toLowerCase()))).toList();

 Future<void> load()async{try{final r=await http.get(Uri.parse('/api/products'));if(r.statusCode==200)products=(jsonDecode(r.body) as List).map((x)=>Product.fromJson(x)).toList();}catch(_){}
 if(mounted)setState(()=>loading=false);}
 void add(Product p){if(p.stock<1)return;setState(()=>cart.add(p));ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(p.name+' added to bag')));}
 void cat(String c){setState(()=>category=c);Future.delayed(const Duration(milliseconds:80),()=>scroll.animateTo(690,duration:const Duration(milliseconds:500),curve:Curves.easeOut));}

 Future<void> login()async{
  final e=TextEditingController(),pw=TextEditingController();
  await showDialog(context:context,builder:(d)=>AlertDialog(title:const Text('Customer Login',style:TextStyle(fontWeight:FontWeight.w900)),
   content:SizedBox(width:390,child:Column(mainAxisSize:MainAxisSize.min,children:[TextField(controller:e,decoration:const InputDecoration(labelText:'Email')),TextField(controller:pw,obscureText:true,decoration:const InputDecoration(labelText:'Password'))])),
   actions:[TextButton(onPressed:(){Navigator.pop(d);register();},child:const Text('CREATE ACCOUNT')),FilledButton(onPressed:()async{
    final r=await http.post(Uri.parse('/api/auth/login'),headers:{'Content-Type':'application/json'},body:jsonEncode({'email':e.text,'password':pw.text}));
    if(r.statusCode==200){final j=jsonDecode(r.body);token=j['token'];user=j['user']['name'];logged=true;if(mounted){Navigator.pop(d);setState((){});}}
    else if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Invalid email or password')));
   },child:const Text('LOGIN'))]));
  e.dispose();pw.dispose();
 }

 Future<void> register()async{
  final n=TextEditingController(),e=TextEditingController(),ph=TextEditingController(),pw=TextEditingController();
  await showDialog(context:context,builder:(d)=>AlertDialog(title:const Text('Create Account',style:TextStyle(fontWeight:FontWeight.w900)),
   content:SizedBox(width:400,child:SingleChildScrollView(child:Column(children:[TextField(controller:n,decoration:const InputDecoration(labelText:'Full name')),TextField(controller:e,decoration:const InputDecoration(labelText:'Email')),TextField(controller:ph,decoration:const InputDecoration(labelText:'Phone / WhatsApp')),TextField(controller:pw,obscureText:true,decoration:const InputDecoration(labelText:'Password'))]))),
   actions:[TextButton(onPressed:()=>Navigator.pop(d),child:const Text('CANCEL')),FilledButton(onPressed:()async{
    final r=await http.post(Uri.parse('/api/auth/register'),headers:{'Content-Type':'application/json'},body:jsonEncode({'name':n.text,'email':e.text,'phone':ph.text,'password':pw.text}));
    if(r.statusCode==201&&mounted){Navigator.pop(d);login();}else if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(jsonDecode(r.body)['error']??'Registration failed')));
   },child:const Text('REGISTER'))]));
  n.dispose();e.dispose();ph.dispose();pw.dispose();
 }

 Future<void> checkout()async{
  if(!logged){login();return;}
  final n=TextEditingController(),ph=TextEditingController(),city=TextEditingController(),addr=TextEditingController();String method='cod';
  final total=cart.fold<double>(0,(s,p)=>s+p.price);
  await showDialog(context:context,builder:(d)=>StatefulBuilder(builder:(d,setD)=>AlertDialog(title:const Text('Secure Checkout',style:TextStyle(fontWeight:FontWeight.w900)),
   content:SizedBox(width:510,child:SingleChildScrollView(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    TextField(controller:n,decoration:const InputDecoration(labelText:'Full name')),TextField(controller:ph,decoration:const InputDecoration(labelText:'Phone / WhatsApp')),TextField(controller:city,decoration:const InputDecoration(labelText:'City')),TextField(controller:addr,decoration:const InputDecoration(labelText:'Complete delivery address')),
    const SizedBox(height:18),const Text('PAYMENT METHOD',style:TextStyle(fontWeight:FontWeight.bold)),
    RadioListTile(value:'cod',groupValue:method,onChanged:(v)=>setD(()=>method=v!),title:const Text('Cash on Delivery')),
    RadioListTile(value:'jazzcash',groupValue:method,onChanged:(v)=>setD(()=>method=v!),title:const Text('JazzCash'),subtitle:const Text('03420954886')),
    RadioListTile(value:'easypaisa',groupValue:method,onChanged:(v)=>setD(()=>method=v!),title:const Text('Easypaisa'),subtitle:const Text('03420954886')),
    const Divider(),Text('Order total: Rs. '+total.toStringAsFixed(0),style:const TextStyle(fontSize:19,fontWeight:FontWeight.w900))
   ]))),
   actions:[TextButton(onPressed:()=>Navigator.pop(d),child:const Text('CANCEL')),FilledButton(onPressed:()async{
    if(addr.text.trim().isEmpty)return;
    final r=await http.post(Uri.parse('/api/orders'),headers:{'Content-Type':'application/json','Authorization':'Bearer '+token},body:jsonEncode({'items':cart.map((p)=>{'product_id':p.id,'quantity':1,'unit_price':p.price}).toList(),'total':total,'payment_method':method,'shipping_address':n.text+', '+ph.text+', '+city.text+', '+addr.text}));
    if(r.statusCode==201&&mounted){final j=jsonDecode(r.body);Navigator.pop(d);setState(()=>cart.clear());showOrder(j,method);}else if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Could not create order')));
   },child:const Text('PLACE ORDER'))])));
  n.dispose();ph.dispose();city.dispose();addr.dispose();
 }

 void showOrder(Map<String,dynamic> o,String method)=>showDialog(context:context,builder:(d)=>AlertDialog(
  icon:const Icon(Icons.check_circle_outline,size:48),title:Text('Order #'+o['id'].toString()+' created',style:const TextStyle(fontWeight:FontWeight.w900)),
  content:Text(method=='cod'?'Your order is pending confirmation.':'Send payment to 03420954886 via '+(method=='jazzcash'?'JazzCash':'Easypaisa')+' and share the transaction reference on WhatsApp.'),
  actions:[if(method!='cod')FilledButton(onPressed:()=>launchUrl(Uri.parse('https://wa.me/923420954886')),child:const Text('WHATSAPP')),TextButton(onPressed:()=>Navigator.pop(d),child:const Text('DONE'))]));

 void bag(){
  showDialog(context:context,builder:(d){final total=cart.fold<double>(0,(s,p)=>s+p.price);return AlertDialog(title:Text('Shopping Bag ('+cart.length.toString()+')',style:const TextStyle(fontWeight:FontWeight.w900)),
   content:SizedBox(width:520,child:ConstrainedBox(constraints:const BoxConstraints(maxHeight:500),child:ListView(shrinkWrap:true,children:[
    for(final p in cart)ListTile(contentPadding:EdgeInsets.zero,leading:Image.network(p.image,width:55,height:55,fit:BoxFit.cover),title:Text(p.name),subtitle:Text(p.category),trailing:Text('Rs. '+p.price.toStringAsFixed(0))),
    const Divider(),Align(alignment:Alignment.centerRight,child:Text('TOTAL  Rs. '+total.toStringAsFixed(0),style:const TextStyle(fontSize:19,fontWeight:FontWeight.w900)))
   ]))),actions:[TextButton(onPressed:()=>Navigator.pop(d),child:const Text('CONTINUE')),FilledButton(onPressed:(){Navigator.pop(d);checkout();},child:const Text('CHECKOUT'))]);});
 }

 void details(Product p)=>showDialog(context:context,builder:(d)=>Dialog(child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:850,maxHeight:750),child:SingleChildScrollView(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
  Image.network(p.image,height:390,width:850,fit:BoxFit.cover),Padding(padding:const EdgeInsets.all(28),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
   Text(p.category.toUpperCase(),style:const TextStyle(color:Color(0xFF9A763C),fontWeight:FontWeight.bold,letterSpacing:2)),const SizedBox(height:8),Text(p.name,style:const TextStyle(fontSize:32,fontWeight:FontWeight.w900)),
   const SizedBox(height:10),Row(children:[Text('Rs. '+p.price.toStringAsFixed(0),style:const TextStyle(fontSize:25,fontWeight:FontWeight.w900)),const SizedBox(width:12),Text('Rs. '+p.oldPrice.toStringAsFixed(0),style:const TextStyle(color:Colors.grey,decoration:TextDecoration.lineThrough)),const SizedBox(width:12),Text(p.discount.toString()+'% OFF')]),
   const SizedBox(height:18),Text(p.description,style:const TextStyle(color:Colors.black54,height:1.6)),const SizedBox(height:15),Text('Stock: '+p.stock.toString(),style:const TextStyle(fontWeight:FontWeight.bold)),const SizedBox(height:20),
   SizedBox(width:double.infinity,child:FilledButton.icon(onPressed:p.stock<1?null:(){Navigator.pop(d);add(p);},icon:const Icon(Icons.shopping_bag_outlined),label:const Text('ADD TO BAG')))
  ]))
 ]))));

 Widget hero()=>SizedBox(height:590,child:Stack(fit:StackFit.expand,children:[
  Image.network('https://images.unsplash.com/photo-1495555961986-6d4c1ecb7be3?auto=format&fit=crop&w=1900&q=90',fit:BoxFit.cover),Container(color:Colors.black54),
  Positioned(left:MediaQuery.sizeOf(context).width*.07,bottom:60,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
   const Text('KHAN FOOTWEAR',style:TextStyle(color:Color(0xFFE0B96B),letterSpacing:4,fontWeight:FontWeight.bold)),const SizedBox(height:12),
   const Text('100+ STYLES.\\nONE WALK.',style:TextStyle(color:Colors.white,fontSize:62,height:.92,fontWeight:FontWeight.w900)),
   const SizedBox(height:16),const SizedBox(width:500,child:Text('Shop our complete PostgreSQL-powered catalogue: boots, sneakers, formal shoes, sandals, slides and more.',style:TextStyle(color:Colors.white70,fontSize:16,height:1.5))),const SizedBox(height:25),
   FilledButton(onPressed:()=>scroll.animateTo(680,duration:const Duration(milliseconds:600),curve:Curves.easeOut),style:FilledButton.styleFrom(backgroundColor:Colors.white,foregroundColor:Colors.black,padding:const EdgeInsets.symmetric(horizontal:30,vertical:18)),child:const Text('SHOP 100 PRODUCTS'))
  ]))
 ]));

 Widget card(Product p)=>Card(elevation:0,clipBehavior:Clip.antiAlias,color:Colors.white,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(12)),child:InkWell(onTap:()=>details(p),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
  Expanded(child:Stack(children:[Positioned.fill(child:Image.network(p.image,fit:BoxFit.cover,errorBuilder:(_,__,___)=>const Center(child:Icon(Icons.image_not_supported)))),Positioned(left:10,top:10,child:Container(color:Colors.black,padding:const EdgeInsets.symmetric(horizontal:8,vertical:5),child:Text(p.discount.toString()+'% OFF',style:const TextStyle(color:Colors.white,fontSize:10,fontWeight:FontWeight.bold)))),Positioned(right:6,top:6,child:IconButton.filledTonal(onPressed:()=>add(p),icon:const Icon(Icons.add_shopping_cart))) ])),
  Padding(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
   Text(p.category.toUpperCase(),style:const TextStyle(color:Colors.grey,fontSize:9,letterSpacing:1,fontWeight:FontWeight.bold)),const SizedBox(height:5),Text(p.name,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:16,fontWeight:FontWeight.w800)),const SizedBox(height:5),const Text('★★★★★',style:TextStyle(color:Color(0xFFB88939),fontSize:12)),const SizedBox(height:5),
   Row(children:[Text('Rs. '+p.price.toStringAsFixed(0),style:const TextStyle(fontSize:16,fontWeight:FontWeight.w900)),const SizedBox(width:7),Text('Rs. '+p.oldPrice.toStringAsFixed(0),style:const TextStyle(color:Colors.grey,fontSize:11,decoration:TextDecoration.lineThrough))]),const SizedBox(height:8),SizedBox(width:double.infinity,child:FilledButton(onPressed:p.stock<1?null:()=>add(p),child:const Text('ADD TO BAG')))
  ]))
 ])));

 Widget categoryBar()=>Container(color:Colors.white,padding:const EdgeInsets.symmetric(vertical:18),child:SingleChildScrollView(scrollDirection:Axis.horizontal,padding:const EdgeInsets.symmetric(horizontal:24),child:Row(children:[for(final c in cats)Padding(padding:const EdgeInsets.only(right:8),child:ChoiceChip(label:Text(c),selected:category==c,onSelected:(_)=>cat(c)))])));

 Widget catalogue()=>Padding(padding:const EdgeInsets.fromLTRB(24,55,24,70),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
  const Text('THE CATALOGUE',style:TextStyle(color:Color(0xFF9A763C),fontSize:11,fontWeight:FontWeight.bold,letterSpacing:3)),const SizedBox(height:8),Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[const Text('100+ footwear styles',style:TextStyle(fontSize:36,fontWeight:FontWeight.w900)),Text(shown.length.toString()+' products',style:const TextStyle(color:Colors.grey))]),const SizedBox(height:22),
  if(loading)const Center(child:Padding(padding:EdgeInsets.all(70),child:CircularProgressIndicator()))else LayoutBuilder(builder:(c,b){final n=b.maxWidth>=1400?4:b.maxWidth>=900?3:b.maxWidth>=600?2:1;return GridView.builder(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),itemCount:shown.length,gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:n,crossAxisSpacing:18,mainAxisSpacing:22,childAspectRatio:n==1?1.0:.68),itemBuilder:(_,i)=>card(shown[i]));})
 ]));

 Widget promo()=>Container(margin:const EdgeInsets.symmetric(horizontal:24),height:390,child:Row(children:[
  Expanded(child:Stack(fit:StackFit.expand,children:[Image.network('https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=1200&q=90',fit:BoxFit.cover),Container(color:Colors.black38),const Positioned(left:25,bottom:25,child:Text('SNEAKERS\\nEveryday motion',style:TextStyle(color:Colors.white,fontSize:28,fontWeight:FontWeight.w900)))])),
  const SizedBox(width:16),Expanded(child:Stack(fit:StackFit.expand,children:[Image.network('https://images.unsplash.com/photo-1638247025967-b4e38f787b76?auto=format&fit=crop&w=1200&q=90',fit:BoxFit.cover),Container(color:Colors.black38),const Positioned(left:25,bottom:25,child:Text('BOOTS\\nBuilt for every season',style:TextStyle(color:Colors.white,fontSize:28,fontWeight:FontWeight.w900)))]))
 ]));

 Widget footer()=>Container(color:const Color(0xFF111111),padding:const EdgeInsets.fromLTRB(30,55,30,30),child:Column(children:[const Text('KHAN FOOTWEAR',style:TextStyle(color:Colors.white,fontSize:25,fontWeight:FontWeight.w900,letterSpacing:4)),const SizedBox(height:12),const Text('100+ products • PostgreSQL • JWT • Orders • Payments',style:TextStyle(color:Colors.white54)),const SizedBox(height:35),const Divider(color:Colors.white24),const SizedBox(height:20),TextButton(onPressed:()=>launchUrl(Uri.parse('https://wa.me/923420954886')),child:const Text('WHATSAPP 03420954886',style:TextStyle(color:Colors.white)))]));

 @override Widget build(BuildContext c){
  final w=MediaQuery.sizeOf(c).width,desk=w>=950;
  return Scaffold(body:CustomScrollView(controller:scroll,slivers:[
   SliverToBoxAdapter(child:Container(height:34,color:Colors.black,alignment:Alignment.center,child:const Text('FREE SHIPPING OVER RS. 5,000   •   EASY EXCHANGE   •   WHATSAPP SUPPORT',style:TextStyle(color:Colors.white,fontSize:10,letterSpacing:.7,fontWeight:FontWeight.bold)))),
   SliverAppBar(pinned:true,backgroundColor:Colors.white,surfaceTintColor:Colors.white,toolbarHeight:74,title:const Text('KHAN',style:TextStyle(fontSize:26,fontWeight:FontWeight.w900,letterSpacing:5)),
    actions:desk?[TextButton(onPressed:()=>cat('Formal Shoes'),child:const Text('MEN')),TextButton(onPressed:()=>cat('Sneakers'),child:const Text('WOMEN')),TextButton(onPressed:()=>cat('Chelsea Boots'),child:const Text('BOOTS')),TextButton(onPressed:()=>cat('Running Shoes'),child:const Text('SNEAKERS')),IconButton(onPressed:()=>setState(()=>searchOpen=!searchOpen),icon:const Icon(Icons.search)),IconButton(onPressed:login,icon:Icon(logged?Icons.person:Icons.person_outline)),IconButton(onPressed:bag,icon:Badge(label:Text(cart.length.toString()),isLabelVisible:cart.isNotEmpty,child:const Icon(Icons.shopping_bag_outlined))),const SizedBox(width:15)]:[IconButton(onPressed:()=>setState(()=>searchOpen=!searchOpen),icon:const Icon(Icons.search)),IconButton(onPressed:bag,icon:Badge(label:Text(cart.length.toString()),isLabelVisible:cart.isNotEmpty,child:const Icon(Icons.shopping_bag_outlined))) ]),
   if(searchOpen)SliverToBoxAdapter(child:Container(color:Colors.white,padding:const EdgeInsets.fromLTRB(24,8,24,18),child:TextField(controller:search,autofocus:true,onChanged:(v)=>setState(()=>query=v),decoration:InputDecoration(prefixIcon:const Icon(Icons.search),hintText:'Search 100+ products...',filled:true,fillColor:const Color(0xFFF1F0EC),border:OutlineInputBorder(borderRadius:BorderRadius.circular(12),borderSide:BorderSide.none))))),
   SliverToBoxAdapter(child:hero()),SliverToBoxAdapter(child:categoryBar()),SliverToBoxAdapter(child:catalogue()),SliverToBoxAdapter(child:promo()),
   SliverToBoxAdapter(child:Padding(padding:const EdgeInsets.symmetric(vertical:70,horizontal:25),child:Column(children:[const Text('REAL COMMERCE FLOW',style:TextStyle(color:Color(0xFF9A763C),fontWeight:FontWeight.bold,letterSpacing:3)),const SizedBox(height:12),const Text('Accounts → Cart → Orders → Payments',textAlign:TextAlign.center,style:TextStyle(fontSize:34,fontWeight:FontWeight.w900)),const SizedBox(height:12),const Text('Register and login with JWT, checkout creates PostgreSQL orders and order_items in a transaction, and JazzCash/Easypaisa payments create payment transaction records.',textAlign:TextAlign.center,style:TextStyle(color:Colors.grey,fontSize:15,height:1.6))]))),
   SliverToBoxAdapter(child:footer())
  ]));
 }
}


class _PaymentsTab extends StatefulWidget {
  final String token;
  const _PaymentsTab({required this.token});

  @override
  State<_PaymentsTab> createState() => _PaymentsTabState();
}

class _PaymentsTabState extends State<_PaymentsTab> {
  bool loading = true;
  List<dynamic> payments = [];

  @override
  void initState() {
    super.initState();
    loadPayments();
  }

  Future<void> loadPayments() async {
    if (widget.token.isEmpty) {
      setState(() => loading = false);
      return;
    }
    try {
      final response = await http.get(
        Uri.parse('/api/payments/history'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      if (response.statusCode == 200) {
        payments = jsonDecode(response.body) as List;
      }
    } catch (_) {}
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (payments.isEmpty) {
      return const Center(child: Text('No payment transactions yet.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(22),
      itemCount: payments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, index) {
        final payment = Map<String, dynamic>.from(payments[index]);
        return Card(
          elevation: 0,
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.payments_outlined)),
            title: Text(
              '${payment['method']} • Order #${payment['order_id']}',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            subtitle: Text(
              '${payment['status']}'
              '${payment['transaction_reference'] == null ? '' : ' • Ref: ${payment['transaction_reference']}'}',
            ),
            trailing: Text(
              'Rs. ${payment['amount']}',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        );
      },
    );
  }
}
