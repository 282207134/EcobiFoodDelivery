import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/app_state.dart';
import '../widgets/common.dart';

class CartPage extends StatefulWidget {
  final bool empty, deletePreview, dialogPreview;
  const CartPage({
    super.key,
    this.empty = false,
    this.deletePreview = false,
    this.dialogPreview = false,
  });
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    if (widget.dialogPreview) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) confirmRemove('avocado');
      });
    }
  }

  Future<void> confirmRemove(String id) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              art('delete', width: 180, height: 180),
              heading('Delete Selection?', size: 22),
              const SizedBox(height: 12),
              const Text(
                'Are you sure you want to\ndelete your selection?',
                textAlign: TextAlign.center,
                style: TextStyle(color: muted),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                'Delete',
                onPressed: () => Navigator.pop(ctx, true),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
    if (result == true && mounted) AppScope.of(context).remove(id);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final empty = widget.empty || s.cart.isEmpty;
    return PageLayout(
      title: 'My Cart',
      bottom: PrimaryButton(
        empty ? 'Explore Product' : 'Check Out',
        onPressed: () => empty ? home(context) : go(context, 'checkout'),
      ),
      child: empty
          ? Column(
              children: [
                art('empty_cart', height: 320),
                const SizedBox(height: 24),
                heading('Your cart is empty!', size: 24),
                const SizedBox(height: 12),
                const Text(
                  'Explore our products and find\nsomething for you.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: muted),
                ),
              ],
            )
          : Column(
              children: [
                for (final entry in s.cart.entries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Dismissible(
                      key: ValueKey(entry.key),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (_) async {
                        await confirmRemove(entry.key);
                        return false;
                      },
                      background: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE4E4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.all(20),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                      ),
                      child: Panel(
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: art(
                                entry.key,
                                width: 64,
                                height: 72,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.key == 'avocado'
                                        ? 'Booth Avocado'
                                        : productById(entry.key).name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text(
                                        money(productById(entry.key).price),
                                        style: const TextStyle(
                                          color: green,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Spacer(),
                                      _quantity(
                                        'Decrease ${entry.key}',
                                        Icons.remove_circle,
                                        () => entry.value == 1
                                            ? confirmRemove(entry.key)
                                            : s.decrease(entry.key),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        child: Text(
                                          '${entry.value}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      _quantity(
                                        'Increase ${entry.key}',
                                        Icons.add_circle,
                                        () => s.add(entry.key),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (widget.deletePreview &&
                                MediaQuery.sizeOf(context).width >= 375)
                              IconButton(
                                tooltip: 'Delete ${entry.key}',
                                onPressed: () => confirmRemove(entry.key),
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                const Divider(color: Color(0xFFDDDDDD)),
                const SizedBox(height: 8),
                const Totals(),
              ],
            ),
    );
  }

  Widget _quantity(String label, IconData icon, VoidCallback onTap) => SizedBox(
    width: 28,
    height: 32,
    child: IconButton(
      tooltip: label,
      padding: EdgeInsets.zero,
      onPressed: onTap,
      icon: Icon(icon, size: 26, color: ink),
    ),
  );
}

class Totals extends StatelessWidget {
  const Totals({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Column(
      children: [
        InfoRow('Sub Total', money(s.subtotal)),
        const InfoRow('Delivery Fee', '\$0'),
        if (s.discount > 0)
          InfoRow('Voucher discount', '-${money(s.discount)}'),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Divider(color: Color(0xFFDDDDDD)),
        ),
        InfoRow('Total', money(s.total), total: true),
      ],
    );
  }
}

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return PageLayout(
      title: 'Order',
      bottom: PrimaryButton(
        'Place Order',
        onPressed: s.cart.isEmpty
            ? null
            : () {
                s.placeOrder();
                Navigator.pushReplacementNamed(context, '/success');
              },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          heading('Deliver to'),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => go(context, 'addresses'),
            child: Panel(
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: art(
                      'mini_map',
                      width: 134,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        heading(s.address, size: 16),
                        const SizedBox(height: 8),
                        caption(
                          s.address == 'Home'
                              ? 'Jump Street, New York, NY 10004, USA'
                              : 'Wall Street, New York, NY 10004, USA',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          heading('Add voucher'),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => go(context, 'promotions'),
            child: Panel(
              child: Row(
                children: [
                  const Icon(Icons.discount, color: green, size: 28),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        heading(
                          s.voucher.isEmpty ? 'Choose a voucher' : '20% OFF',
                          size: 16,
                        ),
                        caption(
                          s.voucher.isEmpty
                              ? 'Save on your next order'
                              : s.voucher,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Totals(),
          const SizedBox(height: 20),
          InkWell(
            onTap: () => go(context, 'payment-select'),
            child: Panel(
              child: Row(
                children: [
                  const Icon(
                    Icons.credit_card,
                    color: Color(0xFFFFA122),
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      s.payment == 'Mastercard'
                          ? '● ● ●  ● ● ●   ${s.cards.isEmpty ? 'Cash' : s.cards.last}'
                          : s.payment,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SelectionPage extends StatefulWidget {
  final String kind;
  const SelectionPage(this.kind, {super.key});
  @override
  State<SelectionPage> createState() => _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage> {
  String? selected;
  final code = TextEditingController();
  final extraAddresses = <String>[];
  @override
  void dispose() {
    code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final address = widget.kind == 'addresses';
    final promotion = widget.kind == 'promotions';
    final options = address
        ? ['Home', 'Work', 'Lily’s house', ...extraAddresses]
        : promotion
        ? ['Salmon Fillet', 'Avocado', 'Cafe Ara']
        : ['Mastercard', 'Apple Pay', 'Paypal', 'Cash'];
    selected ??= address
        ? s.address
        : promotion
        ? (s.voucher.isEmpty ? options.first : s.voucher)
        : s.payment;
    return PageLayout(
      title: address
          ? 'Address'
          : promotion
          ? 'Choose Voucher'
          : 'Payment',
      bottom: PrimaryButton(
        address
            ? 'Confirm Address'
            : promotion
            ? 'Confirm'
            : 'Confirm Payment',
        onPressed: () {
          if (address) {
            s.address = selected!;
          } else if (promotion) {
            s.voucher = selected!;
          } else {
            s.payment = selected!;
          }
          s.update();
          Navigator.pop(context);
        },
      ),
      child: Column(
        children: [
          if (promotion) ...[
            TextField(
              controller: code,
              decoration: InputDecoration(
                hintText: 'freeship, 10% off,...',
                suffixIcon: IconButton(
                  tooltip: 'Apply code',
                  onPressed: () {
                    if (code.text.toUpperCase() == 'ECOBI20') {
                      setState(() => selected = 'Salmon Fillet');
                      toast(context, '20% voucher selected');
                    } else {
                      toast(context, 'Try demo code ECOBI20');
                    }
                  },
                  icon: const Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          for (final option in options)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: InkWell(
                onTap: () => setState(() => selected = option),
                borderRadius: BorderRadius.circular(20),
                child: Panel(
                  color: selected == option ? surface : Colors.white,
                  child: Row(
                    children: [
                      if (promotion) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: art(
                            option == 'Salmon Fillet'
                                ? 'salmon'
                                : option == 'Avocado'
                                ? 'avocado'
                                : 'coffee',
                            width: 70,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 16),
                      ] else if (!address) ...[
                        Icon(
                          option == 'Apple Pay'
                              ? Icons.apple
                              : Icons.credit_card,
                          size: 28,
                        ),
                        const SizedBox(width: 16),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            heading(
                              promotion
                                  ? (option == 'Cafe Ara'
                                        ? '15% OFF'
                                        : '20% OFF')
                                  : option,
                              size: 16,
                            ),
                            const SizedBox(height: 8),
                            caption(
                              address
                                  ? '${option == 'Home' ? 'Jump' : 'Wall'} Street, NY 10004, New York, USA'
                                  : promotion
                                  ? 'For order with $option'
                                  : option == 'Mastercard'
                                  ? '•••• 3042'
                                  : 'Local demo payment',
                            ),
                            if (address) ...[
                              const SizedBox(height: 4),
                              caption('+12 435 687 999'),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        selected == option
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: selected == option
                            ? green
                            : const Color(0xFFCCCCCC),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (address)
            TextButton.icon(
              onPressed: addAddress,
              icon: const Icon(Icons.add),
              label: const Text('Add New Address'),
            ),
          if (!address && !promotion)
            TextButton.icon(
              onPressed: () => go(context, 'add-card'),
              icon: const Icon(Icons.add),
              label: const Text('Add New Card'),
            ),
        ],
      ),
    );
  }

  void addAddress() {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add address'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Address label'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  extraAddresses.add(controller.text.trim());
                  selected = controller.text.trim();
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    ).then((_) => controller.dispose());
  }
}

class SuccessPage extends StatelessWidget {
  const SuccessPage({super.key});
  @override
  Widget build(BuildContext context) => PageLayout(
    title: '',
    back: false,
    bottom: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PrimaryButton(
          'Track Order',
          onPressed: () => Navigator.pushReplacementNamed(context, '/tracking'),
        ),
        TextButton(
          onPressed: () => home(context),
          child: const Text('Go to Home'),
        ),
      ],
    ),
    child: Column(
      children: [
        art('success', height: 336),
        const SizedBox(height: 36),
        heading('Payment Success!', size: 24),
        const SizedBox(height: 16),
        const Text(
          'The order has been paid. Shipper will\ndeliver to you soon',
          textAlign: TextAlign.center,
          style: TextStyle(color: muted),
        ),
        const SizedBox(height: 16),
        caption('Demo order • no payment has been charged'),
      ],
    ),
  );
}

class TrackingPage extends StatelessWidget {
  const TrackingPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      children: [
        Positioned.fill(child: art('map', fit: BoxFit.cover)),
        SafeArea(
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  tooltip: 'Back',
                  onPressed: () => home(context),
                  icon: const Icon(Icons.arrow_back),
                ),
                title: const Text('Tracking'),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Panel(
                  color: Colors.white,
                  child: Row(
                    children: [
                      art('mascot', width: 64, height: 64),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            heading('Peter Evans', size: 18),
                            const Text('⭐ 4.9/5'),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Contact courier',
                        onPressed: () => toast(
                          context,
                          'Demo courier • contact service is not connected.',
                        ),
                        icon: const Icon(Icons.phone, color: green),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.location_on, color: green),
                      title: caption('Delivery to'),
                      subtitle: const Text(
                        'Jump Street, New York, NY 10004',
                        style: TextStyle(
                          color: ink,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.schedule,
                        color: Color(0xFFFFA339),
                      ),
                      title: caption('Estimated time'),
                      subtitle: const Text(
                        '15 mins',
                        style: TextStyle(
                          color: ink,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      'Order Received',
                      onPressed: () {
                        final s = AppScope.of(context);
                        if (s.orders.isNotEmpty) {
                          s.orders.first['received'] = true;
                          s.save();
                        }
                        toast(context, 'Order marked as received');
                        home(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
