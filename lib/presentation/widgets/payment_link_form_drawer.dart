import 'package:flutter/material.dart';
import '../../domain/entities/payment_link_entity.dart';

class PaymentLinkFormDrawer extends StatefulWidget {
  final Function(PaymentLinkEntity) onSave;

  const PaymentLinkFormDrawer({super.key, required this.onSave});

  @override
  State<PaymentLinkFormDrawer> createState() => _PaymentLinkFormDrawerState();
}

class _PaymentLinkFormDrawerState extends State<PaymentLinkFormDrawer> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _amountController = TextEditingController();
  final _redirectController = TextEditingController();
  String _currency = 'BDT';

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        color: Colors.white,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Create Payment Link",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Product Name *",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Amount *",
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      value: _currency,
                      decoration: const InputDecoration(
                        labelText: "Currency",
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'BDT', child: Text("BDT")),
                        DropdownMenuItem(value: 'USD', child: Text("USD")),
                      ],
                      onChanged: (v) => setState(() => _currency = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _redirectController,
                decoration: const InputDecoration(
                  labelText: "Redirect URL",
                  hintText: "https://myshop.com/success",
                  border: OutlineInputBorder(),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          widget.onSave(
                            PaymentLinkEntity(
                              id: '',
                              slug: '',
                              productName: _nameController.text,
                              description: _descController.text,
                              amount: double.parse(_amountController.text),
                              currency: _currency,
                              redirectUrl: _redirectController.text,
                              createdAt: DateTime.now(),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Create Link"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
