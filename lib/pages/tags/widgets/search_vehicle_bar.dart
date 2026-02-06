import 'package:flutter/material.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';

class SearchVehicleBar extends StatefulWidget {
  final Function(String)? onSearch;

  const SearchVehicleBar({
    super.key,
    this.onSearch,
  });

  @override
  State<SearchVehicleBar> createState() => _SearchVehicleBarState();
}

class _SearchVehicleBarState extends State<SearchVehicleBar> {
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
      padding: const EdgeInsets.symmetric(horizontal: 8),
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
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onSubmitted: (value) => _handleSearch(),
                decoration: InputDecoration(
                  hintText: 'Search any vehicle',
                  hintStyle: TextStyle(
                    color: AppColors.textGrey.withOpacity(0.6),
                    fontSize: AppConstants.fontSizeCardTitle,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                  ),
                  isDense: true,
                ),
                style: TextStyle(
                  fontSize: AppConstants.fontSizeCardTitle,
                  color: AppColors.black,
                ),
              ),
            ),
            GestureDetector(
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
