import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/checkout/checkout_bloc.dart';
import '../../logic/checkout/checkout_event.dart';
import '../../logic/checkout/checkout_state.dart';
import '../../core/injection.dart';

class PublicCheckoutPage extends StatefulWidget {
  final String slug;
  const PublicCheckoutPage({super.key, required this.slug});

  @override
  State<PublicCheckoutPage> createState() => _PublicCheckoutPageState();
}

class _PublicCheckoutPageState extends State<PublicCheckoutPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _trxController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BlocProvider(
      create: (context) =>
          getIt<CheckoutBloc>()..add(LoadCheckoutDetails(widget.slug)),
      child: Scaffold(
        backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        body: BlocConsumer<CheckoutBloc, CheckoutState>(
          listener: (context, state) {
            if (state is CheckoutSuccess) {
              _showSuccessDialog(
                context,
                state.transactionId,
                state.redirectUrl,
              );
            }
          },
          builder: (context, state) {
            if (state is CheckoutLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is CheckoutInvalid) {
              return Center(
                child: Text(
                  state.reason,
                  style: TextStyle(fontSize: 18, color: colorScheme.error),
                ),
              );
            }
            if (state is CheckoutLoaded) {
              final link = state.link;
              final isSandbox = link.isSandbox;

              return Center(
                child: SingleChildScrollView(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 500),
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                        ),
                      ],
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSandbox) _buildSandboxBanner(context),
                        const SizedBox(height: 24),
                        Icon(
                          Icons.lock_outline,
                          size: 48,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          link.productName,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${link.amount} ${link.currency}",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildTextField(
                          context,
                          "Full Name",
                          _nameController,
                          Icons.person_outline,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          context,
                          "Email Address",
                          _emailController,
                          Icons.mail_outline,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          context,
                          "Phone Number",
                          _phoneController,
                          Icons.phone_android,
                        ),
                        const SizedBox(height: 32),
                        if (isSandbox) ...[
                          Text(
                            "Sandbox Mode: Enter 'SANDBOX-123' to simulate",
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildTextField(
                            context,
                            "Test TrxID",
                            _trxController,
                            Icons.security,
                            hint: "SANDBOX-123",
                          ),
                          const SizedBox(height: 24),
                        ],
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              if (isSandbox &&
                                  _trxController.text != "SANDBOX-123") {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Invalid Testing TrxID"),
                                  ),
                                );
                                return;
                              }
                              context.read<CheckoutBloc>().add(
                                InitiateCheckoutPayment(
                                  customerEmail: _emailController.text,
                                  customerName: _nameController.text,
                                  customerPhone: _phoneController.text,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                            ),
                            child: Text(
                              state is CheckoutProcessing
                                  ? "Processing..."
                                  : "Pay Now",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildSandboxBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning_amber_rounded, size: 16, color: Colors.amber),
          SizedBox(width: 8),
          Text(
            "SANDBOX MODE",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.amber,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context,
    String label,
    TextEditingController controller,
    IconData icon, {
    String? hint,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, String txn, String? redirect) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Icon(Icons.check_circle, size: 64, color: Colors.green),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Payment Successful!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("TrxID: $txn"),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: const Text("Done"),
            ),
          ),
        ],
      ),
    );
  }
}
