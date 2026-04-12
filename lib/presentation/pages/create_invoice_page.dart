import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../core/injection.dart';
import '../../logic/invoice/invoice_bloc.dart';
import '../../logic/invoice/invoice_event.dart';
import '../../logic/invoice/invoice_state.dart';
import '../../logic/customer/customer_bloc.dart';
import '../../logic/customer/customer_event.dart';
import '../../logic/customer/customer_state.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/invoice_entity.dart';

class CreateInvoicePage extends StatelessWidget {
  const CreateInvoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              getIt<InvoiceBloc>()..add(InitializeNewInvoice()),
        ),
        BlocProvider(
          create: (context) =>
              getIt<CustomerBloc>()..add(const LoadCustomers()),
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text("Create New Invoice"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          actions: [
            BlocBuilder<InvoiceBloc, InvoiceState>(
              builder: (context, state) {
                if (state is InvoiceFormState) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: state.isSaving
                            ? null
                            : () => context.read<InvoiceBloc>().add(
                                SaveInvoice(),
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                        ),
                        child: state.isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text("Save Invoice"),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocListener<InvoiceBloc, InvoiceState>(
          listener: (context, state) {
            if (state is InvoiceSavedSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Invoice saved successfully!"),
                  backgroundColor: Colors.green,
                ),
              );
              context.pop(); // Go back to list
            }
            if (state is InvoiceError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildFormContent(context)),
                const SizedBox(width: 24),
                Expanded(flex: 1, child: _buildSummarySidebar(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent(BuildContext context) {
    return Column(
      children: [
        _buildHeaderSection(context),
        const SizedBox(height: 24),
        _buildItemsSection(context),
        const SizedBox(height: 24),
        _buildNotesSection(context),
      ],
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Invoice Details",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildCustomerDropdown(context)),
              const SizedBox(width: 16),
              Expanded(child: _buildDatePicker(context)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildCurrencyDropdown(context)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatusDropdown(context)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerDropdown(BuildContext context) {
    return BlocBuilder<CustomerBloc, CustomerState>(
      builder: (context, state) {
        List<CustomerEntity> customers = [];
        if (state is CustomerLoaded) customers = state.customers;

        return DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: "Bill To Customer",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          items: customers
              .map(
                (c) => DropdownMenuItem(value: c.id, child: Text(c.fullName)),
              )
              .toList(),
          onChanged: (val) => context.read<InvoiceBloc>().add(
            UpdateInvoiceHeader(customerId: val),
          ),
        );
      },
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return BlocBuilder<InvoiceBloc, InvoiceState>(
      builder: (context, state) {
        DateTime date = DateTime.now();
        if (state is InvoiceFormState) date = state.dueDate;

        return TextFormField(
          readOnly: true,
          decoration: InputDecoration(
            labelText: "Due Date",
            suffixIcon: const Icon(Icons.calendar_today),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          controller: TextEditingController(
            text: DateFormat('yyyy-MM-dd').format(date),
          ),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) {
              context.read<InvoiceBloc>().add(
                UpdateInvoiceHeader(dueDate: picked),
              );
            }
          },
        );
      },
    );
  }

  Widget _buildCurrencyDropdown(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: 'BDT',
      decoration: InputDecoration(
        labelText: "Currency",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: const [
        DropdownMenuItem(value: 'BDT', child: Text("BDT (৳)")),
        DropdownMenuItem(value: 'USD', child: Text("USD (\$)")),
      ],
      onChanged: (val) =>
          context.read<InvoiceBloc>().add(UpdateInvoiceHeader(currency: val)),
    );
  }

  Widget _buildStatusDropdown(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: 'unpaid',
      decoration: InputDecoration(
        labelText: "Initial Status",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: const [
        DropdownMenuItem(value: 'unpaid', child: Text("Unpaid")),
        DropdownMenuItem(value: 'paid', child: Text("Paid")),
        DropdownMenuItem(value: 'partial', child: Text("Partial")),
      ],
      onChanged: (val) =>
          context.read<InvoiceBloc>().add(UpdateInvoiceHeader(status: val)),
    );
  }

  Widget _buildItemsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Invoice Items",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: () =>
                    context.read<InvoiceBloc>().add(AddInvoiceItem()),
                icon: const Icon(Icons.add),
                label: const Text("Add Item"),
              ),
            ],
          ),
          const SizedBox(height: 16),
          BlocBuilder<InvoiceBloc, InvoiceState>(
            builder: (context, state) {
              if (state is InvoiceFormState) {
                return Column(
                  children: List.generate(state.items.length, (index) {
                    return _buildItemRow(context, index, state.items[index]);
                  }),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(
    BuildContext context,
    int index,
    InvoiceItemEntity item,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextFormField(
              decoration: const InputDecoration(
                hintText: "Description",
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => context.read<InvoiceBloc>().add(
                UpdateInvoiceItem(index: index, description: val),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 1,
            child: TextFormField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Qty",
                border: OutlineInputBorder(),
              ),
              initialValue: item.quantity.toString(),
              onChanged: (val) => context.read<InvoiceBloc>().add(
                UpdateInvoiceItem(
                  index: index,
                  quantity: int.tryParse(val) ?? 1,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: TextFormField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Price",
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => context.read<InvoiceBloc>().add(
                UpdateInvoiceItem(
                  index: index,
                  unitPrice: double.tryParse(val) ?? 0.0,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "৳${item.total}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () =>
                context.read<InvoiceBloc>().add(RemoveInvoiceItem(index)),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Notes & Shipping",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: "Shipping Charge",
              border: OutlineInputBorder(),
            ),
            onChanged: (val) => context.read<InvoiceBloc>().add(
              UpdateInvoiceHeader(shippingCharge: double.tryParse(val) ?? 0.0),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: "Private Notes",
              border: OutlineInputBorder(),
            ),
            onChanged: (val) => context.read<InvoiceBloc>().add(
              UpdateInvoiceHeader(notes: val),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySidebar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: BlocBuilder<InvoiceBloc, InvoiceState>(
        builder: (context, state) {
          if (state is InvoiceFormState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Invoice Summary",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                _buildSummaryRow("Subtotal", "৳${state.subtotal}"),
                _buildSummaryRow(
                  "Total Discount",
                  "-৳${state.totalDiscount}",
                  color: Colors.red,
                ),
                _buildSummaryRow("Total VAT", "৳${state.totalVat}"),
                _buildSummaryRow("Shipping", "৳${state.shippingCharge}"),
                const Divider(height: 32),
                _buildSummaryRow(
                  "Grand Total",
                  "৳${state.grandTotal}",
                  isBold: true,
                  fontSize: 18,
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    Color? color,
    bool isBold = false,
    double fontSize = 14,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey, fontSize: fontSize),
          ),
          Text(
            value,
            style: TextStyle(
              color: color ?? Colors.black,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
