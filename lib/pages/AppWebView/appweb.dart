import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../utils/colors.dart';

class InAppWebViewPage extends StatefulWidget {
  final String url;
  final String title;

  const InAppWebViewPage({
    super.key,
    required this.url,
    this.title = 'Loading...',
  });

  @override
  State<InAppWebViewPage> createState() => _InAppWebViewPageState();
}

class _InAppWebViewPageState extends State<InAppWebViewPage> {
  late final WebViewController controller;
  bool isLoading = true;
  String pageTitle = '';

  @override
  void initState() {
    super.initState();
    pageTitle = widget.title;
    
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (url) {
            setState(() {
              isLoading = false;
            });
            // Get page title
            controller.getTitle().then((title) {
              if (title != null && title.isNotEmpty) {
                setState(() {
                  pageTitle = title;
                });
              }
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // Yellow gradient background (like your app header)
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryYellow,
                  AppColors.primaryYellow.withOpacity(0.85),
                  AppColors.darkYellow,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Custom Header matching your AppHeader style
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back/Close button (matching your AppHeader style)
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.black.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 20,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                      
                      // Center - Logo (matching your AppHeader)
                      Image.asset(
                        'assets/images/sampark_black.png',
                        height: 32,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Text(
                            'Sampark',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.black,
                            ),
                          );
                        },
                      ),
                      
                      // Refresh button (matching your AppHeader icon style)
                      GestureDetector(
                        onTap: () => controller.reload(),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.black.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.refresh_rounded,
                            size: 22,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // WebView Content with curved top
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    child: Container(
                      color: AppColors.white,
                      child: Stack(
                        children: [
                          WebViewWidget(controller: controller),
                          if (isLoading)
                            Container(
                              color: AppColors.white,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      color: AppColors.activeYellow,
                                      strokeWidth: 3,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Loading...',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
