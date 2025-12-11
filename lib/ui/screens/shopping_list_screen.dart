import 'package:flutter/material.dart';

class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Minimal implementation inspired by Stitch prototype structure
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(bottom: 80),
        children: const [
          _SectionTitle('Suggested for You'),
          _HorizontalSuggestions(),
          _SectionTitle('Your List'),
          _CategoryCard(
            title: 'Produce',
            items: [
              _CheckItem(title: 'Apples', subtitle: '6 items', badge: 'Meal Plan'),
              _CheckItem(title: 'Avocado', subtitle: '2 items', badge: 'Low Stock'),
              _CheckItem(title: 'Bananas', subtitle: '1 bunch', checked: true),
            ],
          ),
          _CategoryCard(
            title: 'Dairy & Eggs',
            items: [
              _CheckItem(title: 'Eggs', subtitle: '1 dozen'),
              _CheckItem(title: 'Greek Yogurt', subtitle: '500g'),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
    );
  }
}

class _HorizontalSuggestions extends StatelessWidget {
  const _HorizontalSuggestions();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: const [
          _SuggestionCard(title: 'Milk', subtitle: 'Low Stock', imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDKdx0t9pAtBdvVIfHHJeE4u9KfyJfK5kC12sJHwGfXUH5eCyqzhqr8vUPMDNHRlXcshffIXdni4aB3IgWFg4L6R-JCi1XM8FcNYSK9SxLXD3fdil-nWVS8lImYcH_bCl_GODxj-zcxCtqxaf_C6_8yHh10musrL-EesF93x9qjV4LZEz-HCpSvhFu01qenCzO-YBh-8_NhjagMXtA23IzwQ5b1A5oJ39n40Dh__dUTn4Y6mrGhr5Y-Qk0qaxPN9ZIFfTCOAkUmyg'),
          SizedBox(width: 12),
          _SuggestionCard(title: 'Chicken', subtitle: 'For Lasagna', imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBJWSaG6bzHiuyLRlA2VHFyQOEDns9rZq9A9XcW_Gl0TWPctNoFb_sYM3Dv1nMzRVWp8Afkw0uVdZvEmtPGBWlW31f68MUSfjsIR_zlT_6Tz-V3S0cIXt1800qzFzDXye6llQSqQRz87JRDwKDNuyEXsBLZRM9fiGsC84erjCGYQg1TCrqDfMMQdC2OJT2qnZX02FGmRUaytr2scnraB5qnVPHfRL1Baf7nmv89qjwHOBzDtqS1a4TEJN22Z_uNjZXUHwWGsN01_g'),
          SizedBox(width: 12),
          _SuggestionCard(title: 'Carrots', subtitle: 'For Salad', imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCFDobD_WRJYV8Xy2lwXNY3THDOi76iT7GOvPA1mOTC7IQEM0SwoM0S2jjRkPdTFQkX3QD_JimAfdH_nLjJcXdaxz-9Mc2FCtU4YTjA7LXFFbn2YgzFu2dp9rzKRgZSnvXXtHMSMOcjMxGu-6uB2r51p4OtoglHeqd3Dhkh3EvyOLoLrIKceYL36V9zFGi9x2ZEZ_6uVsEwZB_8YHVFSQ-kI4ifz-gpQslPuK6oSSQzL2Wy9hSEj5HAHayGttuZrwo-S6CEeRK2Sw'),
        ],
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  const _SuggestionCard({required this.title, required this.subtitle, required this.imageUrl});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0,2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(imageUrl, height: 100, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('Add'),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(60, 32)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final List<_CheckItem> items;
  const _CategoryCard({required this.title, required this.items});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                child: Text(title.toUpperCase(), style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
              for (final item in items) const Divider(height: 1),
              for (final item in items) item,
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? badge;
  final bool checked;
  const _CheckItem({required this.title, this.subtitle, this.badge, this.checked = false});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Checkbox(value: checked, onChanged: (_) {}),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(decoration: checked ? TextDecoration.lineThrough : null, color: checked ? Colors.grey : null)),
                if (subtitle != null)
                  Text(subtitle!, style: TextStyle(fontSize: 12, color: checked ? Colors.grey : Colors.grey[600], decoration: checked ? TextDecoration.lineThrough : null)),
              ],
            ),
          ),
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(badge!, style: const TextStyle(fontSize: 11)),
            ),
        ],
      ),
    );
  }
}
