import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Product {
  final String id, name, category, brand;
  final int price, oldPrice;
  const Product(
    this.id,
    this.name,
    this.category,
    this.price,
    this.oldPrice, {
    this.brand = 'Picovina Food',
  });
}

const products = [
  Product('beef', 'Beef Ribs', 'Meat', 79, 99),
  Product('salmon', 'Salmon Fillet', 'Seafood', 59, 89),
  Product('corn', 'Dalat Corn', 'Vegetable', 29, 39, brand: 'Pieco Farm'),
  Product('avocado', 'Avocado', 'Fruit', 40, 45),
  Product('coffee', 'Cafe Arabica', 'Drinks', 25, 35),
  Product('milk', 'Fresh Milk', 'Drinks', 12, 18),
  Product('carrot', 'Carrot Ecobi', 'Vegetable', 2, 3),
];
Product productById(String id) =>
    products.firstWhere((p) => p.id == id, orElse: () => products[1]);
String money(num amount) =>
    '\$${amount % 1 == 0 ? amount.toInt() : amount.toStringAsFixed(2)}';

class AppState extends ChangeNotifier {
  SharedPreferences? _prefs;
  Map<String, int> cart = {'avocado': 2, 'corn': 1, 'beef': 1};
  Set<String> favorites = {};
  Set<int> savedStores = {0, 1, 2, 3, 4};
  List<Map<String, dynamic>> orders = [];
  List<String> cards = ['3042'];
  String name = 'Peter Evans',
      email = 'peter@pitstudio.co',
      phone = '123 456 78';
  String address = 'Home', payment = 'Mastercard', voucher = '';
  String selectedProduct = 'salmon';
  bool onboarded = false, signedIn = false;
  String city = 'New York';
  bool promoOnly = false, showFees = false, accessible = false;
  RangeValues prices = const RangeValues(0, 999);
  int get subtotal =>
      cart.entries.fold(0, (s, e) => s + productById(e.key).price * e.value);
  double get discount =>
      voucher.isEmpty ? 0 : subtotal * (voucher == 'Cafe Ara' ? .15 : .2);
  double get total => subtotal - discount;
  int get count => cart.values.fold(0, (a, b) => a + b);
  Product get product => productById(selectedProduct);

  static Future<AppState> load() async {
    final state = AppState();
    state._prefs = await SharedPreferences.getInstance();
    final raw = state._prefs!.getString('ecobi_state');
    if (raw != null) {
      try {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        state.cart = Map<String, int>.from(data['cart']);
        state.favorites = Set<String>.from(data['favorites']);
        state.savedStores = Set<int>.from(data['savedStores']);
        state.orders = List<Map<String, dynamic>>.from(
          (data['orders'] as List).map((e) => Map<String, dynamic>.from(e)),
        );
        state.cards = List<String>.from(data['cards']);
        state.name = data['name'];
        state.email = data['email'];
        state.phone = data['phone'];
        state.onboarded = data['onboarded'];
        state.signedIn = data['signedIn'];
      } catch (_) {
        /* Invalid local cache falls back to the demo seed. */
      }
    }
    return state;
  }

  Future<void> save() async {
    notifyListeners();
    await _prefs?.setString(
      'ecobi_state',
      jsonEncode({
        'cart': cart,
        'favorites': favorites.toList(),
        'savedStores': savedStores.toList(),
        'orders': orders,
        'cards': cards,
        'name': name,
        'email': email,
        'phone': phone,
        'onboarded': onboarded,
        'signedIn': signedIn,
      }),
    );
  }

  void add(String id) {
    cart[id] = (cart[id] ?? 0) + 1;
    save();
  }

  void decrease(String id) {
    if ((cart[id] ?? 0) > 1) {
      cart[id] = cart[id]! - 1;
      save();
    }
  }

  void remove(String id) {
    cart.remove(id);
    save();
  }

  void toggleFavorite(String id) {
    favorites.contains(id) ? favorites.remove(id) : favorites.add(id);
    save();
  }

  void toggleStore(int id) {
    savedStores.contains(id) ? savedStores.remove(id) : savedStores.add(id);
    save();
  }

  void update() => notifyListeners();
  void placeOrder() {
    if (cart.isEmpty) return;
    orders.insert(0, {
      'id':
          'ECO${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      'items': Map<String, int>.from(cart),
      'total': total,
      'received': false,
    });
    cart.clear();
    voucher = '';
    save();
  }

  void reorder(Map<String, dynamic> order) {
    for (final e in (order['items'] as Map).entries) {
      cart[e.key] = (cart[e.key] ?? 0) + (e.value as int);
    }
    save();
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
    : super(notifier: state);
  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
