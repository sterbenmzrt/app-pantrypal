import 'dart:async';

import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _goToWelcome();
  }

  void _goToWelcome() {
    // Short delay so the brand moment is visible before entering the app.
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/welcome');
    });
  }

  @override
  Widget build(BuildContext context) {
    const heroImage =
        'https://lh3.googleusercontent.com/aida-public/AB6AXuAeCanGJs2IS1T4L2ahcHGZWjd9ovCE-NC4_OVn75yYDDqGq4luQsLOkaNS42unPTy9tzIYVQEz_izeilmz9M8M6keJMw6mNKYWr_SXNUFqi6YbnKZ1GoRfAKU191IgNTmrHKaXknV56cBBUIWc-gaiSCyElO5JnW5t1GoNzYglABZaElAje1SQ6IuRw7lpdMTDW5TrO8AEz1bRYJaeJzn6K8_B4ywjJ9rCzipEbfH6NWXh9L9bNIsjJqnRDXn-DR3BJTKXtm4lgQ';

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background hero visual from the provided design.
          Image.network(heroImage, fit: BoxFit.cover),
          // Soft overlay to keep text legible.
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xB3000000), Color(0x66000000)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.kitchen, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'PantryPal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const Text(
                  'Your Smart Kitchen Assistant',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Reduce food waste, save money, and simplify your meal planning.",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                      strokeWidth: 5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
