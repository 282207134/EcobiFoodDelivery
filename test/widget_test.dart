import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecobi/app.dart';
import 'package:ecobi/data/app_state.dart';

void main() {
  test('Cart arithmetic, voucher and persisted order lifecycle', () async {
    SharedPreferences.setMockInitialValues({});
    final s = await AppState.load();
    expect(s.subtotal, 188);
    s.add('salmon');
    s.voucher = 'Salmon Fillet';
    expect(s.subtotal, 247);
    expect(s.total, closeTo(197.6, .001));
    s.placeOrder();
    await s.save();
    expect(s.cart, isEmpty);
    expect(s.orders, hasLength(1));
    final restored = await AppState.load();
    expect(restored.orders.single['total'], closeTo(197.6, .001));
    restored.reorder(restored.orders.single);
    expect(restored.subtotal, 247);
    restored.decrease('avocado');
    expect(restored.cart['avocado'], 1);
    restored.remove('avocado');
    expect(restored.cart.containsKey('avocado'), isFalse);
  });
  testWidgets('Auth rejects bad phone and moves valid phone to OTP', (
    tester,
  ) async {
    tester.view.resetPhysicalSize();
    tester.view.physicalSize = const Size(1125, 2436);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      EcobiApp(state: AppState(), initialRoute: 'signup-phone'),
    );
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid phone number.'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), '969266825');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Verification code OTP'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('All design routes render at phone and compact sizes', (
    tester,
  ) async {
    for (final size in [const Size(375, 812), const Size(320, 690)]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      for (final route in pages.keys.where((r) => r != 'gallery')) {
        await tester.pumpWidget(const SizedBox());
        await tester.pump();
        await tester.pumpWidget(
          EcobiApp(state: AppState(), initialRoute: route),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$route at $size');
      }
    }
    await tester.pumpWidget(const SizedBox());
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  testWidgets('Product to cart to checkout creates order and clears cart', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1125, 2436);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final state = AppState();
    state.cart.clear();
    await tester.pumpWidget(EcobiApp(state: state, initialRoute: 'product'));
    await tester.tap(find.text('Add to Cart'));
    await tester.pumpAndSettle();
    expect(state.cart['salmon'], 1);
    await tester.tap(find.text('Check Out'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Place Order'));
    await tester.pumpAndSettle();
    expect(find.text('Payment Success!'), findsOneWidget);
    expect(state.orders, hasLength(1));
    expect(state.cart, isEmpty);
  });
  testWidgets('Swipe delete confirms and search handles empty results', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1125, 2436);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final state = AppState();
    await tester.pumpWidget(EcobiApp(state: state, initialRoute: 'cart'));
    await tester.drag(find.byType(Dismissible).first, const Offset(-400, 0));
    await tester.pumpAndSettle();
    expect(find.text('Delete Selection?'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(state.cart.containsKey('avocado'), isFalse);
    navigatorKey.currentState!.pushNamed('/search');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'not-in-catalog');
    await tester.pumpAndSettle();
    expect(find.text('No products found'), findsOneWidget);
  });
}
