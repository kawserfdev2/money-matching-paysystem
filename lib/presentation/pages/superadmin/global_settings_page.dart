import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/injection.dart';
import '../../../domain/entities/global_gateway_entity.dart';
import '../../../logic/superadmin/global_settings/global_settings_bloc.dart';
import '../../../logic/superadmin/global_settings/global_settings_event.dart';
import '../../../logic/superadmin/global_settings/global_settings_state.dart';

class GlobalSettingsPage extends StatelessWidget {
  const GlobalSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<GlobalSettingsBloc>()..add(LoadGlobalGateways()),
      child: const _GlobalSettingsView(),
    );
  }
}

class _GlobalSettingsView extends StatelessWidget {
  const _GlobalSettingsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Global Gateway Control',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Manage supported payment gateways platform-wide. Disabling a gateway updates the checkout page dynamically.',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: BlocListener<GlobalSettingsBloc, GlobalSettingsState>(
                listener: (context, state) {
                  debugPrint('🔔 [UI] GlobalSettingsState Update: $state');
                  if (state is GlobalSettingsError) {
                    debugPrint('❌ [UI] Error received: ${state.message}');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else if (state is GlobalGatewaysLoaded) {
                    debugPrint(
                      '📦 [UI] Gateways loaded: ${state.gateways.length} items',
                    );
                  }
                },
                child: BlocBuilder<GlobalSettingsBloc, GlobalSettingsState>(
                  builder: (context, state) {
                    if (state is GlobalSettingsLoading ||
                        state is GlobalSettingsInitial) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is GlobalSettingsError) {
                      return Center(
                        child: Text(
                          'Error: ${state.message}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    if (state is GlobalGatewaysLoaded) {
                      return GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 400,
                              crossAxisSpacing: 24,
                              mainAxisSpacing: 24,
                              childAspectRatio: 1.1,
                            ),
                        itemCount: state.gateways.length,
                        itemBuilder: (context, index) {
                          final gateway = state.gateways[index];
                          return _GatewayCard(
                            key: ValueKey(gateway.id),
                            gateway: gateway,
                          );
                        },
                      );
                    }

                    return const SizedBox();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GatewayCard extends StatefulWidget {
  final GlobalGatewayEntity gateway;

  const _GatewayCard({super.key, required this.gateway});

  @override
  State<_GatewayCard> createState() => _GatewayCardState();
}

class _GatewayCardState extends State<_GatewayCard> {
  late bool _isActive;
  late TextEditingController _msgController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _isActive = widget.gateway.isActive;
    _msgController = TextEditingController(
      text: widget.gateway.maintenanceMessage ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant _GatewayCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync with server state if it changed AND we are not currently saving
    if (oldWidget.gateway.isActive != widget.gateway.isActive ||
        oldWidget.gateway.maintenanceMessage !=
            widget.gateway.maintenanceMessage) {
      setState(() {
        _isActive = widget.gateway.isActive;
        _msgController.text = widget.gateway.maintenanceMessage ?? '';
      });
    }
  }

  void _onToggle(bool value) {
    debugPrint(
      '🔘 [UI] Switch Toggled: $value for ${widget.gateway.providerName}',
    );
    if (value) {
      debugPrint('🖱️ [UI] Enabing gateway ${widget.gateway.providerName}');
      // Direct enable on server
      context.read<GlobalSettingsBloc>().add(
        ToggleGatewayStatus(
          id: widget.gateway.id,
          isActive: true,
          onSuccess: () => debugPrint(
            '✅ [UI] Enable success for ${widget.gateway.providerName}',
          ),
          onError: (err) => debugPrint(
            '❌ [UI] Enable error for ${widget.gateway.providerName}: $err',
          ),
        ),
      );
    } else {
      debugPrint(
        '🖱️ [UI] Toggling OFF gateway ${widget.gateway.providerName} (Waiting for save)',
      );
      // Only local toggle off, wait for Save & Disable
      setState(() {
        _isActive = false;
      });
    }
  }

  void _saveDisable() {
    debugPrint(
      '🖱️ [UI] Saving & Disabling ${widget.gateway.providerName} with msg: ${_msgController.text}',
    );
    setState(() => _isSaving = true);
    context.read<GlobalSettingsBloc>().add(
      ToggleGatewayStatus(
        id: widget.gateway.id,
        isActive: false,
        maintenanceMessage: _msgController.text.trim().isNotEmpty
            ? _msgController.text.trim()
            : 'Currently disabled by platform administrator.',
        onSuccess: () {
          debugPrint('✅ [UI] Disable success');
          if (mounted) setState(() => _isSaving = false);
        },
        onError: (err) {
          debugPrint('❌ [UI] Disable error: $err');
          if (mounted) setState(() => _isSaving = false);
        },
      ),
    );
  }

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // pendingSave: user manually toggled off local state, but server is still active
    final bool pendingSave = !_isActive && widget.gateway.isActive;
    // globallyDisabled: both local and server state are false
    final bool globallyDisabled = !_isActive && !widget.gateway.isActive;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.gateway.isActive
              ? const Color(0xFFE2E8F0)
              : Colors.red.withOpacity(0.3),
          width: widget.gateway.isActive ? 1 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.network(
                  widget.gateway.logoUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (ctx, _, __) =>
                      const Icon(Icons.payment, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.gateway.providerName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.gateway.isActive
                          ? 'Active and Running'
                          : 'Disabled (Under Maintenance)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: widget.gateway.isActive
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isActive,
                activeColor: Colors.green,
                onChanged: _isSaving ? null : _onToggle,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!_isActive) ...[
            const Divider(),
            const SizedBox(height: 8),
            TextField(
              controller: _msgController,
              enabled: !_isSaving,
              onChanged: (v) {
                debugPrint(
                  '✏️ [UI] Maintenance msg changed for ${widget.gateway.providerName}: $v',
                );
                setState(
                  () {},
                ); // Rebuild to show/hide save button if msg changed
              },
              decoration: const InputDecoration(
                labelText: 'Maintenance Message',
                isDense: true,
                border: OutlineInputBorder(),
                hintText: 'Reason for disabling...',
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 12),
            if (pendingSave ||
                (globallyDisabled &&
                    _msgController.text !=
                        (widget.gateway.maintenanceMessage ?? '')))
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  onPressed: _isSaving ? null : _saveDisable,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save, size: 16),
                  label: Text(_isSaving ? 'Saving...' : 'Save & Disable'),
                ),
              )
            else if (globallyDisabled)
              const Text(
                'Changes saved successfully.',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ] else ...[
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Available Platform-wide',
                    style: TextStyle(color: Colors.green, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
