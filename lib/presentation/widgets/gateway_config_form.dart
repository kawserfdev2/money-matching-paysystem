import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../domain/entities/gateway_entity.dart';
import 'package:file_picker/file_picker.dart';

class GatewayConfigForm extends StatefulWidget {
  final String gatewayName;
  final GatewayEntity? initialData;
  final Function(
    Map<String, dynamic> generalData,
    Map<String, dynamic> configData,
    Uint8List? qrBytes,
  )
  onSave;

  const GatewayConfigForm({
    super.key,
    required this.gatewayName,
    this.initialData,
    required this.onSave,
  });

  @override
  State<GatewayConfigForm> createState() => _GatewayConfigFormState();
}

class _GatewayConfigFormState extends State<GatewayConfigForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  late TextEditingController _minAmountController;
  late TextEditingController _maxAmountController;
  late TextEditingController _fixedChargeController;
  late TextEditingController _percentChargeController;

  // Dynamic fields
  final Map<String, TextEditingController> _configControllers = {};
  Uint8List? _selectedQrBytes;
  String? _currentQrUrl;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(
      text: widget.initialData?.displayName,
    );
    _minAmountController = TextEditingController(
      text: widget.initialData?.minAmount.toString() ?? '10',
    );
    _maxAmountController = TextEditingController(
      text: widget.initialData?.maxAmount.toString() ?? '100000',
    );
    _fixedChargeController = TextEditingController(
      text: widget.initialData?.fixedCharge.toString() ?? '0',
    );
    _percentChargeController = TextEditingController(
      text: widget.initialData?.percentCharge.toString() ?? '0',
    );
    _currentQrUrl = widget.initialData?.qrCodeUrl;
    _setupDynamicFields();
  }

  void _setupDynamicFields() {
    final fields = _getFieldsForType(widget.gatewayName);
    for (var field in fields) {
      _configControllers[field] = TextEditingController(
        text: widget.initialData?.config[field]?.toString(),
      );
    }
  }

  List<String> _getFieldsForType(String type) {
    if (type.contains('personal')) {
      return ['Phone Number'];
    } else if (type.contains('api')) {
      return ['API Key', 'Secret Key'];
    }
    return [];
  }

  Future<void> _pickQrImage() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null && result.files.first.bytes != null) {
      setState(() {
        _selectedQrBytes = result.files.first.bytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "General Information",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildTextField("Display Name", _displayNameController),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  "Min Amount",
                  _minAmountController,
                  isNumber: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  "Max Amount",
                  _maxAmountController,
                  isNumber: true,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  "Fixed Charge",
                  _fixedChargeController,
                  isNumber: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  "Percentage Charge (%)",
                  _percentChargeController,
                  isNumber: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            "Gateway Configuration",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ..._configControllers.entries
              .map((e) => _buildTextField(e.key, e.value))
              .toList(),
          const SizedBox(height: 24),
          const Text(
            "Display QR Code",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildQrPicker(),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Save Gateway Configuration"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _buildQrPicker() {
    return InkWell(
      onTap: _pickQrImage,
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade300,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: _selectedQrBytes != null
            ? const Center(child: Text("Image Selected"))
            : _currentQrUrl != null
            ? Image.network(_currentQrUrl!)
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 32,
                    color: Colors.grey,
                  ),
                  Text(
                    "Click to upload QR Code",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final general = {
        'display_name': _displayNameController.text,
        'min_amount': double.parse(_minAmountController.text),
        'max_amount': double.parse(_maxAmountController.text),
        'fixed_charge': double.parse(_fixedChargeController.text),
        'percent_charge': double.parse(_percentChargeController.text),
      };

      final config = _configControllers.map(
        (key, value) => MapEntry(key, value.text),
      );

      widget.onSave(general, config, _selectedQrBytes);
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _minAmountController.dispose();
    _maxAmountController.dispose();
    _fixedChargeController.dispose();
    _percentChargeController.dispose();
    for (var controller in _configControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
