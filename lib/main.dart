import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() {
  runApp(const JewelCalcApp());
}

class JewelCalcApp extends StatelessWidget {
  const JewelCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jewel Calc',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      home: const JewelCalcHome(),
    );
  }
}

class JewelCalcHome extends StatefulWidget {
  const JewelCalcHome({super.key});

  @override
  State<JewelCalcHome> createState() => _JewelCalcHomeState();
}

class _JewelCalcHomeState extends State<JewelCalcHome> {
  // Base values
  Map<String, double> metalRates = {
    'Gold 22K/916': 0.0,
    'Gold 20K/833': 0.0,
    'Gold 18K/750': 0.0,
    'Silver': 0.0,
  };
  
  double goldWastagePercentage = 0.0;
  double silverWastagePercentage = 0.0;
  double goldMcPerGm = 0.0;
  double silverMcPerGm = 0.0;
  
  // Form fields
  final TextEditingController billNumberController = TextEditingController();
  final TextEditingController customerAccController = TextEditingController();
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController wastageController = TextEditingController();
  final TextEditingController makingChargesController = TextEditingController();
  
  // Settings dialog controllers
  final Map<String, TextEditingController> metalRateControllers = {};
  late final TextEditingController goldWastageController;
  late final TextEditingController silverWastageController;
  late final TextEditingController goldMcController;
  late final TextEditingController silverMcController;
  
  String selectedType = 'Gold 22K/916';
  double weightGm = 0.0;
  double wastageGm = 0.0;
  double makingCharges = 0.0;
  String mcType = 'Rupees';
  double mcPercentage = 0.0;
  String discountType = 'None';
  double discountAmount = 0.0;
  double discountPercentage = 0.0;

  @override
  void initState() {
    super.initState();
    // Initialize settings dialog controllers
    for (var type in metalRates.keys) {
      metalRateControllers[type] = TextEditingController();
    }
    goldWastageController = TextEditingController();
    silverWastageController = TextEditingController();
    goldMcController = TextEditingController();
    silverMcController = TextEditingController();
    _loadBaseValues();
  }

  Future<void> _loadBaseValues() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final lastDate = prefs.getString('last_date') ?? '';

    // Reset if new day
    if (lastDate != today) {
      await _resetToDefaults();
      return;
    }

    setState(() {
      metalRates['Gold 22K/916'] = prefs.getDouble('rate_gold_22k') ?? 0.0;
      metalRates['Gold 20K/833'] = prefs.getDouble('rate_gold_20k') ?? 0.0;
      metalRates['Gold 18K/750'] = prefs.getDouble('rate_gold_18k') ?? 0.0;
      metalRates['Silver'] = prefs.getDouble('rate_silver') ?? 0.0;
      goldWastagePercentage = prefs.getDouble('gold_wastage') ?? 0.0;
      silverWastagePercentage = prefs.getDouble('silver_wastage') ?? 0.0;
      goldMcPerGm = prefs.getDouble('gold_mc') ?? 0.0;
      silverMcPerGm = prefs.getDouble('silver_mc') ?? 0.0;
      
      // Update controllers with loaded values
      _updateSettingsControllers();
    });
  }
  
  void _updateSettingsControllers() {
    for (var entry in metalRates.entries) {
      metalRateControllers[entry.key]!.text = entry.value.toString();
    }
    goldWastageController.text = goldWastagePercentage.toString();
    silverWastageController.text = silverWastagePercentage.toString();
    goldMcController.text = goldMcPerGm.toString();
    silverMcController.text = silverMcPerGm.toString();
  }

  Future<void> _saveBaseValues() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    await prefs.setString('last_date', today);
    await prefs.setDouble('rate_gold_22k', metalRates['Gold 22K/916']!);
    await prefs.setDouble('rate_gold_20k', metalRates['Gold 20K/833']!);
    await prefs.setDouble('rate_gold_18k', metalRates['Gold 18K/750']!);
    await prefs.setDouble('rate_silver', metalRates['Silver']!);
    await prefs.setDouble('gold_wastage', goldWastagePercentage);
    await prefs.setDouble('silver_wastage', silverWastagePercentage);
    await prefs.setDouble('gold_mc', goldMcPerGm);
    await prefs.setDouble('silver_mc', silverMcPerGm);
  }

  Future<void> _resetToDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    setState(() {
      metalRates = {
        'Gold 22K/916': 0.0,
        'Gold 20K/833': 0.0,
        'Gold 18K/750': 0.0,
        'Silver': 0.0,
      };
      goldWastagePercentage = 0.0;
      silverWastagePercentage = 0.0;
      goldMcPerGm = 0.0;
      silverMcPerGm = 0.0;
      
      // Reset controllers
      for (var controller in metalRateControllers.values) {
        controller.text = '0';
      }
      goldWastageController.text = '0';
      silverWastageController.text = '0';
      goldMcController.text = '0';
      silverMcController.text = '0';
    });

    await prefs.setString('last_date', today);
    await prefs.setDouble('rate_gold_22k', 0.0);
    await prefs.setDouble('rate_gold_20k', 0.0);
    await prefs.setDouble('rate_gold_18k', 0.0);
    await prefs.setDouble('rate_silver', 0.0);
    await prefs.setDouble('gold_wastage', 0.0);
    await prefs.setDouble('silver_wastage', 0.0);
    await prefs.setDouble('gold_mc', 0.0);
    await prefs.setDouble('silver_mc', 0.0);
  }

  void _resetAllInputs() {
    setState(() {
      billNumberController.clear();
      customerAccController.clear();
      customerNameController.clear();
      addressController.clear();
      mobileNumberController.clear();
      weightController.clear();
      wastageController.clear();
      makingChargesController.clear();
      weightGm = 0.0;
      wastageGm = 0.0;
      makingCharges = 0.0;
      mcPercentage = 0.0;
      discountAmount = 0.0;
      discountPercentage = 0.0;
      discountType = 'None';
    });
  }

  double get netWeightGm => weightGm + wastageGm;
  
  double get ratePerGram => metalRates[selectedType] ?? 0.0;
  
  double get jAmount => netWeightGm * ratePerGram;
  
  bool get isGold => selectedType.contains('Gold');
  
  double get minMakingCharge => isGold ? 250.0 : 200.0;

  double _calculateMakingCharges() {
    if (mcType == 'Rupees') {
      final mcPerGram = isGold ? goldMcPerGm : silverMcPerGm;
      final calculated = mcPerGram * weightGm;
      return calculated > minMakingCharge ? calculated : minMakingCharge;
    } else {
      final calculated = jAmount * (mcPercentage / 100);
      return calculated > minMakingCharge ? calculated : minMakingCharge;
    }
  }

  double get amountBeforeGst => jAmount + makingCharges;

  double get actualDiscountAmount {
    if (discountType == 'Rupees') {
      return discountAmount;
    } else if (discountType == 'Percentage') {
      return amountBeforeGst * (discountPercentage / 100);
    }
    return 0.0;
  }

  double get amountAfterDiscount => amountBeforeGst - actualDiscountAmount;

  double get cgstAmount => amountAfterDiscount * 0.015;

  double get sgstAmount => amountAfterDiscount * 0.015;

  double get finalAmount => amountAfterDiscount + cgstAmount + sgstAmount;

  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(80 * PdfPageFormat.mm, double.infinity),
        build: (context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(10),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
              pw.Center(
                child: pw.Text('ESTIMATE',
                    style: pw.TextStyle(
                        fontSize: 14, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 5),
              pw.Center(
                child: pw.Text(
                    DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now()),
                    style: const pw.TextStyle(fontSize: 10)),
              ),
              pw.Divider(),
              if (billNumberController.text.isNotEmpty)
                pw.Text('Bill No: ${billNumberController.text}'),
              if (customerAccController.text.isNotEmpty)
                pw.Text('Acc No: ${customerAccController.text}'),
              if (customerNameController.text.isNotEmpty)
                pw.Text('Name: ${customerNameController.text}'),
              if (addressController.text.isNotEmpty)
                pw.Text('Address: ${addressController.text}'),
              if (mobileNumberController.text.isNotEmpty)
                pw.Text('Mobile: ${mobileNumberController.text}'),
              pw.Divider(),
              pw.Text('ITEM DETAILS',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('Type: $selectedType'),
              pw.Text('Rate: Rs.$ratePerGram/gm'),
              pw.Text('Weight: ${weightGm.toStringAsFixed(3)} gm'),
              pw.Text('Wastage: ${wastageGm.toStringAsFixed(3)} gm'),
              pw.Text('Net Weight: ${netWeightGm.toStringAsFixed(3)} gm',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Divider(),
              pw.Text('AMOUNT CALCULATION',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('J Amount:'),
                  pw.Text('Rs.${jAmount.round()}'),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Making Charges:'),
                  pw.Text('Rs.${makingCharges.toStringAsFixed(2)}'),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Amount:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('Rs.${amountBeforeGst.round()}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
              if (actualDiscountAmount > 0) ...[
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Discount:'),
                    pw.Text('Rs.${actualDiscountAmount.toStringAsFixed(2)}'),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('After Discount:',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('Rs.${amountAfterDiscount.toStringAsFixed(2)}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('CGST 1.5%:'),
                  pw.Text('Rs.${cgstAmount.toStringAsFixed(2)}'),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('SGST 1.5%:'),
                  pw.Text('Rs.${sgstAmount.toStringAsFixed(2)}'),
                ],
              ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total Amount:',
                      style: pw.TextStyle(
                          fontSize: 13, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Rs.${finalAmount.round()}',
                      style: pw.TextStyle(
                          fontSize: 13, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ],
          ),
        );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('💎 Jewel Calc 💎'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetAllInputs,
            tooltip: 'Reset All',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now()),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            _buildCustomerInfoSection(),
            const SizedBox(height: 16),
            _buildItemCalculationSection(),
            const SizedBox(height: 16),
            _buildAmountCalculationSection(),
            const SizedBox(height: 16),
            _buildDiscountSection(),
            const SizedBox(height: 16),
            _buildGstSection(),
            const SizedBox(height: 16),
            _buildFinalAmountSection(),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _generatePdf,
                icon: const Icon(Icons.print),
                label: const Text('Print'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfoSection() {
    return Card(
      child: ExpansionTile(
        title: const Text('Customer Information'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: billNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Bill Number',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: customerAccController,
                  decoration: const InputDecoration(
                    labelText: 'Customer Acc Number',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: customerNameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: mobileNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Mobile Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCalculationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Item Calculation',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedType,
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
              items: metalRates.keys.map((String type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedType = value!;
                  wastageGm = weightGm *
                      (isGold ? goldWastagePercentage : silverWastagePercentage) /
                      100;
                  makingCharges = _calculateMakingCharges();
                });
              },
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '📌 Current Rate: ₹${ratePerGram.toStringAsFixed(2)} per gram',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: weightController,
                    decoration: const InputDecoration(
                      labelText: 'Weight (gm)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        weightGm = double.tryParse(value) ?? 0.0;
                        wastageGm = weightGm *
                            (isGold
                                ? goldWastagePercentage
                                : silverWastagePercentage) /
                            100;
                        makingCharges = _calculateMakingCharges();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: wastageController,
                    decoration: InputDecoration(
                      labelText: 'Wastage (gm)',
                      border: const OutlineInputBorder(),
                      hintText: wastageGm.toStringAsFixed(3),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        wastageGm = double.tryParse(value) ?? 0.0;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Net Weight: ${netWeightGm.toStringAsFixed(3)} gm',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCalculationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amount Calculation',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('J Amount:'),
                Text('₹${jAmount.round()}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(),
            Text(
              'Making Charges',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Rupees', label: Text('Rupees (₹)')),
                ButtonSegment(value: 'Percentage', label: Text('Percentage (%)')),
              ],
              selected: {mcType},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  mcType = newSelection.first;
                  makingCharges = _calculateMakingCharges();
                });
              },
            ),
            const SizedBox(height: 12),
            if (mcType == 'Rupees')
              TextField(
                controller: makingChargesController,
                decoration: InputDecoration(
                  labelText: 'Making Charges (₹)',
                  border: const OutlineInputBorder(),
                  hintText: makingCharges.toStringAsFixed(2),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    makingCharges = double.tryParse(value) ?? minMakingCharge;
                    if (makingCharges < minMakingCharge) {
                      makingCharges = minMakingCharge;
                    }
                  });
                },
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Making Charge Percentage (%)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        mcPercentage = double.tryParse(value) ?? 0.0;
                        makingCharges = _calculateMakingCharges();
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Making Charges: ₹${makingCharges.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Amount:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('₹${amountBeforeGst.round()}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscountSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Discount',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'None', label: Text('None')),
                ButtonSegment(value: 'Rupees', label: Text('Rupees (₹)')),
                ButtonSegment(value: 'Percentage', label: Text('Percentage (%)')),
              ],
              selected: {discountType},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  discountType = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 12),
            if (discountType == 'Rupees')
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Discount Amount (₹)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    discountAmount = double.tryParse(value) ?? 0.0;
                  });
                },
              )
            else if (discountType == 'Percentage')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Discount Percentage (%)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        discountPercentage = double.tryParse(value) ?? 0.0;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Discount Amount: ₹${actualDiscountAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            if (actualDiscountAmount > 0) ...[
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Amount After Discount:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('₹${amountAfterDiscount.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGstSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('CGST 1.5%:'),
                Text('₹${cgstAmount.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('SGST 1.5%:'),
                Text('₹${sgstAmount.toStringAsFixed(2)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinalAmountSection() {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('💰 Amount Incl. GST:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('₹${finalAmount.round()}',
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green)),
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog() {
    // Update controllers with current values before showing dialog
    _updateSettingsControllers();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚙️ Base Values Configuration'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Metal Rates (₹ per gram)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...metalRates.keys.map((type) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: '$type Rate',
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      controller: metalRateControllers[type],
                      onChanged: (value) {
                        metalRates[type] = double.tryParse(value) ?? 0.0;
                      },
                    ),
                  )),
              const Divider(),
              const Text('Wastage Settings',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Gold Wastage (%)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                controller: goldWastageController,
                onChanged: (value) {
                  goldWastagePercentage = double.tryParse(value) ?? 0.0;
                },
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Silver Wastage (%)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                controller: silverWastageController,
                onChanged: (value) {
                  silverWastagePercentage = double.tryParse(value) ?? 0.0;
                },
              ),
              const Divider(),
              const Text('Making Charges',
                  key: Key('settings_making_charges'),
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Gold MC (₹ per gram)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                controller: goldMcController,
                onChanged: (value) {
                  goldMcPerGm = double.tryParse(value) ?? 0.0;
                },
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Silver MC (₹ per gram)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                controller: silverMcController,
                onChanged: (value) {
                  silverMcPerGm = double.tryParse(value) ?? 0.0;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await _resetToDefaults();
              setState(() {});
            },
            child: const Text('Reset to Defaults'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _saveBaseValues();
              Navigator.of(context).pop();
              setState(() {});
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    billNumberController.dispose();
    customerAccController.dispose();
    customerNameController.dispose();
    addressController.dispose();
    mobileNumberController.dispose();
    weightController.dispose();
    wastageController.dispose();
    makingChargesController.dispose();
    for (var controller in metalRateControllers.values) {
      controller.dispose();
    }
    goldWastageController.dispose();
    silverWastageController.dispose();
    goldMcController.dispose();
    silverMcController.dispose();
    super.dispose();
  }
}
