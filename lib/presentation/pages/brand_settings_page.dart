import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../logic/settings/settings_bloc.dart';
import '../../logic/settings/settings_event.dart';
import '../../logic/settings/settings_state.dart';
import '../../domain/entities/brand_entity.dart';
import '../../core/injection.dart';
import '../widgets/responsive.dart';

class BrandSettingsPage extends StatefulWidget {
  const BrandSettingsPage({super.key});

  @override
  State<BrandSettingsPage> createState() => _BrandSettingsPageState();
}

class _BrandSettingsPageState extends State<BrandSettingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedCurrency = 'BDT';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SettingsBloc>()..add(LoadSettings()),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          title: Text(
            "Settings",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: Responsive.isMobile(context) ? 20 : 22,
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: const [
              Tab(text: "General"),
              Tab(text: "Branding"),
              Tab(text: "Localization"),
              Tab(text: "Automation"),
            ],
          ),
        ),
        body: BlocConsumer<SettingsBloc, SettingsState>(
          listener: (context, state) {
            if (state is SettingsLoaded) {
              _nameController.text = state.brand.name;
              _emailController.text = state.brand.supportEmail ?? '';
              _phoneController.text = state.brand.supportPhone ?? '';
              _selectedCurrency = state.brand.defaultCurrency;
            }
          },
          builder: (context, state) {
            if (state is SettingsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is SettingsLoaded) {
              return TabBarView(
                controller: _tabController,
                children: [
                  _buildGeneralTab(context, state.brand),
                  _buildBrandingTab(context, state.brand, state.uploadProgress),
                  _buildLocalizationTab(context, state.brand),
                  const Center(child: Text("Automation settings coming soon")),
                ],
              );
            }
            if (state is SettingsError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildGeneralTab(BuildContext context, BrandEntity brand) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(Responsive.isMobile(context) ? 16 : 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              "Public Profile",
              "Manage your gateway identity and support contacts.",
              [
                _buildTextField("Site Name", _nameController, Icons.business),
                const SizedBox(height: 16),
                _buildTextField(
                  "Support Email",
                  _emailController,
                  Icons.email_outlined,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  "Support Phone",
                  _phoneController,
                  Icons.phone_android,
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              height: 45,
              child: ElevatedButton(
                onPressed: () => _handleUpdate(context, brand),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: const Text("Save Changes"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandingTab(
    BuildContext context,
    BrandEntity brand,
    double progress,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(Responsive.isMobile(context) ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            "Logo & Visuals",
            "This logo will appear on checkout pages and dashboards.",
            [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                        image: brand.logoUrl != null
                            ? DecorationImage(
                                image: NetworkImage(brand.logoUrl!),
                                fit: BoxFit.contain,
                              )
                            : null,
                      ),
                      child: brand.logoUrl == null
                          ? const Icon(
                              Icons.image,
                              size: 48,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    if (progress > 0 && progress < 1.0)
                      LinearProgressIndicator(value: progress),
                    TextButton.icon(
                      onPressed: () => _pickAndUpload(context),
                      icon: const Icon(Icons.upload),
                      label: const Text("Upload New Logo"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocalizationTab(BuildContext context, BrandEntity brand) {
    return Padding(
      padding: EdgeInsets.all(Responsive.isMobile(context) ? 16 : 24),
      child: _buildSection(
        "Currency & Region",
        "Set your default target currency for checkouts.",
        [
          DropdownButtonFormField<String>(
            value: _selectedCurrency,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Default Currency",
            ),
            items: [
              'BDT',
              'USD',
              'GBP',
              'EUR',
            ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedCurrency = val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String subtitle, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 20),
        ...children,
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: const OutlineInputBorder(),
      ),
    );
  }

  void _handleUpdate(BuildContext context, BrandEntity brand) {
    final updatedBrand = BrandEntity(
      id: brand.id,
      name: _nameController.text,
      slug: brand.slug,
      logoUrl: brand.logoUrl,
      defaultCurrency: _selectedCurrency,
      supportEmail: _emailController.text,
      supportPhone: _phoneController.text,
      settings: brand.settings,
    );
    context.read<SettingsBloc>().add(UpdateBrandInfo(updatedBrand));
  }

  Future<void> _pickAndUpload(BuildContext context) async {
    final result = await FilePicker.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      context.read<SettingsBloc>().add(
        UploadLogo(
          result.files.single.path!,
          "logo_${DateTime.now().millisecondsSinceEpoch}.png",
        ),
      );
    }
  }
}
