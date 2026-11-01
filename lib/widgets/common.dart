import 'package:flutter/material.dart';

import '../core/theme.dart';

void go(BuildContext context, String route) =>
    Navigator.of(context).pushNamed('/$route');
void home(BuildContext context) =>
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
void toast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

Widget art(
  String name, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.contain,
}) => Image.asset(
  'assets/images/$name.png',
  width: width,
  height: height,
  fit: fit,
  excludeFromSemantics: true,
);
Widget heading(String label, {double size = 20}) => Text(
  label,
  style: TextStyle(fontSize: size, fontWeight: FontWeight.w600, height: 1.4),
);
Widget caption(String label) =>
    Text(label, style: const TextStyle(color: muted, fontSize: 13));

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const PrimaryButton(this.label, {super.key, required this.onPressed});
  @override
  Widget build(BuildContext context) =>
      FilledButton(onPressed: onPressed, child: Text(label));
}

class PageLayout extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? bottom, action;
  final bool back, scroll;
  final Color background;
  const PageLayout({
    super.key,
    required this.title,
    required this.child,
    this.bottom,
    this.action,
    this.back = true,
    this.scroll = true,
    this.background = Colors.white,
  });
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: background,
    appBar: AppBar(
      backgroundColor: background,
      leading: back
          ? IconButton(
              tooltip: 'Back',
              icon: const Icon(Icons.arrow_back_rounded, size: 23),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  home(context);
                }
              },
            )
          : null,
      title: Text(title),
      actions: [if (action != null) action! else const SizedBox(width: 48)],
      toolbarHeight: 72,
    ),
    body: scroll
        ? SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
            child: child,
          )
        : Padding(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
            child: child,
          ),
    bottomNavigationBar: bottom == null
        ? null
        : SafeArea(
            top: false,
            minimum: const EdgeInsets.fromLTRB(24, 12, 24, 20),
            child: bottom!,
          ),
  );
}

class Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color color;
  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = surface,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
    ),
    child: child,
  );
}

class Segments extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;
  const Segments({
    super.key,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.scaleDown,
    child: Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          labels.length,
          (i) => InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => onChanged(i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: i == selected ? green : Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                labels[i],
                style: TextStyle(
                  color: i == selected ? Colors.white : muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class BottomTabs extends StatelessWidget {
  final int selected;
  const BottomTabs(this.selected, {super.key});
  @override
  Widget build(BuildContext context) {
    const labels = ['Home', 'Explore', 'Voucher', 'Profile'];
    const icons = [
      Icons.home_outlined,
      Icons.search_rounded,
      Icons.discount_outlined,
      Icons.person_outline_rounded,
    ];
    const routes = ['home', 'search', 'vouchers', 'profile'];
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: ink,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .18),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            4,
            (i) => Semantics(
              selected: selected == i,
              button: true,
              label: labels[i],
              child: InkWell(
                onTap: () {
                  if (i != selected) {
                    Navigator.of(context).pushReplacementNamed('/${routes[i]}');
                  }
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 8,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        icons[i],
                        color: selected == i
                            ? const Color(0xFF58D47A)
                            : Colors.white,
                        size: 25,
                      ),
                      if (i == selected) ...[
                        const SizedBox(width: 5),
                        Text(
                          labels[i],
                          style: const TextStyle(
                            color: Color(0xFF58D47A),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label, value;
  final bool total;
  const InfoRow(this.label, this.value, {super.key, this.total = false});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: total ? green : const Color(0xFF606060),
              fontSize: total ? 20 : 14,
              fontWeight: total ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: total ? 20 : 16,
              color: total ? green : ink,
            ),
          ),
        ),
      ],
    ),
  );
}

class Field extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscure, autofocus;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  const Field(
    this.hint, {
    super.key,
    required this.controller,
    this.keyboardType,
    this.obscure = false,
    this.autofocus = false,
    this.validator,
    this.onChanged,
  });
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    obscureText: obscure,
    autofocus: autofocus,
    validator: validator,
    onChanged: onChanged,
    decoration: InputDecoration(hintText: hint),
    style: const TextStyle(fontSize: 15),
  );
}

class BadgeLabel extends StatelessWidget {
  final String text;
  const BadgeLabel(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF2D7),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Text(
      '★ $text',
      style: const TextStyle(color: Color(0xFFFFA21D), fontSize: 12),
    ),
  );
}
