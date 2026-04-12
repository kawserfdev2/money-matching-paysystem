import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/injection.dart';
import '../../logic/gateway/gateway_bloc.dart';
import '../../logic/gateway/gateway_event.dart';
import '../../logic/gateway/gateway_state.dart';
import '../../domain/entities/gateway_entity.dart';
import '../widgets/gateway_config_form.dart';

class AddGatewayPage extends StatefulWidget {
  final GatewayEntity? editGateway;

  const AddGatewayPage({super.key, this.editGateway});

  @override
  State<AddGatewayPage> createState() => _AddGatewayPageState();
}

class _AddGatewayPageState extends State<AddGatewayPage> {
  String? _selectedMethod;

  final List<Map<String, String>> _availableMethods = [
    {'name': 'bkash_personal', 'display': 'bKash Personal', 'icon': '📱'},
    {'name': 'nagad_personal', 'display': 'Nagad Personal', 'icon': '📱'},
    {'name': 'bkash_api', 'display': 'bKash API (Merchant)', 'icon': '🛡️'},
    {'name': 'nagad_api', 'display': 'Nagad API', 'icon': '🛡️'},
   // {'name': 'stripe', 'display': 'Stripe', 'icon': '💳'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.editGateway != null) {
      _selectedMethod = widget.editGateway!.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<GatewayBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.editGateway != null ? "Edit Gateway" : "Add New Gateway",
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: BlocListener<GatewayBloc, GatewayState>(
          listener: (context, state) {
            if (state is GatewayActionSuccess) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
              context.pop();
            }
            if (state is GatewayError) {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_selectedMethod == null) ...[
                  const Text(
                    "Select Payment Method",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  _buildMethodGrid(),
                ] else ...[
                  _buildFormHeader(),
                  const SizedBox(height: 32),
                  _buildConfigForm(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMethodGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: _availableMethods.length,
      itemBuilder: (context, index) {
        final method = _availableMethods[index];
        return InkWell(
          onTap: () => setState(() => _selectedMethod = method['name']),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(method['icon']!, style: const TextStyle(fontSize: 40)),
                const SizedBox(height: 12),
                Text(
                  method['display']!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormHeader() {
    final method = _availableMethods.firstWhere(
      (m) => m['name'] == _selectedMethod,
    );
    return Row(
      children: [
        IconButton(
          onPressed: () => setState(() => _selectedMethod = null),
          icon: const Icon(Icons.arrow_back),
        ),
        const SizedBox(width: 8),
        Text(
          "Configuring ${method['display']}",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildConfigForm() {
    return BlocBuilder<GatewayBloc, GatewayState>(
      builder: (context, state) {
        return GatewayConfigForm(
          gatewayName: _selectedMethod!,
          initialData: widget.editGateway,
          onSave: (general, config, qrBytes) async {
            String? finalQrUrl = widget.editGateway?.qrCodeUrl;

            if (qrBytes != null) {
              // Trigger upload and wait
              context.read<GatewayBloc>().add(
                UploadQrCodeImage(qrBytes, "${_selectedMethod}_qr.png"),
              );
            }

            final gateway = GatewayEntity(
              id: widget.editGateway?.id ?? '',
              name: _selectedMethod!,
              displayName: general['display_name'],
              minAmount: general['min_amount'],
              maxAmount: general['max_amount'],
              fixedCharge: general['fixed_charge'],
              percentCharge: general['percent_charge'],
              config: config,
              qrCodeUrl: finalQrUrl,
              isActive: widget.editGateway?.isActive ?? true,
            );

            context.read<GatewayBloc>().add(SaveGateway(gateway));
          },
        );
      },
    );
  }
}
