import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/app_state.dart';
import '../widgets/common.dart';

const voucherNames = ['Salmon fillet', 'Cafe Ara', 'Avocado'];
const voucherImages = ['salmon', 'coffee', 'avocado'];

class VouchersPage extends StatefulWidget {
  const VouchersPage({super.key});
  @override
  State<VouchersPage> createState() => _VouchersPageState();
}

class _VouchersPageState extends State<VouchersPage> {
  int tab = 0;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(
      children: [
        Container(
          height: 176,
          width: double.infinity,
          decoration: const BoxDecoration(color: green),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 24),
                const Text(
                  'My Vouchers',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Segments(
                  labels: const ['My voucher', 'Explore'],
                  selected: tab,
                  onChanged: (i) => setState(() => tab = i),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
            itemCount: tab == 0 ? 3 : 4,
            separatorBuilder: (_, i) => const SizedBox(height: 20),
            itemBuilder: (context, index) {
              final i = index % 3;
              return InkWell(
                onTap: () => Navigator.pushNamed(
                  context,
                  '/voucher-detail',
                  arguments: i,
                ),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  height: MediaQuery.sizeOf(context).width < 350 ? 196 : 160,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFF1F1F1)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: green,
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: Text(
                                  i == 1 ? '15% OFF' : '20% OFF',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              heading(voucherNames[i], size: 18),
                              const Spacer(),
                              Text(
                                [
                                  'Date. 22 Sep',
                                  'Date. 12 Nov',
                                  'Date. 10 Oct',
                                ][i],
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF499F78),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const VerticalDivider(
                        width: 1,
                        indent: 12,
                        endIndent: 12,
                        color: Color(0xFFEEEEEE),
                      ),
                      art(
                        voucherImages[i],
                        width: 112,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
    bottomNavigationBar: const BottomTabs(2),
  );
}

class VoucherDetailPage extends StatelessWidget {
  const VoucherDetailPage({super.key});
  @override
  Widget build(BuildContext context) {
    final i = (ModalRoute.of(context)?.settings.arguments as int?) ?? 1;
    return PageLayout(
      title: 'Voucher Details',
      bottom: PrimaryButton(
        'Use Voucher',
        onPressed: () {
          final s = AppScope.of(context);
          s.voucher = i == 1
              ? 'Cafe Ara'
              : i == 0
              ? 'Salmon Fillet'
              : 'Avocado';
          s.update();
          if (s.cart.isEmpty) {
            home(context);
          } else {
            go(context, 'checkout');
          }
        },
      ),
      child: Column(
        children: [
          SizedBox(
            height: 210,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: art(voucherImages[i], width: 200, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: green,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              i == 1 ? '15% OFF' : '20% OFF',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          heading(voucherNames[i], size: 24),
          const SizedBox(height: 28),
          const Panel(
            child: Wrap(
              spacing: 24,
              runSpacing: 12,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Expire date',
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '☀ 12 Dec',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment method',
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                    SizedBox(height: 10),
                    Text('Cash', style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          for (final text in [
            'Voucher is valid for ${i == 1 ? '15' : '20'}% off for orders with ${voucherNames[i]}.',
            'Voucher can only be used once per day and can be used again the next day.',
            'Voucher cannot be selected at the same time as another voucher.',
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                '•  $text',
                style: const TextStyle(fontSize: 12, height: 1.5),
              ),
            ),
        ],
      ),
    );
  }
}
