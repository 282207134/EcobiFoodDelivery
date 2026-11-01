import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'data/app_state.dart';
import 'features/auth.dart';
import 'features/catalog.dart';
import 'features/checkout.dart';
import 'features/profile.dart';
import 'features/vouchers.dart';
import 'widgets/common.dart';

final navigatorKey = GlobalKey<NavigatorState>();
final Map<String, WidgetBuilder> pages = {
  'splash-light': (_) => const SplashPage(),
  'splash-green': (_) => const SplashPage(greenBackground: true),
  'onboarding-1': (_) => const OnboardingPage(0),
  'onboarding-2': (_) => const OnboardingPage(1),
  'onboarding-3': (_) => const OnboardingPage(2),
  'welcome': (_) => const WelcomePage(),
  'signup-welcome': (_) => const AuthPage('signup-welcome'),
  'signup-phone': (_) => const AuthPage('signup-phone'),
  'verify': (_) => const AuthPage('verify'),
  'email': (_) => const AuthPage('email'),
  'email-typing': (_) => const AuthPage('email', focus: true),
  'create-password': (_) => const AuthPage('create-password'),
  'login-phone': (_) => const AuthPage('login-phone'),
  'login-password': (_) => const AuthPage('login-password'),
  'login-password-focus': (_) => const AuthPage('login-password', focus: true),
  'home': (_) => const HomePage(),
  'product': (_) => const ProductPage(),
  'reviews': (_) => const ProductPage(reviews: true),
  'cart': (_) => const CartPage(),
  'cart-delete': (_) => const CartPage(deletePreview: true),
  'cart-dialog': (_) => const CartPage(dialogPreview: true),
  'empty-cart': (_) => const CartPage(empty: true),
  'checkout': (_) => const CheckoutPage(),
  'addresses': (_) => const SelectionPage('addresses'),
  'promotions': (_) => const SelectionPage('promotions'),
  'payment-select': (_) => const SelectionPage('payment'),
  'success': (_) => const SuccessPage(),
  'tracking': (_) => const TrackingPage(),
  'vouchers': (_) => const VouchersPage(),
  'voucher-detail': (_) => const VoucherDetailPage(),
  'search': (_) => const SearchPage(),
  'results': (_) => const SearchPage(results: true),
  'filter': (_) => const FilterPage(),
  'filtered': (_) => const SearchPage(results: true, filtered: true),
  'scan-permission': (_) => const ScanPage(permission: true),
  'scan': (_) => const ScanPage(),
  'scan-carrot': (_) => const ScanPage(carrot: true),
  'profile': (_) => const ProfilePage(),
  'personal-info': (_) => const PersonalInfoPage(),
  'personal-info-edit': (_) => const PersonalInfoPage(focus: true),
  'orders': (_) => const OrdersPage(),
  'saved': (_) => const SavedPage(),
  'saved-menu': (_) => const SavedPage(menu: true),
  'payment': (_) => const PaymentPage(),
  'add-card': (_) => const AddCardPage(),
  'add-card-edit': (_) => const AddCardPage(focus: true),
  'empty-card': (_) => const PaymentPage(empty: true),
  'referral': (_) => const ReferralPage(),
  'about': (_) => const AboutPage(),
  'gallery': (_) => const GalleryPage(),
};

class EcobiApp extends StatelessWidget {
  final AppState state;
  final String? initialRoute;
  const EcobiApp({super.key, required this.state, this.initialRoute});
  @override
  Widget build(BuildContext context) {
    const start = String.fromEnvironment('INITIAL_ROUTE');
    final route =
        initialRoute ??
        (start.isNotEmpty
            ? start
            : state.signedIn
            ? 'home'
            : state.onboarded
            ? 'welcome'
            : 'onboarding-1');
    return AppScope(
      state: state,
      child: MaterialApp(
        title: 'Ecobi',
        debugShowCheckedModeBanner: false,
        theme: ecobiTheme(),
        navigatorKey: navigatorKey,
        initialRoute: '/$route',
        onGenerateInitialRoutes: (name) => [
          MaterialPageRoute<void>(
            settings: RouteSettings(name: name),
            builder: pages[name.substring(1)] ?? pages['home']!,
          ),
        ],
        onGenerateRoute: (settings) => MaterialPageRoute<void>(
          settings: settings,
          builder:
              pages[settings.name?.replaceFirst('/', '')] ?? pages['home']!,
        ),
        builder: (context, child) => Container(
          color: const Color(0xFFEFF3EF),
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: child!,
          ),
        ),
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  @override
  Widget build(BuildContext context) => PageLayout(
    title: 'About Ecobi',
    child: Column(
      children: [
        art('logo', width: 180),
        const SizedBox(height: 32),
        heading('Fresh food. A little greener.'),
        const SizedBox(height: 16),
        const Text(
          'Ecobi grocery delivery\nFlutter UI demonstration\n\nDesign: Ecobi — Pit Studio\nReference: Pixso\nVersion 1.0.0',
          textAlign: TextAlign.center,
          style: TextStyle(color: muted, height: 1.8),
        ),
        const SizedBox(height: 32),
        PrimaryButton(
          'Browse all screens',
          onPressed: () => go(context, 'gallery'),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () {
            final s = AppScope.of(context);
            s.signedIn = false;
            s.save();
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/welcome',
              (_) => false,
            );
          },
          child: const Text('Sign out'),
        ),
      ],
    ),
  );
}

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});
  @override
  Widget build(BuildContext context) => PageLayout(
    title: 'Screen Gallery',
    child: Column(
      children: [
        caption('Review every page and design state.'),
        const SizedBox(height: 16),
        for (final route in pages.keys.where((r) => r != 'gallery'))
          ListTile(
            title: Text(route),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => go(context, route),
          ),
      ],
    ),
  );
}
