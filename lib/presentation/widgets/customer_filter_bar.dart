import 'package:flutter/material.dart';
import '../../domain/repositories/payment_repository.dart';

class CustomerFilterBar extends StatelessWidget {
  final Function(String) onSearch;
  final Function(String?) onCityChanged;
  final Function(String?) onCountryChanged;
  final Function(PaymentDateRange?) onDateRangeChanged;

  const CustomerFilterBar({
    super.key,
    required this.onSearch,
    required this.onCityChanged,
    required this.onCountryChanged,
    required this.onDateRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 900;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: isMobile
          ? Column(
              children: [
                _buildSearchField(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildCityDropdown()),
                    const SizedBox(width: 12),
                    Expanded(child: _buildCountryDropdown()),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDatePicker(context),
              ],
            )
          : Row(
              children: [
                Expanded(flex: 3, child: _buildSearchField()),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: _buildCityDropdown()),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: _buildCountryDropdown()),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: _buildDatePicker(context)),
              ],
            ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      onChanged: onSearch,
      decoration: InputDecoration(
        hintText: "Search Name, Email, Phone...",
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  Widget _buildCityDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        hintText: "City",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      items: const [
        DropdownMenuItem(value: 'All', child: Text("All Cities")),
        DropdownMenuItem(value: 'Dhaka', child: Text("Dhaka")),
        DropdownMenuItem(value: 'Chittagong', child: Text("Chittagong")),
        DropdownMenuItem(value: 'Sylhet', child: Text("Sylhet")),
      ],
      onChanged: onCityChanged,
    );
  }

  Widget _buildCountryDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        hintText: "Country",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      items: const [
        DropdownMenuItem(value: 'All', child: Text("All Countries")),
        DropdownMenuItem(value: 'Bangladesh', child: Text("Bangladesh")),
        DropdownMenuItem(value: 'USA', child: Text("USA")),
        DropdownMenuItem(value: 'UK', child: Text("UK")),
      ],
      onChanged: onCountryChanged,
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          final range = await showDateRangePicker(
            context: context,
            firstDate: DateTime(2023),
            lastDate: DateTime.now(),
          );
          if (range != null) {
            onDateRangeChanged(
              PaymentDateRange(start: range.start, end: range.end),
            );
          } else {
            onDateRangeChanged(null);
          }
        },
        icon: const Icon(Icons.calendar_today, size: 18),
        label: const Text("Filter by Date"),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: BorderSide(color: Colors.grey.shade200),
        ),
      ),
    );
  }
}
