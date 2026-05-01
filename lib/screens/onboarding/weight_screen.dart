import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'height_screen.dart';

class WeightScreen extends StatefulWidget {
  const WeightScreen({super.key});

  @override
  State<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> {
  double _weight = 70.0;

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  static const double minWeight = 30.0;
  static const double maxWeight = 170.0;

  @override
  void initState() {
    super.initState();
    _controller.text = _weight.toStringAsFixed(1);

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _applyFinalValidation();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Обновление веса через кнопки
  void _updateWeight(double newWeight) {
    final clamped = newWeight.clamp(minWeight, maxWeight);

    setState(() {
      _weight = clamped;
      _controller.text = _weight.toStringAsFixed(1);
    });
  }

  void _incrementWeight() => _updateWeight(_weight + 0.1);
  void _decrementWeight() => _updateWeight(_weight - 0.1);

  // Во время ввода — НЕ трогаем текст
  void _onChanged(String value) {
    if (value.isEmpty) return;

    final parsed = double.tryParse(value);
    if (parsed == null) return;

    setState(() {
      _weight = parsed.clamp(minWeight, maxWeight);
    });
  }

  // Финальная валидация при потере фокуса
  void _applyFinalValidation() {
    final value = double.tryParse(_controller.text);

    if (value == null) {
      _controller.text = _weight.toStringAsFixed(1);
      return;
    }

    if (value > maxWeight) {
      _showWarningToast('Вес не может превышать $maxWeight кг');
    } else if (value < minWeight) {
      _showWarningToast('Вес не может быть меньше $minWeight кг');
    }

    final corrected = value.clamp(minWeight, maxWeight);

    setState(() {
      _weight = corrected;
      _controller.text = corrected.toStringAsFixed(1);
    });
  }

  void _showWarningToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5C5248)),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.05),

              Text(
                'Введите ваш вес',
                style: GoogleFonts.robotoMono(
                  fontSize: 26,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF5C5248),
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              Text(
                'от $minWeight до $maxWeight кг',
                style: GoogleFonts.robotoMono(
                  fontSize: 14,
                  color: const Color(0xFF999999),
                ),
              ),

              SizedBox(height: screenHeight * 0.06),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F0F7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _decrementWeight,
                      child: _buildButton(Icons.remove),
                    ),

                    const SizedBox(width: 16),

                    SizedBox(
                      width: 140,
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.robotoMono(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF5C5248),
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                        onChanged: _onChanged,
                        inputFormatters: [
                           FilteringTextInputFormatter.allow(
                            RegExp(r'^\d{0,3}(\.\d{0,1})?'),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    Text(
                      'кг',
                      style: GoogleFonts.robotoMono(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF5C5248),
                      ),
                    ),

                    const SizedBox(width: 16),

                    GestureDetector(
                      onTap: _incrementWeight,
                      child: _buildButton(Icons.add),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              Image.asset(
                'assets/images/weightguy.png',
                width: 353,
                height: 325,
              ),

              SizedBox(height: screenHeight * 0.02),

              ElevatedButton(
                onPressed: () {
                  _applyFinalValidation();

                  if (_weight >= minWeight && _weight <= maxWeight) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HeightScreen(),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5C5248),
                  foregroundColor: Colors.white, // 👈 БЕЛЫЙ текст
                  fixedSize: const Size(200, 50),
                ),
                child: Text(
                  'ГОТОВО',
                  style: GoogleFonts.robotoMono(fontSize: 21),
                ),
              ),

              SizedBox(height: screenHeight * 0.03),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 28, color: const Color(0xFF5C5248)),
    );
  }
}