import 'package:flutter/material.dart';

class IntroScreen extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final String description;
  final String subHeading;
  final int currentPage;
  final int totalPageCount;
  final VoidCallback onNext;
  final String buttonText;

  const IntroScreen({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.subHeading,
    required this.currentPage,
    required this.totalPageCount,
    required this.onNext,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            Text(
              title,
              style: const TextStyle(
                fontFamily: "Lalezar",
                fontSize: 48,
                fontWeight: FontWeight.w400,
                color: Color.fromRGBO(215, 223, 127, 1),
              ),
            ),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                fontFamily: "Montserrat",
                fontSize: 17,
                color: Colors.white,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.08),
            Image.asset(imagePath),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            Text(
              subHeading,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: "Lalezar",
                fontSize: 36,
                fontWeight: FontWeight.w400,
                color: Color.fromRGBO(215, 223, 127, 1),
              ),
            ),
            Text(
              description,
              style: const TextStyle(
                fontFamily: "Montserrat",
                fontSize: 15,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(totalPageCount, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  height: currentPage == index ? 9.0 : 8.0,
                  width: currentPage == index ? 9.0 : 8.0,
                  decoration: BoxDecoration(
                    color: currentPage == index
                        ? const Color.fromRGBO(215, 223, 127, 1)
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(4.0),
                    boxShadow: currentPage == index
                        ? [
                            BoxShadow(
                              color: const Color.fromRGBO(215, 223, 127, 1)
                                  .withOpacity(0.9),
                              spreadRadius: 1,
                              blurRadius: 2,
                              offset: const Offset(0, 0),
                            ),
                          ]
                        : [],
                  ),
                );
              }),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(215, 223, 127, 1),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontFamily: "Montserrat",
                      color: Color.fromRGBO(26, 81, 98, 1)),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFF0B2C36),
    );
  }
}
