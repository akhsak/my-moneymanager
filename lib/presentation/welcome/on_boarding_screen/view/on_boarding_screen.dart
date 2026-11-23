import 'package:flutter/material.dart';
import 'package:monaymanagment/core/constants/color_constants.dart';
import 'package:monaymanagment/core/constants/size_constatnts.dart';
import 'package:monaymanagment/core/constants/text_styles.dart';
import 'package:monaymanagment/presentation/welcome/launch_screen/view/launch_screen.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardData> _pages = const [
    _OnboardData(
      titleLine1: 'Welcome To',
      titleLine2: 'Expense Manager',
      assetPath: 'assets/on_boarding/amico.png',
    ),
    _OnboardData(
      titleLine1: 'Are You Ready To\nTake Control Of\nYour Finaces?',
      titleLine2: '',
      assetPath: 'assets/on_boarding/amico (1).png',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LaunchScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConstants.init(context);

    return Scaffold(
      backgroundColor: ColorTheme.secondaryColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: SizeConstants.width(6),
                vertical: SizeConstants.height(4),
              ),
              child: Column(
                children: [
                  Text(
                    _pages[_currentPage].titleLine1,
                    textAlign: TextAlign.center,
                    style: TextStyles.bodyText(
                      color: ColorTheme.mainColor2,
                      size: SizeConstants.font(5),
                      weight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: SizeConstants.height(1.2)),
                  Text(
                    _pages[_currentPage].titleLine2,
                    textAlign: TextAlign.center,
                    style: TextStyles.bodyText(
                      color: ColorTheme.mainColor2,
                      size: SizeConstants.font(5),
                      weight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            
            // White Section
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: ColorTheme.mainColor2,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(SizeConstants.width(10)),
                    topRight: Radius.circular(SizeConstants.width(10)),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: SizeConstants.height(4)),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _pages.length,
                        onPageChanged: (index) {
                          setState(() => _currentPage = index);
                        },
                        itemBuilder: (context, index) {
                          final data = _pages[index];
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: SizeConstants.width(6),
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Image.asset(
                                    width: SizeConstants.width(60),
                                    height: SizeConstants.height(70),
                                    data.assetPath,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                SizedBox(height: SizeConstants.height(3)),
                                
                                // Continue/Get Started Text Button
                                Center(
                                  child: GestureDetector(
                                    onTap: _goNext,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _currentPage == _pages.length - 1 ? 'Get Started' : 'Continue',
                                          style: TextStyles.bodyText(
                                            color: const Color(0xFF0D3B36),
                                            size: SizeConstants.font(3.5),
                                            weight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(width: SizeConstants.width(2)),
                                        Icon(
                                          Icons.arrow_forward,
                                          color: const Color(0xFF0D3B36),
                                          size: SizeConstants.font(5),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                
                                SizedBox(height: SizeConstants.height(1.2)),
                                _Indicators(count: _pages.length, index: _currentPage),
                                SizedBox(height: SizeConstants.height(3)),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    // Add bottom padding to ensure content doesn't touch the bottom
                    SizedBox(height: SizeConstants.height(2)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Indicators extends StatelessWidget {
  const _Indicators({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final bool active = i == index;
        return Container(
          width: SizeConstants.width(active ? 2.5 : 2),
          height: SizeConstants.width(active ? 2.5 : 2),
          margin: EdgeInsets.symmetric(horizontal: SizeConstants.width(1.2)),
          decoration: BoxDecoration(
            color: active ? ColorTheme.secondaryColor : Colors.white,
            border: active ? null : Border.all(color: const Color(0xFF0D3B36), width: 1.2),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}

class _OnboardData {
  const _OnboardData({
    required this.titleLine1,
    required this.titleLine2,
    required this.assetPath,
  });

  final String titleLine1;
  final String titleLine2;
  final String assetPath;
}


