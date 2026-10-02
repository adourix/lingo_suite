import 'package:flutter/material.dart';
import '../../models/payment_data.dart';

class PaymentDialog extends StatefulWidget {
  final double total;
  final bool allowCredit;

  const PaymentDialog({
    super.key,
    required this.total,
    this.allowCredit = false,
  });

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentLine {
  PaymentMethod method;
  final TextEditingController controller;

  _PaymentLine(this.method, double amount)
      : controller = TextEditingController(text: amount.toStringAsFixed(2));

  void dispose() => controller.dispose();
}

class _PaymentDialogState extends State<PaymentDialog> {
  late List<_PaymentLine> lines;

  @override
  void initState() {
    super.initState();
    lines = [_PaymentLine(PaymentMethod.cash, widget.total)];
  }

  @override
  void dispose() {
    for (final line in lines) {
      line.dispose();
    }
    super.dispose();
  }

  double _amount(_PaymentLine line) =>
      double.tryParse(line.controller.text.trim()) ?? 0;

  double get _enteredTotal =>
      lines.fold<double>(0, (sum, line) => sum + _amount(line));

  void _addLine() {
    setState(() => lines.add(_PaymentLine(PaymentMethod.visa, 0)));
  }

  void _removeLine(int index) {
    if (lines.length == 1) return;
    setState(() {
      lines[index].dispose();
      lines.removeAt(index);
    });
  }

  void _confirm() {
    final values = <PaymentData>[];
    var remaining = widget.total;
    var change = 0.0;

    for (final line in lines) {
      final entered = _amount(line);
      if (entered <= 0) {
        _showError('Payment amounts must be greater than zero');
        return;
      }

      if (line.method == PaymentMethod.cash) {
        final applied = entered > remaining ? remaining : entered;
        change += entered - applied;
        if (applied > 0) {
          values.add(PaymentData(method: line.method, amount: applied));
          remaining -= applied;
        }
      } else {
        if (entered > remaining + 0.01) {
          _showError('Payment total cannot exceed invoice total');
          return;
        }
        values.add(PaymentData(method: line.method, amount: entered));
        remaining -= entered;
      }
    }

    if (remaining > 0.01) {
      _showError(
        'Remaining amount: ' + remaining.toStringAsFixed(2) + ' EGP',
      );
      return;
    }

    Navigator.pop(
      context,
      PaymentResult(payments: values, change: change),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Payment'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total: ' + widget.total.toStringAsFixed(2) + ' EGP'),
              const SizedBox(height: 16),
              ...List.generate(lines.length, (index) {
                final line = lines[index];
                final methods = PaymentMethod.values
                    .where((m) =>
                        widget.allowCredit ||
                        m != PaymentMethod.customerCredit)
                    .toList();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<PaymentMethod>(
                          initialValue: line.method,
                          decoration: const InputDecoration(
                            labelText: 'Method',
                            border: OutlineInputBorder(),
                          ),
                          items: methods.map((method) {
                            return DropdownMenuItem(
                              value: method,
                              child: Text(method.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => line.method = value);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: line.controller,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            labelText: line.method == PaymentMethod.cash
                                ? 'Cash received'
                                : 'Amount',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: lines.length == 1
                            ? null
                            : () => _removeLine(index),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                );
              }),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _addLine,
                  icon: const Icon(Icons.add),
                  label: const Text('Add payment'),
                ),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Entered'),
                  Text(_enteredTotal.toStringAsFixed(2) + ' EGP'),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _confirm,
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
