import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/app_state.dart';
import '../widgets/common.dart';

void openProduct(BuildContext context, Product product) {
  AppScope.of(context).selectedProduct = product.id;
  go(context, 'product');
}

class ProductCard extends StatelessWidget {
  final Product product;
  final double height;
  const ProductCard(this.product, {super.key, this.height = 196});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      InkWell(
        onTap: () => openProduct(context, product),
        borderRadius: BorderRadius.circular(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: art(
            product.id,
            width: double.infinity,
            height: height,
            fit: BoxFit.cover,
          ),
        ),
      ),
      const SizedBox(height: 14),
      Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => openProduct(context, product),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    children: [
                      Text(
                        money(product.price),
                        style: const TextStyle(
                          color: green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        money(product.oldPrice),
                        style: const TextStyle(
                          color: muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 32,
            height: 40,
            child: IconButton(
              padding: EdgeInsets.zero,
              tooltip: 'Add ${product.name}',
              onPressed: () {
                AppScope.of(context).add(product.id);
                toast(context, '${product.name} added to cart');
              },
              icon: const Icon(Icons.add_box_rounded, size: 32, color: ink),
            ),
          ),
        ],
      ),
    ],
  );
}

class ProductGrid extends StatelessWidget {
  final List<Product> items;
  const ProductGrid(this.items, {super.key});
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (int col = 0; col < 2; col++) ...[
        if (col == 1) const SizedBox(width: 24),
        Expanded(
          child: Column(
            children: [
              for (int i = col; i < items.length; i += 2)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: ProductCard(
                    items[i],
                    height: (i == 1 || i == 2) ? 231 : 196,
                  ),
                ),
            ],
          ),
        ),
      ],
    ],
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(
        tooltip: 'Scan barcode',
        onPressed: () => go(context, 'scan-permission'),
        icon: const Icon(Icons.qr_code_scanner_rounded),
      ),
      title: const Text('Hi, Nguyen'),
      actions: [
        IconButton(
          tooltip: 'My Cart',
          onPressed: () => go(context, 'cart'),
          icon: Badge(
            isLabelVisible: AppScope.of(context).count > 0,
            label: Text('${AppScope.of(context).count}'),
            child: const Icon(Icons.shopping_basket_outlined),
          ),
        ),
        const SizedBox(width: 12),
      ],
      toolbarHeight: 72,
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => go(context, 'vouchers'),
            child: art(
              'banner',
              width: double.infinity,
              height: 144,
              fit: BoxFit.fill,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              separatorBuilder: (_, i) => const SizedBox(width: 24),
              itemBuilder: (context, i) {
                const names = [
                  'Meat',
                  'Fruit',
                  'Vegetable',
                  'Seafood',
                  'Bread',
                ];
                const images = [
                  'meat',
                  'fruit',
                  'vegetable',
                  'seafood',
                  'bread',
                ];
                return InkWell(
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/results',
                    arguments: names[i],
                  ),
                  child: Column(
                    children: [
                      art('${images[i]}_category', width: 56, height: 56),
                      const SizedBox(height: 10),
                      Text(
                        names[i],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 24,
              height: 4,
              decoration: BoxDecoration(
                color: mint,
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.centerLeft,
              child: Container(
                width: 16,
                decoration: BoxDecoration(
                  color: green,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          heading('Today’s Special'),
          const SizedBox(height: 30),
          ProductGrid([products[0], products[1], products[2], products[3]]),
        ],
      ),
    ),
    bottomNavigationBar: const BottomTabs(0),
  );
}

class SearchPage extends StatefulWidget {
  final bool results, filtered;
  const SearchPage({super.key, this.results = false, this.filtered = false});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final controller = TextEditingController();
  String query = '';
  bool initial = true;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (initial) {
      query = (ModalRoute.of(context)?.settings.arguments as String?) ?? '';
      controller.text = query;
      initial = false;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final result = products
        .where(
          (p) =>
              '${p.name} ${p.category}'.toLowerCase().contains(
                query.toLowerCase(),
              ) &&
              (!widget.filtered ||
                  (p.price >= s.prices.start && p.price <= s.prices.end)),
        )
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Filter',
            onPressed: () => go(context, 'filter'),
            icon: const Icon(Icons.filter_alt_outlined),
          ),
          const SizedBox(width: 12),
        ],
        toolbarHeight: 72,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              onChanged: (value) => setState(() => query = value),
              decoration: InputDecoration(
                hintText: 'Fruit, meat,...',
                prefixIcon: const Icon(Icons.search, color: muted),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        tooltip: 'Clear search',
                        onPressed: () {
                          controller.clear();
                          setState(() => query = '');
                        },
                        icon: const Icon(Icons.close, size: 18),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 28),
            if (widget.filtered) ...[
              Wrap(
                spacing: 8,
                children: [
                  Chip(label: Text(s.city)),
                  Chip(
                    label: Text(
                      '${money(s.prices.start)} – ${money(s.prices.end)}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            if (query.isEmpty && !widget.results) ...[
              heading('Recent Search', size: 16),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children:
                    [
                          'Orange',
                          'Beef',
                          'Chicken',
                          'Diet cupcake',
                          'Flower',
                          'Soda',
                        ]
                        .map(
                          (e) => ActionChip(
                            label: Text(e),
                            backgroundColor: surface,
                            side: BorderSide.none,
                            onPressed: () {
                              controller.text = e;
                              setState(() => query = e);
                            },
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: 32),
              heading('Popular Results', size: 20),
            ] else
              heading('Fresh Product'),
            const SizedBox(height: 24),
            if (result.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 70),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.search_off, size: 48, color: muted),
                      const SizedBox(height: 16),
                      heading('No products found'),
                      caption('Try another search or reset the filters.'),
                    ],
                  ),
                ),
              )
            else
              ProductGrid(
                query.isEmpty && !widget.results
                    ? result.take(2).toList()
                    : result,
              ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomTabs(1),
    );
  }
}

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});
  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  String? city;
  RangeValues? range;
  bool? fees, promo, accessible;
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    city ??= s.city;
    range ??= s.prices;
    fees ??= s.showFees;
    promo ??= s.promoOnly;
    accessible ??= s.accessible;
    return PageLayout(
      title: 'Filter',
      bottom: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => setState(() {
                city = 'New York';
                range = const RangeValues(0, 999);
                fees = false;
                promo = false;
                accessible = false;
              }),
              child: const Text('Reset'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: PrimaryButton(
              'Apply',
              onPressed: () {
                s.city = city!;
                s.prices = range!;
                s.showFees = fees!;
                s.promoOnly = promo!;
                s.accessible = accessible!;
                s.update();
                Navigator.pushReplacementNamed(context, '/filtered');
              },
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          heading('Place of sale'),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: ['New York', 'Boston', 'Washington', 'Las Vegas']
                .map(
                  (c) => ChoiceChip(
                    label: Text(c),
                    selected: city == c,
                    selectedColor: green,
                    backgroundColor: surface,
                    labelStyle: TextStyle(
                      color: city == c ? Colors.white : ink,
                    ),
                    side: BorderSide.none,
                    showCheckmark: false,
                    onSelected: (_) => setState(() => city = c),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 30),
          const Divider(color: surface),
          const SizedBox(height: 10),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Show price with fees',
              style: TextStyle(fontSize: 14),
            ),
            value: fees!,
            onChanged: (v) => setState(() => fees = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Support promo codes',
              style: TextStyle(fontSize: 14),
            ),
            value: promo!,
            onChanged: (v) => setState(() => promo = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Accessible', style: TextStyle(fontSize: 14)),
            value: accessible!,
            onChanged: (v) => setState(() => accessible = v),
          ),
          const SizedBox(height: 30),
          const Divider(color: surface),
          const SizedBox(height: 24),
          heading('Price Range'),
          const SizedBox(height: 24),
          RangeSlider(
            values: range!,
            min: 0,
            max: 999,
            divisions: 999,
            labels: RangeLabels(money(range!.start), money(range!.end)),
            onChanged: (v) => setState(() => range = v),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              caption('0\$'),
              Text(money(range!.start)),
              Text(money(range!.end)),
              caption('999\$'),
            ],
          ),
        ],
      ),
    );
  }
}

class ProductPage extends StatelessWidget {
  final bool reviews;
  const ProductPage({super.key, this.reviews = false});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final p = s.product;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  height: reviews ? 220 : 342,
                  width: double.infinity,
                  child: p.id == 'salmon'
                      ? art('product_hero', fit: BoxFit.cover)
                      : art(p.id, fit: BoxFit.cover),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          tooltip: 'Back',
                          onPressed: () => Navigator.canPop(context)
                              ? Navigator.pop(context)
                              : home(context),
                          icon: const Icon(Icons.arrow_back),
                        ),
                        IconButton(
                          tooltip: 'Save product',
                          onPressed: () => s.toggleFavorite(p.id),
                          icon: Icon(
                            s.favorites.contains(p.id)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: s.favorites.contains(p.id) ? green : ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Transform.translate(
              offset: const Offset(0, -24),
              child: Segments(
                labels: const ['Detail', 'Reviews'],
                selected: reviews ? 1 : 0,
                onChanged: (i) {
                  if ((i == 1) != reviews) {
                    Navigator.pushReplacementNamed(
                      context,
                      i == 1 ? '/reviews' : '/product',
                    );
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: reviews
                  ? _reviews(context)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: heading(p.name, size: 24)),
                            Text(
                              money(p.oldPrice),
                              style: const TextStyle(
                                color: muted,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              money(p.price),
                              style: const TextStyle(
                                color: green,
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: surface),
                        const SizedBox(height: 16),
                        heading('Product details', size: 16),
                        const SizedBox(height: 12),
                        InfoRow('Brand', p.brand),
                        InfoRow('Categories', p.category),
                        const InfoRow('Net weight', '300g'),
                        const SizedBox(height: 16),
                        heading('Also buy with', size: 16),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 202,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: 3,
                            separatorBuilder: (_, i) =>
                                const SizedBox(width: 16),
                            itemBuilder: (context, i) => InkWell(
                              onTap: () {
                                if (i == 1) {
                                  s.selectedProduct = 'avocado';
                                  s.update();
                                } else {
                                  toast(
                                    context,
                                    'Steak’s Spices added to your shopping list',
                                  );
                                }
                              },
                              child: Container(
                                width: 144,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: mint,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: art(i == 1 ? 'avocado' : 'spices'),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      i == 1 ? 'Avocado' : 'Steak’s Spices',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    Text(
                                      i == 1 ? '\$14' : '\$5',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: reviews
          ? null
          : SafeArea(
              top: false,
              minimum: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: PrimaryButton(
                'Add to Cart',
                onPressed: () {
                  s.add(p.id);
                  go(context, 'cart');
                },
              ),
            ),
      floatingActionButton: reviews
          ? FloatingActionButton(
              backgroundColor: green,
              foregroundColor: Colors.white,
              onPressed: () => _rate(context),
              child: const Icon(Icons.edit),
            )
          : null,
    );
  }

  Widget _reviews(BuildContext context) => Column(
    children: [
      const Text(
        '4.0',
        style: TextStyle(fontSize: 64, fontWeight: FontWeight.w600),
      ),
      const Text(
        '★ ★ ★ ★ ☆',
        style: TextStyle(color: Color(0xFFFFA339), fontSize: 28),
      ),
      caption('147 reviews'),
      const SizedBox(height: 32),
      for (final r in [
        (
          'Jennie Doo',
          '1 day ago',
          'Super Fresh!',
          'This salmon has the perfect fat ratio to make it simply buttery and delicious. The velvety texture is divine and the taste is nothing short of magical.',
        ),
        (
          'Kim Catoo',
          '3 days ago',
          'High Quality',
          'Used it for a few months now and I am truly happy. The quality is always wonderful.',
        ),
      ])
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: mint,
                      child: Text(r.$1.substring(0, 1)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.$1,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          caption(r.$2),
                        ],
                      ),
                    ),
                    const BadgeLabel('4.0'),
                  ],
                ),
                const SizedBox(height: 18),
                heading('“${r.$3}”', size: 15),
                const SizedBox(height: 8),
                Text(r.$4, style: const TextStyle(fontSize: 12, height: 1.5)),
              ],
            ),
          ),
        ),
    ],
  );
  void _rate(BuildContext context) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Write a review'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'How was your order?'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              toast(context, 'Thank you! Your demo review has been recorded.');
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    ).then((_) => controller.dispose());
  }
}

class ScanPage extends StatefulWidget {
  final bool permission, carrot;
  const ScanPage({super.key, this.permission = false, this.carrot = false});
  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  bool flash = false;
  @override
  Widget build(BuildContext context) {
    if (widget.permission) {
      return PageLayout(
        title: '',
        bottom: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PrimaryButton(
              'Accept',
              onPressed: () => Navigator.pushReplacementNamed(context, '/scan'),
            ),
            TextButton(
              onPressed: () => home(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
        child: Column(
          children: [
            art('camera', height: 320),
            const SizedBox(height: 32),
            heading('Camera permissions', size: 24),
            const SizedBox(height: 12),
            const Text(
              'The barcode scanning feature\nrequires camera permissions',
              textAlign: TextAlign.center,
              style: TextStyle(color: muted),
            ),
            const SizedBox(height: 16),
            caption('Interactive scan preview • no live camera'),
          ],
        ),
      );
    }
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: art(
              widget.carrot ? 'scan_carrot' : 'scan_salmon',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  leading: IconButton(
                    tooltip: 'Back',
                    onPressed: () => Navigator.canPop(context)
                        ? Navigator.pop(context)
                        : home(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  actions: [
                    IconButton(
                      tooltip: 'Toggle flash preview',
                      onPressed: () => setState(() => flash = !flash),
                      icon: Icon(flash ? Icons.flash_on : Icons.flash_off),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Detecting...', style: TextStyle(color: green)),
                const SizedBox(height: 40),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: Center(child: Container(height: 3, color: green)),
                    ),
                  ),
                ),
                const SizedBox(height: 70),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: InkWell(
                    onTap: () {
                      AppScope.of(context).selectedProduct = widget.carrot
                          ? 'carrot'
                          : 'salmon';
                      go(context, 'product');
                    },
                    child: Panel(
                      color: Colors.white,
                      child: Row(
                        children: [
                          art(
                            widget.carrot ? 'carrot' : 'salmon',
                            width: 64,
                            height: 72,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                heading(
                                  widget.carrot
                                      ? 'Carrot Ecobi'
                                      : 'Salmon fillet',
                                  size: 18,
                                ),
                                Text(
                                  widget.carrot
                                      ? '\$2 / 1 kilogram'
                                      : '\$79 / 1 pieces',
                                  style: const TextStyle(color: green),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: muted),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
