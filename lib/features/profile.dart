import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme.dart';
import '../data/app_state.dart';
import '../widgets/common.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    const labels = [
      'Personal Info',
      'Payment Method',
      'Order History',
      'Savings',
      'Vouchers',
      'Referral',
      'About Ecobi',
    ];
    const routes = [
      'personal-info',
      'payment',
      'orders',
      'saved',
      'vouchers',
      'referral',
      'about',
    ];
    const icons = [
      Icons.person,
      Icons.credit_card,
      Icons.shopping_bag,
      Icons.bookmark,
      Icons.discount,
      Icons.people,
      Icons.info,
    ];
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.topCenter,
              children: [
                art(
                  'profile_bg',
                  width: double.infinity,
                  height: 172,
                  fit: BoxFit.fill,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 92),
                  child: InkWell(
                    onTap: () => go(context, 'personal-info'),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: art('mascot', width: 104, height: 104),
                    ),
                  ),
                ),
              ],
            ),
            heading(s.name),
            const SizedBox(height: 8),
            const BadgeLabel('Gold'),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: List.generate(
                  labels.length,
                  (i) => Column(
                    children: [
                      if (i == 3 || i == 6)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(color: mint),
                        ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        onTap: () => go(context, routes[i]),
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundColor: const Color(0xFFF0FFF3),
                          child: Icon(icons[i], color: green, size: 22),
                        ),
                        title: Text(
                          labels[i],
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Color(0xFFBDBDBD),
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: const BottomTabs(3),
    );
  }
}

class PersonalInfoPage extends StatefulWidget {
  final bool focus;
  const PersonalInfoPage({super.key, this.focus = false});
  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController(),
      email = TextEditingController(),
      phone = TextEditingController();
  bool ready = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!ready) {
      final s = AppScope.of(context);
      name.text = s.name;
      email.text = s.email;
      phone.text = s.phone;
      ready = true;
    }
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PageLayout(
    title: 'Personal Info',
    bottom: PrimaryButton(
      'Save',
      onPressed: () {
        if (form.currentState!.validate()) {
          final s = AppScope.of(context);
          s.name = name.text.trim();
          s.email = email.text.trim();
          s.phone = phone.text.trim();
          s.save();
          toast(context, 'Personal information saved');
          Navigator.pop(context);
        }
      },
    ),
    child: Form(
      key: form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: art('mascot', width: 104, height: 104)),
          const SizedBox(height: 12),
          Center(child: heading(name.text)),
          const SizedBox(height: 8),
          const Center(child: BadgeLabel('Gold')),
          const SizedBox(height: 32),
          caption('Full name'),
          const SizedBox(height: 8),
          Field(
            'Full name',
            controller: name,
            autofocus: widget.focus,
            validator: (v) =>
                v!.trim().isEmpty ? 'Please enter your name.' : null,
          ),
          const SizedBox(height: 24),
          caption('Email'),
          const SizedBox(height: 8),
          Field(
            'Email',
            controller: email,
            keyboardType: TextInputType.emailAddress,
            validator: (v) => RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v!)
                ? null
                : 'Enter a valid email.',
          ),
          const SizedBox(height: 24),
          caption('Phone number'),
          const SizedBox(height: 8),
          Field(
            '+84',
            controller: phone,
            keyboardType: TextInputType.phone,
            validator: (v) => v!.replaceAll(RegExp(r'\D'), '').length < 8
                ? 'Enter a valid phone number.'
                : null,
          ),
        ],
      ),
    ),
  );
}

class BankCard extends StatelessWidget {
  final String number, name, expiry;
  const BankCard({
    super.key,
    this.number = '**** **** **** 3042',
    this.name = 'Peter Evans',
    this.expiry = '02/30',
  });
  @override
  Widget build(BuildContext context) => Container(
    height: 190,
    width: double.infinity,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: const Color(0xFF1A9D56),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Stack(
      children: [
        Positioned(
          right: -48,
          bottom: -36,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: const Color(0xFF52B34B).withValues(alpha: .6),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          right: 20,
          top: -18,
          child: Icon(
            Icons.eco,
            size: 95,
            color: Colors.white.withValues(alpha: .08),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ecobi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(Icons.eco, color: Colors.white),
                ],
              ),
              Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  letterSpacing: 1,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  Text(
                    expiry,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class PaymentPage extends StatelessWidget {
  final bool empty;
  const PaymentPage({super.key, this.empty = false});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final noCard = empty || s.cards.isEmpty;
    return PageLayout(
      title: 'Payment Methods',
      action: IconButton(
        tooltip: 'Remove saved card',
        onPressed: () async {
          final result = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Remove saved card?'),
              content: const Text('You can add a new demo card at any time.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Remove'),
                ),
              ],
            ),
          );
          if (result == true) {
            s.cards.clear();
            s.save();
          }
        },
        icon: const Icon(Icons.more_vert),
      ),
      bottom: PrimaryButton(
        'Add new card',
        onPressed: () => go(context, 'add-card'),
      ),
      child: noCard
          ? Column(
              children: [
                art('empty_card', height: 336),
                const SizedBox(height: 28),
                heading('Empty Card!', size: 24),
                const SizedBox(height: 16),
                const Text(
                  'Add your payment method to\nenjoy our services',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: muted),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                heading('Default Payment', size: 16),
                const SizedBox(height: 24),
                BankCard(
                  number: '**** **** **** ${s.cards.last}',
                  name: s.name,
                ),
                const SizedBox(height: 42),
                heading('Another Payment', size: 16),
                const SizedBox(height: 24),
                Panel(
                  child: Row(
                    children: [
                      const Icon(Icons.credit_card, color: Color(0xFFFFA21D)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          '● ● ●  ● ● ●  ${s.cards.last}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => toast(
                    context,
                    'Apple Pay requires a payment provider connection.',
                  ),
                  child: const Panel(
                    child: Row(
                      children: [
                        Icon(Icons.apple),
                        SizedBox(width: 16),
                        Expanded(child: Text('Connect your Apple Pay')),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class AddCardPage extends StatefulWidget {
  final bool focus;
  const AddCardPage({super.key, this.focus = false});
  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController(text: 'Peter Evans'),
      number = TextEditingController(),
      expiry = TextEditingController(),
      cvv = TextEditingController();
  @override
  void initState() {
    super.initState();
    if (widget.focus) number.text = '2832019213123';
  }

  @override
  void dispose() {
    for (final c in [name, number, expiry, cvv]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PageLayout(
    title: 'Add new card',
    bottom: PrimaryButton(
      'Add Card',
      onPressed: () {
        if (form.currentState!.validate()) {
          final s = AppScope.of(context);
          final digits = number.text.replaceAll(RegExp(r'\D'), '');
          s.cards.add(digits.substring(digits.length - 4));
          s.save();
          toast(context, 'Demo card saved');
          Navigator.pop(context);
        }
      },
    ),
    child: Form(
      key: form,
      child: Column(
        children: [
          BankCard(
            number: number.text.isEmpty
                ? '---- ---- ---- ----'
                : number.text
                      .replaceAllMapped(RegExp(r'.{1,4}'), (m) => '${m[0]} ')
                      .trim(),
            name: name.text,
            expiry: expiry.text.isEmpty ? '--/--' : expiry.text,
          ),
          const SizedBox(height: 44),
          Field(
            'Cardholder name',
            controller: name,
            onChanged: (_) => setState(() {}),
            validator: (v) =>
                v!.trim().isEmpty ? 'Enter cardholder name.' : null,
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: number,
            autofocus: widget.focus,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
            ],
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'Enter your card number',
            ),
            validator: (v) => RegExp(r'^\d{16}$').hasMatch(v!)
                ? null
                : 'Enter a 16-digit demo card number.',
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Field(
                  'MM/YY',
                  controller: expiry,
                  keyboardType: TextInputType.datetime,
                  onChanged: (_) => setState(() {}),
                  validator: (v) =>
                      RegExp(r'^(0[1-9]|1[0-2])/\d{2}$').hasMatch(v!)
                      ? null
                      : 'Use MM/YY.',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Field(
                  'CVV',
                  controller: cvv,
                  obscure: true,
                  keyboardType: TextInputType.number,
                  validator: (v) => RegExp(r'^\d{3,4}$').hasMatch(v!)
                      ? null
                      : 'Use 3–4 digits.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          caption('Demo card • only the last four digits are saved.'),
        ],
      ),
    ),
  );
}

class SavedPage extends StatefulWidget {
  final bool menu;
  const SavedPage({super.key, this.menu = false});
  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  final menuKey = GlobalKey<PopupMenuButtonState<String>>();
  @override
  void initState() {
    super.initState();
    if (widget.menu) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => menuKey.currentState?.showButtonMenu(),
      );
    }
  }

  bool showFavorites = false;
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    const names = [
      'Pieco Farm',
      'MS’s Market',
      'Fruit Market',
      'Sprout’s Market',
      'FoodsEco',
    ];
    return PageLayout(
      title: 'Saved',
      action: IconButton(
        tooltip: 'Saved products',
        onPressed: () => setState(() => showFavorites = !showFavorites),
        icon: Icon(
          showFavorites ? Icons.storefront_outlined : Icons.favorite_border,
        ),
      ),
      child: Column(
        children: [
          if (showFavorites) ...[
            if (s.favorites.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 80),
                child: Text(
                  'No saved products yet.\nTap the heart on a product to save it.',
                  textAlign: TextAlign.center,
                ),
              ),
            for (final id in s.favorites)
              ListTile(
                leading: art(id, width: 56, height: 60),
                title: Text(productById(id).name),
                trailing: IconButton(
                  tooltip: 'Remove favorite',
                  onPressed: () => s.toggleFavorite(id),
                  icon: const Icon(Icons.favorite, color: green),
                ),
                onTap: () {
                  s.selectedProduct = id;
                  go(context, 'product');
                },
              ),
          ] else
            for (final i in s.savedStores)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Panel(
                  child: Row(
                    children: [
                      art('store${i + 1}', width: 96, height: 96),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            heading(names[i], size: 18),
                            caption('⌖ Hanoi, Vietnam'),
                            const SizedBox(height: 14),
                            BadgeLabel(
                              i < 2
                                  ? 'Top Picks'
                                  : i == 2
                                  ? 'Hot Deals'
                                  : 'Fast Delivery',
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        key: i == s.savedStores.first ? menuKey : null,
                        tooltip: 'Store options',
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'open',
                            child: Text('Explore store'),
                          ),
                          PopupMenuItem(
                            value: 'remove',
                            child: Text('Remove from saved'),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'remove') {
                            s.toggleStore(i);
                          } else {
                            Navigator.pushNamed(context, '/results');
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
          if (!showFavorites && s.savedStores.isEmpty)
            const Text('No saved stores.'),
        ],
      ),
    );
  }
}

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});
  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  int tab = 1;
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final demo = <Map<String, dynamic>>[
      {
        'id': 'HNBJKM09',
        'items': {'salmon': 1},
        'total': 79,
        'received': true,
      },
      {
        'id': 'HNMSJD871',
        'items': {'corn': 1},
        'total': 25,
        'received': true,
        'cancelled': true,
      },
    ];
    final orders = [...s.orders, ...demo]
        .where((o) => tab == 0 ? o['received'] != true : o['received'] == true)
        .toList();
    return PageLayout(
      title: 'Order History',
      child: Column(
        children: [
          Segments(
            labels: const ['Ongoing', 'History'],
            selected: tab,
            onChanged: (i) => setState(() => tab = i),
          ),
          const SizedBox(height: 28),
          if (orders.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 60),
              child: Column(
                children: [
                  art('empty_cart', height: 200),
                  heading('No ongoing orders'),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => home(context),
                    child: const Text('Explore Product'),
                  ),
                ],
              ),
            ),
          for (final order in orders)
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Panel(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          order['cancelled'] == true
                              ? 'Cancel'
                              : order['received'] == true
                              ? 'Completed'
                              : 'On the way',
                          style: TextStyle(
                            color: order['cancelled'] == true
                                ? Colors.red
                                : green,
                            fontSize: 12,
                          ),
                        ),
                        caption('#${order['id']}'),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              heading(
                                productById(
                                  (order['items'] as Map).keys.first as String,
                                ).name,
                                size: 18,
                              ),
                              caption('Picovina Food'),
                              const SizedBox(height: 12),
                              Text(
                                money(order['total'] as num),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: art(
                            (order['items'] as Map).keys.first as String,
                            width: 96,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              if (order['received'] != true) {
                                go(context, 'tracking');
                              } else {
                                s.selectedProduct =
                                    (order['items'] as Map).keys.first
                                        as String;
                                go(context, 'reviews');
                              }
                            },
                            child: Text(
                              order['received'] == true ? 'Rate' : 'Track',
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: PrimaryButton(
                            'Re-order',
                            onPressed: () {
                              s.reorder(order);
                              go(context, 'cart');
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ReferralPage extends StatefulWidget {
  const ReferralPage({super.key});
  @override
  State<ReferralPage> createState() => _ReferralPageState();
}

class _ReferralPageState extends State<ReferralPage> {
  final invited = <int>{2};
  @override
  Widget build(BuildContext context) => PageLayout(
    title: 'Referral',
    child: Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            height: 230,
            width: double.infinity,
            child: art('referral_bg', fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 24),
        heading('Refer & Earn'),
        const SizedBox(height: 10),
        const Text(
          'Share this code with your friend and\nyou both get \$10',
          textAlign: TextAlign.center,
          style: TextStyle(color: muted),
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: green,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Text(
                'ECOBI22',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () async {
                  await Clipboard.setData(const ClipboardData(text: 'ECOBI22'));
                  if (context.mounted) toast(context, 'Referral code copied');
                },
                child: const Text(
                  'Copy',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        caption('OR SEND INVITE'),
        const SizedBox(height: 16),
        for (int i = 0; i < 3; i++)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: mint,
              child: Text(
                ['R', 'K', 'T'][i],
                style: const TextStyle(color: green),
              ),
            ),
            title: Text(
              ['Ryan Boo', 'Koo Moo', 'Taa Daa'][i],
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: caption('0123 456 789'),
            trailing: TextButton(
              onPressed: invited.contains(i)
                  ? null
                  : () {
                      setState(() => invited.add(i));
                      toast(
                        context,
                        'Demo invitation marked. No message was sent.',
                      );
                    },
              child: Text(invited.contains(i) ? 'Invited' : '+ Invite'),
            ),
          ),
      ],
    ),
  );
}
