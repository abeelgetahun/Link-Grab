import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _numPages = 3;

  List<Map<String, String>> onboardingData = [
    {
      'title': 'Welcome to Link Grab',
      'description':
          'Save and organize links from anywhere with just a few taps.',
      'image': 'assets/images/onboarding1.png',
    },
    {
      'title': 'Share Links Easily',
      'description':
          'Use the share button in any app to save links directly to Link Grab.',
      'image': 'assets/images/onboarding2.png',
    },
    {
      'title': 'Organize Your Links',
      'description':
          'Create categories to keep your links organized and easy to find.',
      'image': 'assets/images/onboarding3.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemCount: _numPages,
                itemBuilder: (context, index) {
                  return OnboardingPage(
                    title: onboardingData[index]['title']!,
                    description: onboardingData[index]['description']!,
                    image: onboardingData[index]['image']!,
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Skip button
                  _currentPage != _numPages - 1
                      ? TextButton(
                        onPressed: () {
                          _completeOnboarding();
                        },
                        child: const Text('Skip'),
                      )
                      : const SizedBox(),

                  // Indicator row
                  Row(
                    children: List.generate(
                      _numPages,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color:
                              _currentPage == index
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  // Next/Done button
                  TextButton(
                    onPressed: () {
                      if (_currentPage != _numPages - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      } else {
                        _completeOnboarding();
                      }
                    },
                    child: Text(
                      _currentPage != _numPages - 1 ? 'Next' : 'Get Started',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _completeOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_onboarding', true);

    if (!mounted) return;

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
  }
}

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final String image;

  const OnboardingPage({
    Key? key,
    required this.title,
    required this.description,
    required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Image.asset(
              image,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.image, size: 100)),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
