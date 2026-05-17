import 'package:flutter/material.dart';
import 'package:dr_apple/theme/app_fonts.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/user_data_provider.dart';
import 'activity_level_screen.dart';

class AgeScreen extends StatefulWidget {
  const AgeScreen({super.key});

  @override
  State<AgeScreen> createState() => _AgeScreenState();
}

class _AgeScreenState extends State<AgeScreen> {
  double _age = 25.0;

  static const double minAge = 10.0;
  static const double maxAge = 120.0;

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.text = _age.toStringAsFixed(0);

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

  void _updateAge(double value) {
    final clamped = value.clamp(minAge, maxAge);

    setState(() {
      _age = clamped;
      _controller.text = _age.toStringAsFixed(0);
    });
  }

  void _onChanged(String value) {
    if (value.isEmpty) return;

    final parsed = double.tryParse(value);
    if (parsed == null) return;

    setState(() {
      _age = parsed.clamp(minAge, maxAge);
    });
  }

  void _applyFinalValidation() {
    final value = double.tryParse(_controller.text);

    if (value == null) {
      _controller.text = _age.toStringAsFixed(0);
      return;
    }

    if (value > maxAge) {
      _showWarning('Возраст не может быть больше ${maxAge.toInt()} лет');
    } else if (value < minAge) {
      _showWarning('Возраст не может быть меньше ${minAge.toInt()} лет');
    }

    final corrected = value.clamp(minAge, maxAge);

    setState(() {
      _age = corrected;
      _controller.text = corrected.toStringAsFixed(0);
    });
  }

  void _showWarning(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
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
                      'Введите ваш возраст',
                      style: AppFonts.literata(
                        fontSize: 26,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF5C5248),
                      ),
                    ),

              

                    SizedBox(height: screenHeight * 0.08),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F0F7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 140,
                            child: TextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: AppFonts.literata(
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
                                  RegExp(r'^\d{0,3}'),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          Text(
                            'лет',
                            style: AppFonts.literata(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF5C5248),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.04),

                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${minAge.toInt()} лет',
                                style: AppFonts.roboto(fontSize: 14),
                              ),
                              Text(
                                '${maxAge.toInt()} лет',
                                style: AppFonts.roboto(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        Slider(
                          value: _age,
                          min: minAge,
                          max: maxAge,
                          divisions: (maxAge - minAge).toInt(),
                          activeColor: const Color(0xFF5C5248),
                          onChanged: _updateAge,
                        ),
                      ],
                    ),

                    const Spacer(),

                    Image.asset(
                      'assets/images/ageguy.png',
                      width: 353,
                      height: 325,
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

                              if (_age >= minAge && _age <= maxAge) {
                                context.read<UserDataProvider>().setAge(_age.round());
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ActivityLevelScreen(),
                                  ),
                                );
                              }
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
                              style: AppFonts.roboto(
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