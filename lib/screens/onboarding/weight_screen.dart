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

  static const double minWeight = 20.0;
  static const double maxWeight = 500.0;

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

  void _updateWeight(double newWeight) {
    final clamped = newWeight.clamp(minWeight, maxWeight);

    setState(() {
      _weight = clamped;
      _controller.text = _weight.toStringAsFixed(1);
    });
  }

  void _incrementWeight() => _updateWeight(_weight + 0.1);
  void _decrementWeight() => _updateWeight(_weight - 0.1);

  void _onChanged(String value) {
    if (value.isEmpty) return;

    final parsed = double.tryParse(value);
    if (parsed == null) return;

    setState(() {
      _weight = parsed.clamp(minWeight, maxWeight);
    });
  }

  void _applyFinalValidation() {
    final value = double.tryParse(_controller.text);

    if (value == null) {
      _controller.text = _weight.toStringAsFixed(1);
      return;
    }

    final corrected = value.clamp(minWeight, maxWeight);

    setState(() {
      _weight = corrected;
      _controller.text = corrected.toStringAsFixed(1);
    });
  }

  Widget _buildButton(IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        size: 28,
        color: const Color(0xFF5C5248),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: bottomInset + 12),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenHeight -
                  MediaQuery.of(context).padding.top -
                  kToolbarHeight,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.05),

                    Text(
                      'Введите ваш вес',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.literata(
                        fontSize: 26,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF5C5248),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    Text(
                      'от ${minWeight.toStringAsFixed(1)} до ${maxWeight.toStringAsFixed(1)} кг',
                      style: GoogleFonts.literata(
                        fontSize: 14,
                        color: const Color(0xFF999999),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.06),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F0F7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: _decrementWeight,
                              child: _buildButton(Icons.remove),
                            ),
                            const SizedBox(width: 14),
                            SizedBox(
                              width: 178,
                              child: TextField(
                                controller: _controller,
                                focusNode: _focusNode,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.literata(
                                  fontSize: 56,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF5C5248),
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: _onChanged,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d{0,3}(\.\d{0,1})?$'),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'кг',
                              style: GoogleFonts.literata(
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF5C5248),
                              ),
                            ),
                            const SizedBox(width: 14),
                            GestureDetector(
                              onTap: _incrementWeight,
                              child: _buildButton(Icons.add),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.04),

                    Expanded(
                      child: Center(
                        child: Image.asset(
                          'assets/images/weightguy.png',
                          width: 353,
                          height: 325,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Center(
                        child: SizedBox(
                          width: screenWidth * 0.88,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              _applyFinalValidation();

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HeightScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5C5248),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              'ГОТОВО',
                              style: GoogleFonts.roboto(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
