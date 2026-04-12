import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:go_router/go_router.dart';
import '../../core/injection.dart';
import '../../logic/gateway/gateway_bloc.dart';
import '../../logic/gateway/gateway_event.dart';
import '../../logic/gateway/gateway_state.dart';
import '../../domain/entities/gateway_entity.dart';

class GatewayListPage extends StatelessWidget {
  const GatewayListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<GatewayBloc>()..add(LoadGateways()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 16,
                children: [
                  const Text(
                    "Payment Gateways",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/gateways/add'),
                    icon: const Icon(Icons.add),
                    label: const Text("Add New Gateway"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: BlocBuilder<GatewayBloc, GatewayState>(
                    builder: (context, state) {
                      if (state is GatewayLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is GatewayLoaded) {
                        return _buildTable(context, state.gateways);
                      }

                      if (state is GatewayError) {
                        return Center(child: Text("Error: ${state.message}"));
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTable(BuildContext context, List<GatewayEntity> gateways) {
    return DataTable2(
      columnSpacing: 12,
      horizontalMargin: 12,
      minWidth: 600,
      headingRowColor: MaterialStateProperty.all(const Color(0xFFF8FAFC)),
      columns: const [
        DataColumn2(label: Text('Gateway'), size: ColumnSize.L),
        DataColumn2(label: Text('Display Name')),
        DataColumn2(label: Text('Charges'), size: ColumnSize.M),
        DataColumn2(label: Text('Status'), size: ColumnSize.S),
        DataColumn2(label: Text('Actions'), size: ColumnSize.S),
      ],
      rows: gateways.map((gateway) {
        return DataRow(
          cells: [
            DataCell(
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue.shade50,
                    child: Text(gateway.name[0].toUpperCase()),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      gateway.name.replaceAll('_', ' ').toUpperCase(),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
            DataCell(
              Text(
                gateway.displayName,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            DataCell(
              Text("৳${gateway.fixedCharge} + ${gateway.percentCharge}%"),
            ),
            DataCell(
              Switch(
                materialTapTargetSize: MaterialTapTargetSize.padded,
                padding: EdgeInsets.zero,
                value: gateway.isActive,
                onChanged: (val) {
                  context.read<GatewayBloc>().add(
                    ToggleGatewayStatus(gateway.id, val),
                  );
                },
                activeColor: Colors.blue,
              ),
            ),
            DataCell(
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () =>
                          context.push('/gateways/edit', extra: gateway),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        size: 20,
                        color: Colors.grey,
                      ),
                      onPressed: () => _confirmDelete(context, gateway.id),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Gateway"),
        content: const Text("Are you sure you want to remove this gateway?"),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              context.read<GatewayBloc>().add(DeleteGateway(id));
              context.pop();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
