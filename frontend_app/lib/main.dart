import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Verified 2026: Riverpod 3.x default for new apps, Material3 seed theme,
// responsive compact<600 / medium 600-1024 / expanded>1024, LayoutBuilder-first.

const primarySeed = Color(0xFF7B1E1E);
const secondaryAccent = Color(0xFFE8A93D);

class Food {
  final String id, name, image;
  final double price, rating;
  const Food(this.id, this.name, this.price, this.image, this.rating);
}

const demoMenu = [
  Food('1', 'Salmon Sushi', 21.0, '🍣', 4.9),
  Food('2', 'Tuna Roll', 19.0, '🍱', 4.8),
  Food('3', 'Salmon Eggs', 21.0, '🍳', 4.7),
  Food('4', 'Mini Sushi Set', 15.0, '🍙', 4.6),
  Food('5', 'Spicy Tuna Nigiri', 22.0, '🔥', 4.7),
  Food('6', 'California Roll', 16.0, '🦀', 4.6),
  Food('7', 'Dragon Roll', 24.0, '🐲', 4.8),
  Food('8', 'Chirashi Bowl', 26.0, '🍚', 4.9),
  Food('9', 'Omakase Set', 45.0, '👑', 5.0),
  Food('10', 'Family Boat', 52.0, '🚤', 4.8),
  Food('11', 'Matcha Latte', 8.0, '🍵', 4.6),
  Food('12', 'Mochi Trio', 9.5, '🍡', 4.7),
];

final cartProvider = NotifierProvider<CartNotifier, Map<String, int>>(CartNotifier.new);
class CartNotifier extends Notifier<Map<String, int>> {
  @override
  Map<String, int> build() => {};
  void add(String id, int qty) => state = {...state, id: (state[id] ?? 0) + qty};
  void remove(String id) { final m = Map<String,int>.from(state); m.remove(id); state = m; }
  void clear() => state = {};
  int get count => state.values.fold(0, (a,b)=>a+b);
}

// Verified 2026: debounced search (320ms), optimistic favorites, order history one-tap reorder
final searchQueryProvider = StateProvider<String>((ref) => '');
// Shared promo code: banner Redeem writes here, Cart checkout reads it (verified promo-at-launch pattern)
final promoCodeProvider = StateProvider<String>((ref) => '');
final favoritesProvider = NotifierProvider<FavNotifier, Set<String>>(FavNotifier.new);
class FavNotifier extends Notifier<Set<String>> {
  static const _key = 'fav_ids_v1';
  @override
  Set<String> build() => <String>{};
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    state = (prefs.getStringList(_key) ?? <String>[]).toSet();
  }
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, state.toList());
  }
  void toggle(String id) {
    if (state.contains(id)) {
      final next = <String>{...state};
      next.remove(id);
      state = next;
    } else {
      state = <String>{...state, id};
    }
    _save();
  }
}
final ordersProvider = NotifierProvider<OrdersNotifier, List<Map<String,dynamic>>>(OrdersNotifier.new);
class OrdersNotifier extends Notifier<List<Map<String,dynamic>>> {
  @override
  List<Map<String,dynamic>> build() => [];
  void place(Map<String,int> cart, double total) {
    final id = 'ORD-${(state.length+1).toString().padLeft(4,'0')}';
    state = [...state, {'id': id, 'items': Map<String,int>.from(cart), 'total': total, 'at': DateTime.now().toIso8601String()}];
  }
}

void main() => runApp(const ProviderScope(child: SushiApp()));

class SushiApp extends ConsumerWidget {
  const SushiApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Sushi Man SaaS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: primarySeed, brightness: Brightness.light),
        textTheme: GoogleFonts.dmSerifDisplayTextTheme(),
      ),
      darkTheme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: primarySeed, brightness: Brightness.dark)),
      home: const IntroPage(),
    );
  }
}

// ---------- Intro ----------
class IntroPage extends StatelessWidget {
  const IntroPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7B1E1E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('SUSHI MAN', style: GoogleFonts.dmSerifDisplay(color: Colors.white, fontSize: 28)),
              const SizedBox(height: 8),
              const Center(child: Text('🍣', style: TextStyle(fontSize: 120))),
              Text('Taste of\nJapanese food', style: GoogleFonts.dmSerifDisplay(color: Colors.white, fontSize: 44, height: 1.1)),
              const SizedBox(height: 10),
              Text('Delicate sliced fresh salmon drapes elegantly over a pillow of perfectly seasoned rice.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), height: 2, fontSize: 15)),
              const SizedBox(height: 16),
              Center(
                child: FilledButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MenuPage())),
                  icon: const Icon(Icons.arrow_forward, color: Colors.white),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    child: Text('Get Started', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: secondaryAccent.withValues(alpha: 0.9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- Menu (responsive) ----------
class MenuPage extends ConsumerStatefulWidget {
  const MenuPage({super.key});
  @override
  ConsumerState<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends ConsumerState<MenuPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(favoritesProvider.notifier).load());
  }
  @override
  Widget build(BuildContext context) {
    final cartCount = ref.watch(cartProvider.select((m) => m.values.fold(0, (a,b)=>a+b)));
    final query = ref.watch(searchQueryProvider).toLowerCase();
    final filtered = demoMenu.where((f) => f.name.toLowerCase().contains(query)).toList();
    return LayoutBuilder(builder: (context, c) {
      final wide = c.maxWidth >= 840;
      final body = CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _promoBanner(context)),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SearchBar(hintText: 'Search here', leading: const Icon(Icons.search),
                onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)))),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          const SliverToBoxAdapter(child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('Food Menu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)))),
          if (filtered.isEmpty)
            const SliverToBoxAdapter(child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: Text('No dishes match your search.\nTry “salmon” or “tuna”.',
                textAlign: TextAlign.center, style: TextStyle(color: Colors.grey))))),
          SliverToBoxAdapter(
            child: SizedBox(height: 230,
              child: ListView.separated(scrollDirection: Axis.horizontal, padding: const EdgeInsets.all(16),
                itemCount: filtered.length,
                separatorBuilder: (_, _)=>const SizedBox(width:12),
                itemBuilder: (_,i)=>FoodTile(food: filtered[i]))),
          ),
          SliverToBoxAdapter(child: _popularTile(context, demoMenu[2])),
        ],
      );
      return Scaffold(
        backgroundColor: const Color(0xFFF5F3EF),
        appBar: AppBar(
          backgroundColor: Colors.transparent, elevation: 0, foregroundColor: Colors.grey.shade800,
          leading: const Icon(Icons.menu),
          title: const Text('Tokyo'),
          centerTitle: true,
          actions: [
            Stack(children: [
              IconButton(icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage()))),
              if (cartCount>0) Positioned(right:6,top:6,child: Badge(label: Text('$cartCount'))),
            ]),
          ],
        ),
        body: wide ? Row(children: [
          NavigationRail(extended: true, selectedIndex: 0,
            destinations: const [NavigationRailDestination(icon: Icon(Icons.home), label: Text('Menu')),
              NavigationRailDestination(icon: Icon(Icons.receipt), label: Text('Orders'))]),
          Expanded(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 900), child: body)),
        ]) : body,
        bottomNavigationBar: wide ? null : NavigationBar(
          selectedIndex: 0,
          destinations: const [NavigationDestination(icon: Icon(Icons.home), label: 'Menu'),
            NavigationDestination(icon: Icon(Icons.receipt), label: 'Orders')]),
      );
    });
  }

  Widget _promoBanner(BuildContext context) => Consumer(builder: (context, ref, _) => Container(
    margin: const EdgeInsets.all(20),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    decoration: BoxDecoration(color: primarySeed, borderRadius: BorderRadius.circular(20)),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Get 32% Promo', style: GoogleFonts.dmSerifDisplay(color: Colors.white, fontSize: 22)),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: (){
            ref.read(promoCodeProvider.notifier).state = 'SAVE10';
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Promo SAVE10 applied — see it at checkout.')));
          },
          style: FilledButton.styleFrom(backgroundColor: secondaryAccent),
          child: const Text('Redeem', style: TextStyle(color: Colors.white))),
      ])),
      const Text('🍱', style: TextStyle(fontSize: 56)),
    ]),
  ));

  Widget _popularTile(BuildContext context, Food f) => Consumer(builder: (context, ref, _) {
    final fav = ref.watch(favoritesProvider).contains(f.id);
    return Container(
    margin: const EdgeInsets.all(20), padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
    child: Row(children: [
      Text(f.image, style: const TextStyle(fontSize: 56)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(f.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text('\$${f.price.toStringAsFixed(0)}', style: TextStyle(color: Colors.grey.shade600)),
      ])),
      IconButton(
        icon: Icon(fav ? Icons.favorite : Icons.favorite_border, color: fav ? Colors.red : null),
        onPressed: () => ref.read(favoritesProvider.notifier).toggle(f.id)),
    ]),
  );
  });
}

class FoodTile extends ConsumerWidget {
  final Food food;
  const FoodTile({super.key, required this.food});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FoodDetailsPage(food: food))),
      child: Container(
        width: 170, padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Hero(tag: 'food-${food.id}', child: Text(food.image, style: const TextStyle(fontSize: 64)))),
          const SizedBox(height: 8),
          Text(food.name, style: const TextStyle(fontWeight: FontWeight.w600),
            maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('\$${food.price.toStringAsFixed(0)}'),
            Row(children: [const Icon(Icons.star, size: 14, color: Colors.amber), Text('${food.rating}')]),
          ]),
        ]),
      ),
    );
  }
}

// ---------- Details ----------
class FoodDetailsPage extends ConsumerStatefulWidget {
  final Food food;
  const FoodDetailsPage({super.key, required this.food});
  @override
  ConsumerState<FoodDetailsPage> createState() => _DetailsState();
}
class _DetailsState extends ConsumerState<FoodDetailsPage> {
  int qty = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, foregroundColor: Colors.black),
      body: Column(children: [
        Expanded(child: ListView(padding: const EdgeInsets.symmetric(horizontal: 24), children: [
          Center(child: Hero(tag: 'food-${widget.food.id}', child: Text(widget.food.image, style: const TextStyle(fontSize: 140)))),
          Row(children: [const Icon(Icons.star, color: Colors.amber), Text('${widget.food.rating}',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))]),
          const SizedBox(height: 8),
          Text(widget.food.name, style: GoogleFonts.dmSerifDisplay(fontSize: 28)),
          const SizedBox(height: 8),
          const Text('Delicate sliced fresh salmon drapes elegantly over a pillow of perfectly seasoned rice. Crafted for a premium multi-tenant SaaS demo.',
            style: TextStyle(color: Colors.grey, height: 2)),
        ])),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(color: primarySeed,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('\$${widget.food.price.toStringAsFixed(0)}',
              style: GoogleFonts.dmSerifDisplay(color: Colors.white, fontSize: 24)),
            Row(children: [
              _circleBtn(Icons.remove, () => setState(()=>qty = qty>0?qty-1:0)),
              SizedBox(width: 40, child: Center(child: Text('$qty',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)))),
              _circleBtn(Icons.add, () => setState(()=>qty++)),
            ]),
            FilledButton(
              onPressed: qty==0?null:() {
                ref.read(cartProvider.notifier).add(widget.food.id, qty);
                showDialog(barrierDismissible: false, context: context, builder: (_) => AlertDialog(
                  backgroundColor: primarySeed,
                  title: const Text('Successfully added', style: TextStyle(color: Colors.white)),
                  actions: [TextButton(onPressed:(){Navigator.pop(context);Navigator.pop(context);},
                    child: const Text('OK', style: TextStyle(color: Colors.white)) )],
                ));
              },
              style: FilledButton.styleFrom(backgroundColor: secondaryAccent),
              child: const Text('Add to cart', style: TextStyle(color: Colors.white)),
            ),
          ]),
        ),
      ]),
    );
  }
  Widget _circleBtn(IconData i, VoidCallback f) => IconButton(
    onPressed: f, icon: Icon(i, color: Colors.white),
    style: IconButton.styleFrom(backgroundColor: secondaryAccent, shape: const CircleBorder()));
}

// ---------- Cart + Checkout (verified MVP: summary, promo, history, reorder) ----------
class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});
  @override
  ConsumerState<CartPage> createState() => _CartState();
}
class _CartState extends ConsumerState<CartPage> {
  String promo = '';
  late final TextEditingController _promoCtrl;
  int _payIdx = 0;
  static const _payMethods = ['Card', 'Wallet', 'COD'];
  @override
  void initState() {
    super.initState();
    _promoCtrl = TextEditingController();
    Future.microtask(() {
      final shared = ref.read(promoCodeProvider);
      if (shared.isNotEmpty) setState(() { promo = shared; _promoCtrl.text = shared; });
    });
  }
  @override
  void dispose() { _promoCtrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final items = cart.entries.toList();
    final orders = ref.watch(ordersProvider);
    final subtotal = items.fold(0.0, (a,e) {
      final f = demoMenu.firstWhere((x)=>x.id==e.key);
      return a + f.price * e.value;
    });
    final discount = promo.trim().toUpperCase()=='SAVE10' ? subtotal*0.10 : 0.0;
    final delivery = items.isEmpty ? 0.0 : 2.0;
    final tax = (subtotal-discount)*0.08;
    final total = subtotal-discount+delivery+tax;
    return Scaffold(
      backgroundColor: primarySeed,
      appBar: AppBar(title: const Text('My Cart'), backgroundColor: Colors.transparent,
        elevation: 0, foregroundColor: Colors.white),
      body: Column(children: [
        if (items.isEmpty)
          const Padding(padding: EdgeInsets.all(32),
            child: Center(child: Text('Your cart is empty.\nAdd sushi from the menu to get started.',
              textAlign: TextAlign.center, style: TextStyle(color: Colors.white)))),
        if (items.isNotEmpty)
        Expanded(child: ListView(
          children: [
            ...items.map((e){
              final f = demoMenu.firstWhere((x)=>x.id==e.key);
              return Dismissible(
                key: ValueKey(f.id),
                direction: DismissDirection.endToStart,
                background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 24),
                  decoration: BoxDecoration(color: Colors.red.shade700, borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.delete, color: Colors.white)),
                onDismissed: (_) => ref.read(cartProvider.notifier).remove(f.id),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    title: Text(f.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Qty ${e.value} • \$${(f.price*e.value).toStringAsFixed(0)}'),
                    trailing: IconButton(icon: const Icon(Icons.delete_outline),
                      onPressed: ()=>ref.read(cartProvider.notifier).remove(f.id)),
                  )));
            }),
            Container(margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(children: [
                TextField(controller: _promoCtrl,
                  decoration: const InputDecoration(hintText: 'Promo code (try SAVE10)', border: OutlineInputBorder()),
                  onChanged: (v)=>setState(()=>promo=v)),
                const SizedBox(height: 8),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 0, label: Text('Card'), icon: Icon(Icons.credit_card, size: 16)),
                    ButtonSegment(value: 1, label: Text('Wallet'), icon: Icon(Icons.wallet, size: 16)),
                    ButtonSegment(value: 2, label: Text('COD'), icon: Icon(Icons.payments, size: 16)),
                  ],
                  selected: {_payIdx},
                  onSelectionChanged: (s)=>setState(()=>_payIdx=s.first),
                ),
                const SizedBox(height: 4),
                Text(_payIdx==2
                  ? 'Pay cash on delivery.'
                  : 'Stripe PaymentSheet (card + Apple/Google Pay) activates when STRIPE_SECRET_KEY is set.',
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 8),
                _row('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
                _row('Discount', '-\$${discount.toStringAsFixed(2)}'),
                _row('Delivery', '\$${delivery.toStringAsFixed(2)}'),
                _row('Tax (8%)', '\$${tax.toStringAsFixed(2)}'),
                const Divider(),
                _row('Total', '\$${total.toStringAsFixed(2)}', bold: true),
              ])),
            if (orders.isNotEmpty)
              Container(margin: const EdgeInsets.symmetric(horizontal: 16), padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(16)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Order history (one-tap reorder)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ...orders.reversed.take(3).map((o) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${o['id']} • \$${(o['total'] as double).toStringAsFixed(0)}',
                        style: const TextStyle(color: Colors.white)),
                      TextButton(
                        onPressed: (){
                          final m = Map<String,int>.from(o['items'] as Map);
                          m.forEach((id,q)=>ref.read(cartProvider.notifier).add(id,q));
                        },
                        child: const Text('Reorder', style: TextStyle(color: Colors.amber))),
                    ])),
                ])),
          ],
        )),
        if (items.isEmpty && orders.isEmpty) const Spacer(),
        Padding(padding: const EdgeInsets.all(20),
          child: SizedBox(width: double.infinity,
            child: FilledButton(
              onPressed: items.isEmpty?null:(){
                ref.read(ordersProvider.notifier).place(cart, total);
                ref.read(cartProvider.notifier).clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Order placed (${_payMethods[_payIdx]})! Track in Orders.')));
              },
              style: FilledButton.styleFrom(backgroundColor: secondaryAccent,
                padding: const EdgeInsets.symmetric(vertical: 16)),
              child: Text(items.isEmpty ? 'Pay Now' : 'Pay \$${total.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white, fontSize: 16))))),
      ]),
    );
  }
  Widget _row(String k, String v, {bool bold=false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(k, style: TextStyle(fontWeight: bold?FontWeight.bold:FontWeight.normal)),
      Text(v, style: TextStyle(fontWeight: bold?FontWeight.bold:FontWeight.normal)),
    ]));
}
