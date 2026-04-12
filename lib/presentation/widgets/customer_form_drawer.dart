import 'package:flutter/material.dart';
import '../../domain/entities/customer_entity.dart';

class CustomerFormDrawer extends StatefulWidget {
  final CustomerEntity? editCustomer;
  final Function(CustomerEntity) onSave;

  const CustomerFormDrawer({
    super.key,
    this.editCustomer,
    required this.onSave,
  });

  @override
  State<CustomerFormDrawer> createState() => _CustomerFormDrawerState();
}

class _CustomerFormDrawerState extends State<CustomerFormDrawer> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _companyController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _postcodeController;
  String? _selectedCountry;

  @override
  void initState() {
    super.initState();
    final c = widget.editCustomer;
    _firstNameController = TextEditingController(text: c?.firstName);
    _lastNameController = TextEditingController(text: c?.lastName);
    _emailController = TextEditingController(text: c?.email);
    _phoneController = TextEditingController(text: c?.phone);
    _companyController = TextEditingController(text: c?.company);
    _addressController = TextEditingController(text: c?.address);
    _cityController = TextEditingController(text: c?.city);
    _stateController = TextEditingController(text: c?.state);
    _postcodeController = TextEditingController(text: c?.postcode);
    _selectedCountry = c?.country;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Personal Information",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              "First Name",
                              _firstNameController,
                              required: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              "Last Name",
                              _lastNameController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        "Email",
                        _emailController,
                        required: true,
                        isEmail: true,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField("Phone", _phoneController, required: true),
                      const SizedBox(height: 16),
                      _buildTextField("Company", _companyController),
                      const SizedBox(height: 32),
                      const Text(
                        "Address Details",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField("Address", _addressController),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField("City", _cityController),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField("State", _stateController),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              "Postcode",
                              _postcodeController,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(child: _buildCountryDropdown()),
                        ],
                      ),
                      const SizedBox(height: 48),
                      _buildSubmitButtons(context),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.editCustomer == null ? "Add New Customer" : "Edit Customer",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool required = false,
    bool isEmail = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      validator: (value) {
        if (required && (value == null || value.isEmpty))
          return "This field is required";
        if (isEmail && value != null && value.isNotEmpty) {
          final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
          if (!regex.hasMatch(value)) return "Enter a valid email address";
        }
        return null;
      },
    );
  }

  Widget _buildCountryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCountry,
      decoration: InputDecoration(
        labelText: "Country",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      items: const [
        DropdownMenuItem(value: 'Bangladesh', child: Text("Bangladesh")),
        DropdownMenuItem(value: 'USA', child: Text("USA")),
        DropdownMenuItem(value: 'UK', child: Text("UK")),
        DropdownMenuItem(value: 'Canada', child: Text("Canada")),
      ],
      onChanged: (val) => setState(() => _selectedCountry = val),
    );
  }

  Widget _buildSubmitButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 20),
            ),
            child: const Text("Cancel"),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 20),
            ),
            child: const Text("Save Customer"),
          ),
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final customer = CustomerEntity(
        id: widget.editCustomer?.id ?? 'new',
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        company: _companyController.text,
        address: _addressController.text,
        city: _cityController.text,
        state: _stateController.text,
        postcode: _postcodeController.text,
        country: _selectedCountry,
        createdFrom: widget.editCustomer?.createdFrom ?? 'manual',
        createdAt: widget.editCustomer?.createdAt ?? DateTime.now(),
      );
      widget.onSave(customer);
    }
  }
}
