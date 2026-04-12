import 'package:flutter/material.dart';

class TransactionFilterBar extends StatelessWidget {
  final Function(String) onSearch;
  final Function(String?) onGatewayChanged;
  final Function(DateTimeRange?) onDateRangeChanged;

  const TransactionFilterBar({
    super.key,
    required this.onSearch,
    required this.onGatewayChanged,
    required this.onDateRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 700;

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: isMobile
          ? Column(
              children: [
                _buildSearchField(context),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildGatewayDropdown(context)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildDatePicker(context)),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                Expanded(flex: 3, child: _buildSearchField(context)),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: _buildGatewayDropdown(context)),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: _buildDatePicker(context)),
              ],
            ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return TextField(
      onChanged: onSearch,
      decoration: InputDecoration(
        hintText: "Search Email or TxID...",
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  Widget _buildGatewayDropdown(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        hintText: "Gateway",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      items: const [
        DropdownMenuItem(value: 'All', child: Text("All Gateways")),
        DropdownMenuItem(
          value: 'bkash_personal',
          child: Text("bKash Personal"),
        ),
        DropdownMenuItem(
          value: 'nagad_personal',
          child: Text("Nagad Personal"),
        ),
        DropdownMenuItem(value: 'stripe', child: Text("Stripe")),
      ],
      onChanged: onGatewayChanged,
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        final range = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2023),
          lastDate: DateTime.now(),
        );
        onDateRangeChanged(range);
      },
      icon: const Icon(Icons.calendar_today, size: 18),
      label: const Text("Date Range"),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
    );
  }
}
