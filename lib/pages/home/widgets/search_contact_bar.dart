import 'package:flutter/material.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';

class SearchContactBar extends StatefulWidget {
  final Function(String)? onSearch; // ✅ Add callback

  const SearchContactBar({
    super.key,
    this.onSearch,
  });

  @override
  State<SearchContactBar> createState() => _SearchContactBarState();
}

class _SearchContactBarState extends State<SearchContactBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSearch() {
    if (widget.onSearch != null) {
      widget.onSearch!(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.paddingLarge,
          4,
          4,
          4,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: AppColors.lightGrey,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller, // ✅ Added controller
                onSubmitted: (value) => _handleSearch(), // ✅ Search on Enter
                decoration: InputDecoration(
                  hintText: 'Contact any vehicle',
                  hintStyle: TextStyle(
                    color: AppColors.textGrey.withOpacity(0.6),
                    fontSize: AppConstants.fontSizeCardTitle,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,  // ✅ Reduced to 0 for minimal height
                  ),
                  isDense: true,  // ✅ Makes the field more compact
                ),
                style: TextStyle(
                  fontSize: AppConstants.fontSizeCardTitle,
                  color: AppColors.black,
                ),
              ),
            ),
            GestureDetector( // ✅ Added tap handler
              onTap: _handleSearch,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.activeYellow,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.search,
                  color: AppColors.black,
                  size: AppConstants.iconSizeLarge,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
