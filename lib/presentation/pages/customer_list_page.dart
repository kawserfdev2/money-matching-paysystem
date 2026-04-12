import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../core/injection.dart';
import '../../logic/customer/customer_bloc.dart';
import '../../logic/customer/customer_event.dart';
import '../../logic/customer/customer_state.dart';
import '../../domain/entities/customer_entity.dart';
import '../widgets/customer_filter_bar.dart';
import '../widgets/customer_insights_drawer.dart';
import '../widgets/customer_form_drawer.dart';
import '../widgets/responsive.dart';

class CustomerListPage extends StatelessWidget {
  const CustomerListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<CustomerBloc>()..add(const LoadCustomers()),
      child: Scaffold(
        body: BlocListener<CustomerBloc, CustomerState>(
          listener: (context, state) {
            if (state is CustomerActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            }
            if (state is CustomerError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: Builder(
            builder: (innerContext) {
              return Padding(
                padding: EdgeInsets.all(Responsive.isMobile(context) ? 16 : 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        Text(
                          "Customers",
                          style: TextStyle(
                            fontSize: Responsive.isMobile(context) ? 20 : 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _openCustomerForm(innerContext),
                          icon: const Icon(Icons.add),
                          label: const Text("New Customer"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Filter Bar
                    BlocBuilder<CustomerBloc, CustomerState>(
                      builder: (context, state) {
                        return CustomerFilterBar(
                          onSearch: (q) => context.read<CustomerBloc>().add(
                            SearchCustomers(q),
                          ),
                          onCityChanged: (c) => context
                              .read<CustomerBloc>()
                              .add(ApplyCustomerFilters(city: c)),
                          onCountryChanged: (cn) => context
                              .read<CustomerBloc>()
                              .add(ApplyCustomerFilters(country: cn)),
                          onDateRangeChanged: (r) => context
                              .read<CustomerBloc>()
                              .add(ApplyCustomerFilters(dateRange: r)),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Customer Table
                    Expanded(
                      child: Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                        ),
                        child: BlocBuilder<CustomerBloc, CustomerState>(
                          builder: (context, state) {
                            if (state is CustomerLoading && state.isFirstLoad) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (state is CustomerLoaded) {
                              return _buildTable(
                                innerContext,
                                state.customers,
                                state.hasReachedMax,
                              );
                            }

                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTable(
    BuildContext context,
    List<CustomerEntity> customers,
    bool hasReachedMax,
  ) {
    return DataTable2(
      columnSpacing: 12,
      horizontalMargin: 12,
      minWidth: 1000,
      headingRowColor: WidgetStateProperty.all(
        Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      columns: const [
        DataColumn2(label: Text('Customer'), size: ColumnSize.L),
        DataColumn2(label: Text('Company')),
        DataColumn2(label: Text('Email')),
        DataColumn2(label: Text('Phone'), size: ColumnSize.M),
        DataColumn2(label: Text('Location'), size: ColumnSize.M),
        DataColumn2(label: Text('Actions'), size: ColumnSize.S),
      ],
      rows: customers.map((customer) {
        return DataRow(
          cells: [
            DataCell(
              InkWell(
                onTap: () => _openCustomerInsights(context, customer),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      child: Text(
                        customer.firstName[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      customer.fullName,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            DataCell(Text(customer.company ?? "N/A")),
            DataCell(Text(customer.email)),
            DataCell(Text(customer.phone)),
            DataCell(
              Text("${customer.city ?? "-"}, ${customer.country ?? "-"}"),
            ),
            DataCell(
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => _openCustomerForm(context, customer),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      size: 20,
                      color: Colors.grey,
                    ),
                    onPressed: () => _confirmDelete(context, customer.id),
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  void _openCustomerInsights(BuildContext context, CustomerEntity customer) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Insights",
      pageBuilder: (context, _, __) {
        return Align(
          alignment: Alignment.centerRight,
          child: CustomerInsightsDrawer(customer: customer),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(
            begin: const Offset(1, 0),
            end: const Offset(0, 0),
          ).animate(anim1),
          child: child,
        );
      },
    );
  }

  void _openCustomerForm(BuildContext context, [CustomerEntity? customer]) {
    final customerBloc = context.read<CustomerBloc>();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Customer Form",
      pageBuilder: (context, _, __) {
        return Align(
          alignment: Alignment.centerRight,
          child: CustomerFormDrawer(
            editCustomer: customer,
            onSave: (newCustomer) {
              customerBloc.add(SaveCustomer(newCustomer));
              Navigator.pop(context);
            },
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(
            begin: const Offset(1, 0),
            end: const Offset(0, 0),
          ).animate(anim1),
          child: child,
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    final customerBloc = context.read<CustomerBloc>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Customer"),
        content: const Text(
          "Are you sure you want to remove this customer? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              customerBloc.add(DeleteCustomer(id));
              Navigator.pop(ctx);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
