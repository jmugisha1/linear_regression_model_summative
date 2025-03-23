import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Salary Prediction',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo, fontFamily: 'Roboto'),
      home: const SalaryPredictionPage(),
    );
  }
}

class SalaryPredictionPage extends StatefulWidget {
  const SalaryPredictionPage({super.key});

  @override
  State<SalaryPredictionPage> createState() => _SalaryPredictionPageState();
}

class _SalaryPredictionPageState extends State<SalaryPredictionPage> {
  String _gender = 'Male';
  int _age = 31;
  String _educationLevel = 'Bachelor\'s';
  int _yearsOfExperience = 12;
  double _predictedSalary = 0.0; // To store the predicted salary
  bool _isLoading = false; // To show a loading indicator

  final List<String> _educationLevels = ['Bachelor\'s', 'Master\'s', 'PhD'];

  // Function to call the FastAPI endpoint
  Future<void> _predictSalary() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    // Map gender and education level to numeric values
    final genderMap = {'Male': 1, 'Female': 0};
    final educationMap = {'Bachelor\'s': 0, 'Master\'s': 1, 'PhD': 2};

    // Prepare the request body
    final requestBody = {
      'Age': _age,
      'Gender': genderMap[_gender],
      'EducationLevel': educationMap[_educationLevel],
      'YearsOfExperience': _yearsOfExperience,
    };

    try {
      // Make the POST request to the FastAPI endpoint
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/predict'), // Use local server URL
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        // Parse the response and update the predicted salary
        final responseData = json.decode(response.body);
        setState(() {
          _predictedSalary = responseData['predicted_salary'];
        });
      } else {
        // Handle errors
        throw Exception('Failed to load prediction: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exceptions
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Hey, Welcome',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.fullscreen_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Salary Card
            Card(
              margin: const EdgeInsets.only(bottom: 24.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              color: const Color(0xFF4A33FF),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.credit_card,
                            color: Color(0xFF4A33FF),
                            size: 18,
                          ),
                        ),
                        const Text(
                          'Salary Model',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    _buildCardInfoRow(
                      'Predicted Salary',
                      'RF ${_predictedSalary.toStringAsFixed(2)}',
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: List.generate(
                        3,
                        (index) => Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Text('*Required Fields', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 16),

            // Gender Selection
            _buildSelectionCard(
              title: 'Gender',
              child: Column(
                children: [
                  _buildRadioOption('Male', _gender, (value) {
                    setState(() => _gender = value!);
                  }),
                  _buildRadioOption('Female', _gender, (value) {
                    setState(() => _gender = value!);
                  }),
                ],
              ),
            ),

            // Age Input
            _buildInputCard(
              title: 'Age',
              value: _age.toString(),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  setState(() => _age = int.tryParse(value) ?? _age);
                }
              },
            ),

            // Education Level
            _buildSelectionCard(
              title: 'Education Level',
              child: Column(
                children:
                    _educationLevels.map((level) {
                      return _buildRadioOption(level, _educationLevel, (value) {
                        setState(() => _educationLevel = value!);
                      });
                    }).toList(),
              ),
            ),

            // Years of Experience
            _buildInputCard(
              title: 'Years Of Experience',
              value: _yearsOfExperience.toString(),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  setState(
                    () =>
                        _yearsOfExperience =
                            int.tryParse(value) ?? _yearsOfExperience,
                  );
                }
              },
            ),

            // Predict Button
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed:
                  _isLoading
                      ? null
                      : _predictSalary, // Disable button when loading
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A33FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child:
                  _isLoading
                      ? const CircularProgressIndicator(
                        color: Colors.white,
                      ) // Show loading indicator
                      : const Text(
                        'Predict',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.chat_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
        ],
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }

  Widget _buildCardInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionCard({required String title, required Widget child}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      color: Colors.white,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption(
    String title,
    String groupValue,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Radio<String>(
            value: title,
            groupValue: groupValue,
            onChanged: onChanged,
            activeColor: const Color(0xFF4A33FF),
            fillColor: MaterialStateProperty.resolveWith<Color>((
              Set<MaterialState> states,
            ) {
              if (states.contains(MaterialState.selected)) {
                return const Color(0xFF4A33FF);
              }
              return Colors.grey;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard({
    required String title,
    required String value,
    required Function(String) onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      color: Colors.white,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            TextField(
              controller: TextEditingController(text: value),
              onChanged: onChanged,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
