import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Hero image header
          Expanded(
            flex: 2,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuAeCanGJs2IS1T4L2ahcHGZWjd9ovCE-NC4_OVn75yYDDqGq4luQsLOkaNS42unPTy9tzIYVQEz_izeilmz9M8M6keJMw6mNKYWr_SXNUFqi6YbnKZ1GoRfAKU191IgNTmrHKaXknV56cBBUIWc-gaiSCyElO5JnW5t1GoNzYglABZaElAje1SQ6IuRw7lpdMTDW5TrO8AEz1bRYJaeJzn6K8_B4ywjJ9rCzipEbfH6NWXh9L9bNIsjJqnRDXn-DR3BJTKXtm4lgQ',
                  fit: BoxFit.cover,
                ),
                Positioned(
                  left: 16,
                  top: 16,
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.kitchen, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'PantryPal',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Body
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Your Smart Kitchen Assistant',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Reduce food waste, save money, and simplify your meal planning. Let's get your pantry organized.",
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/signup'),
                      style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                      child: const Text('Get Started'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    child: const Text('Already have an account? Log In'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
