import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/app_state.dart';
import '../widgets/common.dart';

class SplashPage extends StatelessWidget {
  final bool greenBackground;
  const SplashPage({super.key, this.greenBackground = false});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: greenBackground ? green : Colors.white,
    body: Center(
      child: GestureDetector(
        onTap: () => Navigator.pushReplacementNamed(context, '/onboarding-1'),
        child: art(
          greenBackground ? 'splash_green' : 'splash_light',
          width: 105,
          height: 140,
        ),
      ),
    ),
  );
}

class OnboardingPage extends StatelessWidget {
  final int index;
  const OnboardingPage(this.index, {super.key});
  @override
  Widget build(BuildContext context) {
    const titles = [
      'Get quality groceries\npicked with care',
      'Shop from\nyour favorites stores',
      'Shop more deals,\nsave more with us',
    ];
    const subtitles = [
      'Shoppers pick the highest quality items.\nThat’s our 100% quality promise',
      'Your favorites are on Instacart along with\n300 more across North America',
      'Save with exclusive deals, coupons\nand more with no membership required!',
    ];
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, size) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: size.maxHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    SizedBox(height: size.maxHeight * .12),
                    art(
                      'onboarding${index + 1}',
                      width: 311,
                      height: size.maxHeight * .35,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                        (i) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == index ? 24 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: i == index ? green : const Color(0xFFBDBDBD),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: size.maxHeight * .07),
                    heading(titles[index], size: 24),
                    const SizedBox(height: 16),
                    Text(
                      subtitles[index],
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: muted, height: 1.5),
                    ),
                    const SizedBox(height: 46),
                    PrimaryButton(
                      index == 2 ? 'Let’s Start' : 'Next',
                      onPressed: () {
                        if (index == 2) {
                          final s = AppScope.of(context);
                          s.onboarded = true;
                          s.save();
                        }
                        Navigator.pushReplacementNamed(
                          context,
                          index == 2 ? '/welcome' : '/onboarding-${index + 2}',
                        );
                      },
                    ),
                    if (index == 2)
                      Padding(
                        padding: const EdgeInsets.only(top: 18),
                        child: TextButton(
                          onPressed: () => toast(
                            context,
                            'Shopper registration is coming soon.',
                          ),
                          child: const Text(
                            'Not looking for groceries? Become a shopper',
                            style: TextStyle(fontSize: 10),
                          ),
                        ),
                      ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: LayoutBuilder(
      builder: (context, size) => SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: size.maxHeight * .58,
              width: double.infinity,
              child: art('welcome', fit: BoxFit.cover),
            ),
            SizedBox(
              height: 340,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Column(
                  children: [
                    art('mascot', height: 48),
                    const Spacer(),
                    const Text(
                      'Get your groceries\nReady for pickup items',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                    const Spacer(),
                    PrimaryButton(
                      'Get Started!',
                      onPressed: () => go(context, 'signup-welcome'),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class AuthPage extends StatefulWidget {
  final String mode;
  final bool focus;
  const AuthPage(this.mode, {super.key, this.focus = false});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final controller = TextEditingController();
  final form = GlobalKey<FormState>();
  bool visible = false;
  int seconds = 29;
  Timer? timer;
  bool get isPassword => widget.mode.contains('password');
  @override
  void initState() {
    super.initState();
    if (widget.mode == 'verify') {
      timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted && seconds > 0) setState(() => seconds--);
      });
    }
    if (widget.focus) {
      controller.text = widget.mode == 'email' ? 'Hello@Pitstudio.co' : '';
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    controller.dispose();
    super.dispose();
  }

  void submit() {
    if (!form.currentState!.validate()) return;
    final s = AppScope.of(context);
    switch (widget.mode) {
      case 'signup-welcome':
        go(context, 'signup-phone');
      case 'signup-phone':
        s.phone = controller.text;
        go(context, 'verify');
      case 'verify':
        go(context, 'email');
      case 'email':
        s.email = controller.text.trim();
        go(context, 'create-password');
      case 'login-phone':
        s.phone = controller.text;
        go(context, 'login-password');
      default:
        s.signedIn = true;
        s.onboarded = true;
        s.save();
        home(context);
    }
  }

  String? validate(String? value) {
    final text = value?.trim() ?? '';
    if (isPassword) {
      return RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$').hasMatch(text)
          ? null
          : 'Use 8+ characters with a letter and a number.';
    }
    if (widget.mode == 'email') {
      return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(text)
          ? null
          : 'Enter a valid email address.';
    }
    if (widget.mode == 'verify') {
      return text == '1234' ? null : 'Enter the 4-digit demo code: 1234.';
    }
    return text.replaceAll(RegExp(r'\D'), '').length >= 8
        ? null
        : 'Enter a valid phone number.';
  }

  @override
  Widget build(BuildContext context) {
    final welcome = widget.mode == 'signup-welcome';
    final otp = widget.mode == 'verify';
    final title = switch (widget.mode) {
      'login-phone' => 'Log in with your phone\nnumber',
      'login-password' => 'Enter your password',
      'signup-phone' => 'Enter your phone number',
      'verify' => 'Verification code OTP',
      'email' => 'What’s your email address',
      'create-password' => 'Create your password',
      _ => 'Welcome',
    };
    final subtitle = switch (widget.mode) {
      'login-phone' => 'Please enter your phone number to log in Ecobi.',
      'login-password' => 'Please enter your password to log in Ecobi.',
      'signup-phone' => 'Please enter your phone number to using Ecobi.',
      'verify' =>
        'A verification code has been sent to\n(+84) ${AppScope.of(context).phone}',
      'email' => 'Receipts will be sent to your email.',
      _ => 'Your password must be at least 8 characters long, and contain at least one letter and one digit.',
    };
    return PageLayout(
      title: '',
      child: Form(
        key: form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (welcome) ...[
              Center(child: art('mascot', height: 96)),
              const SizedBox(height: 16),
              Center(child: heading(title, size: 24)),
              const SizedBox(height: 40),
            ] else ...[
              heading(title, size: 24),
              const SizedBox(height: 10),
              caption(subtitle),
              const SizedBox(height: 24),
            ],
            if (isPassword)
              TextFormField(
                controller: controller,
                autofocus: widget.focus,
                obscureText: !visible,
                validator: validate,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  suffixIcon: IconButton(
                    tooltip: visible ? 'Hide password' : 'Show password',
                    onPressed: () => setState(() => visible = !visible),
                    icon: Icon(
                      visible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                    ),
                  ),
                ),
              )
            else
              Field(
                otp
                    ? '1  2  3  4'
                    : widget.mode == 'email'
                    ? 'Enter your email'
                    : 'Enter your phone number',
                controller: controller,
                keyboardType: widget.mode == 'email'
                    ? TextInputType.emailAddress
                    : TextInputType.phone,
                autofocus: widget.focus,
                validator: validate,
              ),
            if (otp) ...[
              const SizedBox(height: 14),
              Center(
                child: TextButton(
                  onPressed: seconds == 0
                      ? () {
                          setState(() => seconds = 29);
                          toast(context, 'Demo verification code: 1234');
                        }
                      : null,
                  child: Text(
                    '00:${seconds.toString().padLeft(2, '0')}  Resend',
                  ),
                ),
              ),
              Center(child: caption('Demo code: 1234')),
            ],
            const SizedBox(height: 40),
            PrimaryButton(
              welcome ? 'Continue with phone number' : 'Continue',
              onPressed: submit,
            ),
            if (welcome || widget.mode.startsWith('login')) ...[
              const SizedBox(height: 28),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Or', style: TextStyle(color: muted)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 22),
              for (final provider in ['Google', 'Apple', 'Facebook'])
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 54),
                      backgroundColor: provider == 'Apple'
                          ? ink
                          : provider == 'Facebook'
                          ? const Color(0xFF4166CE)
                          : Colors.white,
                      foregroundColor: provider == 'Google'
                          ? ink
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => toast(
                      context,
                      '$provider sign-in requires a connected authentication service. Use the demo phone flow.',
                    ),
                    child: Text('Continue with $provider'),
                  ),
                ),
            ],
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'By continuing, you agree to our',
                style: TextStyle(color: muted, fontSize: 11),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Ecobi demo'),
                    content: const Text(
                      'This is a local UI demonstration. No account is created and no payment is processed.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ),
                child: const Text(
                  'Terms of Service & Privacy Policy',
                  style: TextStyle(fontSize: 11),
                ),
              ),
            ),
            if (welcome)
              Center(
                child: TextButton(
                  onPressed: () => go(context, 'login-phone'),
                  child: const Text('Already have an account? Log in'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
