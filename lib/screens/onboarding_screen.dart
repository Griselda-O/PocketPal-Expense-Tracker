import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _page = 0;
  final PageController _controller = PageController();
  String _budget = '';
  List<String> _selectedCategories = [];
  String _goal = '';

  final List<String> _categories = [
    'Food',
    'Transport',
    'Health',
    'Entertainment',
    'Utilities',
    'Shopping',
    'Education',
    'Savings',
    'Travel',
    'Airtime',
    'Printing',
    'Leisure',
    'Other',
  ];
  final List<String> _goals = [
    'Save more',
    'Reduce debt',
    'Track spending',
    'Build emergency fund',
    'Invest',
    'Budget for travel',
    'Increase income',
    'Other',
  ];

  void _nextPage() {
    if (_page < 3) {
      setState(() => _page++);
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_page > 0) {
      setState(() => _page--);
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _controller,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            // 1. Welcome
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                SvgPicture.asset('assets/onboarding/welcome.svg', height: 180),
                const SizedBox(height: 32),
                Text(
                  'Welcome to PocketPal!',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    'Your smart companion for tracking expenses, setting budgets, and reaching your financial goals.',
                    textAlign: TextAlign.center,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _nextPage,
                  child: const Text('Get Started'),
                ),
                const SizedBox(height: 32),
              ],
            ),
            // 2. Feature Highlights
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                SizedBox(
                  height: 200,
                  child: PageView(
                    children: const [
                      _FeatureCard(
                        image: 'assets/onboarding/analytics.svg',
                        title: 'Visualize Spending',
                        desc: 'See your expenses in beautiful charts.',
                      ),
                      _FeatureCard(
                        image: 'assets/onboarding/budget.svg',
                        title: 'Set Budgets',
                        desc: 'Stay on track with monthly budgets.',
                      ),
                      _FeatureCard(
                        image: 'assets/onboarding/share.svg',
                        title: 'Export & Share',
                        desc: 'Export your data and share reports.',
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                ElevatedButton(onPressed: _nextPage, child: const Text('Next')),
                TextButton(onPressed: _prevPage, child: const Text('Back')),
                const SizedBox(height: 32),
              ],
            ),
            // 3. Financial Questions
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    SvgPicture.asset(
                      'assets/onboarding/questions.svg',
                      height: 140,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Let’s personalize your experience!',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'What’s your monthly budget? (GHS)',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => _budget = v,
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Top spending categories:',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      children: _categories
                          .map(
                            (cat) => FilterChip(
                              label: Text(cat),
                              selected: _selectedCategories.contains(cat),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedCategories.add(cat);
                                  } else {
                                    _selectedCategories.remove(cat);
                                  }
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Main financial goal:',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Column(
                      children: _goals
                          .map(
                            (goal) => RadioListTile<String>(
                              title: Text(goal),
                              value: goal,
                              groupValue: _goal,
                              onChanged: (value) {
                                setState(() {
                                  _goal = value!;
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () async {
                        // Persist onboarding choices
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('budget', _budget);
                        await prefs.setStringList(
                          'categories',
                          _selectedCategories,
                        );
                        await prefs.setString('goal', _goal);
                        _nextPage();
                      },
                      child: const Text('Continue'),
                    ),
                    TextButton(onPressed: _prevPage, child: const Text('Back')),
                  ],
                ),
              ),
            ),
            // 4. All Set
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                SvgPicture.asset('assets/onboarding/success.svg', height: 180),
                const SizedBox(height: 32),
                Text(
                  'All set!',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    'You’re ready to start your financial journey with PocketPal.',
                    textAlign: TextAlign.center,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('onboardingComplete', true);
                    Navigator.pushReplacementNamed(
                      context,
                      '/login',
                    ); // or '/home' if login is optional
                  },
                  child: const Text('Start Using PocketPal'),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String image;
  final String title;
  final String desc;
  const _FeatureCard({
    required this.image,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(image, height: 60),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(desc, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
