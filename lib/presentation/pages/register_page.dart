import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/user_repository.dart';
import '../../logic/blocs/signup/signup_bloc.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // 🧾 Controllers for input fields
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool agreeToTerms = false;

  @override
  Widget build(BuildContext context) {
    // 🎨 Brand Colors & Fonts
    const Color primaryColor = Color(0xFF0B3D2E);
    const Color accentColor = Color(0xFFF5B400);
    const Color backgroundColor = Color(0xFFFFFFFF);
    const Color textGray = Color(0xFF6B6B6B);
    const String fontFamily = 'Poppins';

    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: BlocProvider(
        create: (context) => SignupBloc(userRepository: UserRepository()),
        child: BlocListener<SignupBloc, SignupState>(
          listener: (context, state) {
            if (state is SignupFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Signup Failed: ${state.error}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            if (state is SignupSuccess) {
              // Navigate to login page or show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Signup Successful!'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pushNamed(context, '/login');
            }
          },
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isTablet ? 32 : 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: isTablet ? 48 : 32),

                    // 🏷️ Header Logo
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: "Social ",
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 28 : 24,
                          fontFamily: fontFamily,
                        ),
                        children: [
                          TextSpan(
                            text: "Bunkr",
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              decorationColor: accentColor,
                              decorationThickness: 3,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: isTablet ? 40 : 24),

                    // 🟡 Title
                    Text(
                      "Create Your Account",
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: isTablet ? 26 : 22,
                        fontFamily: fontFamily,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Host management and list vacant beds for extra income.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textGray,
                        fontSize: isTablet ? 18 : 14,
                        fontFamily: fontFamily,
                      ),
                    ),

                    SizedBox(height: isTablet ? 36 : 24),

                    // 🧾 Input Fields
                    _buildTextField(
                      controller: firstNameController,
                      hintText: "First Name",
                      icon: Icons.person,
                      isTablet: isTablet,
                    ),
                    _buildTextField(
                      controller: lastNameController,
                      hintText: "Last Name",
                      icon: Icons.person,
                      isTablet: isTablet,
                    ),
                    _buildTextField(
                      controller: emailController,
                      hintText: "Email Address",
                      icon: Icons.email,
                      isTablet: isTablet,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your email";
                        } else if (!value.contains('@')) {
                          return "Enter a valid email";
                        }
                        return null;
                      },
                    ),
                    _buildTextField(
                      controller: phoneController,
                      hintText: "Phone Number",
                      icon: Icons.phone,
                      isTablet: isTablet,
                    ),
                    _buildTextField(
                      controller: passwordController,
                      hintText: "Password",
                      icon: Icons.lock,
                      obscureText: true,
                      isTablet: isTablet,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your password";
                        } else if (value.length < 6) {
                          return "Password must be at least 6 characters";
                        }
                        return null;
                      },
                    ),
                    _buildTextField(
                      controller: confirmPasswordController,
                      hintText: "Confirm Password",
                      icon: Icons.lock,
                      obscureText: true,
                      isTablet: isTablet,
                      validator: (value) {
                        if (value != passwordController.text) {
                          return "Passwords do not match";
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: isTablet ? 16 : 12),

                    // ☑️ Terms Checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: agreeToTerms,
                          onChanged: (value) {
                            setState(() => agreeToTerms = value ?? false);
                          },
                          activeColor: primaryColor,
                        ),
                        Expanded(
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                "I agree to the ",
                                style: TextStyle(
                                  color: textGray,
                                  fontFamily: fontFamily,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  // TODO: Open Terms page
                                },
                                child: const Text(
                                  "Terms and Conditions",
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: fontFamily,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: isTablet ? 24 : 20),

                    // 🔘 Create Account Button
                    BlocBuilder<SignupBloc, SignupState>(
                      builder: (context, state) {
                        return SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: state is SignupLoading
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 3,
                                  ),
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      if (!agreeToTerms) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text("Please agree to Terms and Conditions"),
                                          ),
                                        );
                                        return;
                                      }
                                      BlocProvider.of<SignupBloc>(context).add(
                                        SignupButtonPressed(
                                          email: emailController.text,
                                          password: passwordController.text,
                                          firstName: firstNameController.text,
                                          lastName: lastNameController.text,
                                          role: 'guest', // or get it from a form field
                                        ),
                                      );
                                    }
                                  },
                                  child: Text(
                                    "Create Account",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: isTablet ? 18 : 16,
                                      fontFamily: fontFamily,
                                    ),
                                  ),
                                ),
                        );
                      },
                    ),

                    SizedBox(height: isTablet ? 32 : 24),

                    // 🧍 Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: TextStyle(
                            color: textGray,
                            fontFamily: fontFamily,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          child: const Text(
                            "Log in",
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontFamily: fontFamily,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: isTablet ? 32 : 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 📦 Helper Widget for Input Fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    bool isTablet = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Color(0xFF0B3D2E)),
          hintText: hintText,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: isTablet ? 16 : 12),
        ),
      ),
    );
  }
}
