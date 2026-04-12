import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/injection.dart';
import '../../logic/developer/developer_bloc.dart';
import '../../logic/developer/developer_event.dart';
import '../../logic/developer/developer_state.dart';

class DeveloperSettingsPage extends StatefulWidget {
  const DeveloperSettingsPage({super.key});

  @override
  State<DeveloperSettingsPage> createState() => _DeveloperSettingsPageState();
}

class _DeveloperSettingsPageState extends State<DeveloperSettingsPage> {
  bool _showSecret = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<DeveloperBloc>()..add(const InitializeDeveloperTools()),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocConsumer<DeveloperBloc, DeveloperState>(
          listener: (context, state) {
            if (state is DeveloperError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is DeveloperLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DeveloperKeysLoaded) {
              final keys = state.keys;
              final brandId = state.brandId ?? "";
              return SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Developer Settings",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Manage your API keys and configure your checkout environment.",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 32),

                    _buildSandboxToggle(
                      context,
                      keys?.isSandbox ?? true,
                      brandId,
                    ),
                    const SizedBox(height: 32),

                    _buildApiKeySection(context, keys, brandId),
                    const SizedBox(height: 48),

                    _buildDocumentationSnippet(),
                  ],
                ),
              );
            }

            return const Center(child: Text("Initializing developer tools..."));
          },
        ),
      ),
    );
  }

  Widget _buildSandboxToggle(
    BuildContext context,
    bool isSandbox,
    String brandId,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isSandbox
            ? Colors.amber.withOpacity(0.05)
            : Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSandbox ? Colors.amber.shade200 : Colors.green.shade200,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSandbox ? "Sandbox Mode Enabled" : "Live Mode Enabled",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isSandbox
                        ? Colors.amber.shade900
                        : Colors.green.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "When enabled, all transactions will be simulated and no real money will be charged.",
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
          Switch(
            value: isSandbox,
            activeColor: Colors.amber.shade900,
            onChanged: (val) {
              context.read<DeveloperBloc>().add(
                ToggleSandboxMode(brandId, val),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildApiKeySection(
    BuildContext context,
    dynamic keys,
    String brandId,
  ) {
    if (keys == null) {
      return Center(
        child: Column(
          children: [
            const Icon(Icons.vpn_key_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text("No API keys generated yet."),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<DeveloperBloc>().add(GenerateApiKeys(brandId));
              },
              child: const Text("Generate New Keys"),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "API Credentials",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () => _confirmRegenerate(context, brandId),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text("Regenerate Keys"),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildKeyField("Public Key", keys.publicKey),
        const SizedBox(height: 16),
        _buildKeyField("Secret Key", keys.secretKey, isSecret: true),
      ],
    );
  }

  Widget _buildKeyField(String label, String value, {bool isSecret = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  isSecret && !_showSecret ? "sk_••••_••••••••••••••••" : value,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
                ),
              ),
              if (isSecret)
                IconButton(
                  onPressed: () => setState(() => _showSecret = !_showSecret),
                  icon: Icon(
                    _showSecret ? Icons.visibility_off : Icons.visibility,
                    size: 20,
                  ),
                ),
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Copied to clipboard!")),
                  );
                },
                icon: const Icon(Icons.copy, size: 20),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmRegenerate(BuildContext context, String brandId) {
    showDialog(
      context: context,
      builder: (dContext) => AlertDialog(
        title: const Text("Regenerate Keys?"),
        content: const Text(
          "Your current keys will stop working immediately. This cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dContext),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              context.read<DeveloperBloc>().add(GenerateApiKeys(brandId));
              Navigator.pop(dContext);
            },
            child: const Text("Regenerate"),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentationSnippet() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Quick Integration",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "// Initiate a payment via API",
                style: TextStyle(color: Colors.green, fontSize: 13),
              ),
              SizedBox(height: 8),
              Text(
                "curl -X POST https://your-project.supabase.co/functions/v1/initiate-payment \\\n  -H \"Authorization: Bearer YOUR_SECRET_KEY\" \\\n  -d '{\n    \"amount\": 500,\n    \"currency\": \"BDT\",\n    \"customer_email\": \"customer@example.com\",\n    \"success_url\": \"https://your-site.com/success\",\n    \"cancel_url\": \"https://your-site.com/cancel\"\n  }'",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'monospace',
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
