import 'package:flutter/material.dart';
import '../models/group.dart'; // Assuming Group model is in lib/models/group.dart

class GroupChip extends StatelessWidget {
  final Group group;
  final bool isSelected;
  final ValueChanged<bool>? onSelected; // Callback for when the chip is selected/deselected

  const GroupChip({
    Key? key,
    required this.group,
    this.isSelected = false,
    this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color chipColor = Color(group.color);
    final bool isDarkColor = ThemeData.estimateBrightnessForColor(chipColor) == Brightness.dark;
    final Color labelColor = isDarkColor ? Colors.white : Colors.black;

    return FilterChip(
      label: Text(
        group.name,
        style: TextStyle(
          color: isSelected ? labelColor : Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: isSelected ? chipColor.withOpacity(0.2) : Colors.grey.shade200,
      selectedColor: chipColor, // Background color when selected
      checkmarkColor: isSelected ? labelColor : null,
      shape: StadiumBorder(
        side: BorderSide(
          color: isSelected ? chipColor : Colors.grey.shade400,
          width: 1.0,
        ),
      ),
      showCheckmark: isSelected, // Show checkmark only when selected
    );
  }
}
