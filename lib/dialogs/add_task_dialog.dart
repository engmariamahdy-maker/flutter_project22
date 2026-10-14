import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../theme/app_colors.dart';
import '../constants/app_constants.dart';
import '../utils/date_formatter.dart';

class AddTaskDialog extends StatefulWidget {
  final TaskModel? task;

  const AddTaskDialog({super.key, this.task});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  late final TextEditingController _titleController;
  late TaskPriority _selectedPriority;
  DateTime? _selectedDate;
  late Color _selectedColor;
  late IconData _selectedIcon;
  final _formKey = GlobalKey<FormState>();

  final List<IconData> _availableIcons = const [
    Icons.task_alt_rounded,
    Icons.work_rounded,
    Icons.school_rounded,
    Icons.fitness_center_rounded,
    Icons.shopping_cart_rounded,
    Icons.home_rounded,
    Icons.favorite_rounded,
    Icons.lightbulb_rounded,
    Icons.event_rounded,
    Icons.book_rounded,
    Icons.music_note_rounded,
    Icons.directions_car_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _selectedPriority = widget.task?.priority ?? TaskPriority.medium;
    _selectedDate = widget.task?.dueDate;
    _selectedColor = widget.task?.color ?? AppColors.taskColors.first;
    _selectedIcon = widget.task?.icon ?? Icons.task_alt_rounded;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final brightness = Theme.of(context).brightness;
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: _selectedColor,
              brightness: brightness,
              primary: _selectedColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final task = TaskModel(
        id: widget.task?.id,
        title: _titleController.text.trim(),
        createdAt: widget.task?.createdAt,
        dueDate: _selectedDate,
        priority: _selectedPriority,
        isCompleted: widget.task?.isCompleted ?? false,
        color: _selectedColor,
        icon: _selectedIcon,
      );
      Navigator.of(context).pop(task);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.task != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    AnimatedContainer(
                      duration: AppConstants.animationNormal,
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _selectedColor.withOpacity(0.15),
                        borderRadius:
                            BorderRadius.circular(AppConstants.borderRadiusMd),
                      ),
                      child: Icon(
                        _selectedIcon,
                        color: _selectedColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        isEdit ? 'تعديل المهمة' : 'مهمة جديدة',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    if (isEdit)
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.close_rounded,
                          color: isDark
                              ? AppColors.secondaryTextDark
                              : AppColors.secondaryTextLight,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 28),
                TextFormField(
                  controller: _titleController,
                  autofocus: !isEdit,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'الرجاء إدخال عنوان المهمة';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  style: Theme.of(context).textTheme.bodyLarge,
                  decoration: const InputDecoration(
                    labelText: 'عنوان المهمة',
                    hintText: 'مثال: إنهاء مشروع التصميم',
                    prefixIcon: Icon(Icons.title_rounded),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'الأولوية',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildPriorityChip(TaskPriority.low, 'منخفضة',
                        AppColors.success, Icons.flag_outlined),
                    const SizedBox(width: 10),
                    _buildPriorityChip(TaskPriority.medium, 'متوسطة',
                        AppColors.warning, Icons.flag_rounded),
                    const SizedBox(width: 10),
                    _buildPriorityChip(TaskPriority.high, 'عالية',
                        AppColors.danger, Icons.flag_rounded),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'التاريخ',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _selectDate,
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadiusMd),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                      borderRadius:
                          BorderRadius.circular(AppConstants.borderRadiusMd),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.event_rounded,
                          color: _selectedDate != null
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.secondaryTextDark
                                  : AppColors.secondaryTextLight),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedDate != null
                                ? DateFormatter.formatDate(_selectedDate!)
                                : 'اختر تاريخ الاستحقاق (اختياري)',
                            style: TextStyle(
                              fontSize: 14,
                              color: _selectedDate != null
                                  ? (isDark
                                      ? AppColors.primaryTextDark
                                      : AppColors.primaryTextLight)
                                  : (isDark
                                      ? AppColors.secondaryTextDark
                                      : AppColors.secondaryTextLight),
                            ),
                          ),
                        ),
                        if (_selectedDate != null)
                          IconButton(
                            onPressed: () =>
                                setState(() => _selectedDate = null),
                            icon: Icon(
                              Icons.clear_rounded,
                              size: 20,
                              color: isDark
                                  ? AppColors.secondaryTextDark
                                  : AppColors.secondaryTextLight,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'اللون',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: AppColors.taskColors
                      .map((color) => _buildColorPicker(color))
                      .toList(),
                ),
                const SizedBox(height: 24),
                Text(
                  'الأيقونة',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _availableIcons
                      .map((icon) => _buildIconPicker(icon))
                      .toList(),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('إلغاء'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedColor,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(isEdit ? Icons.save_rounded : Icons.add_rounded),
                            const SizedBox(width: 8),
                            Text(isEdit ? 'حفظ التعديلات' : 'إضافة المهمة'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(
    TaskPriority priority,
    String label,
    Color color,
    IconData icon,
  ) {
    final isSelected = _selectedPriority == priority;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPriority = priority),
        child: AnimatedContainer(
          duration: AppConstants.animationFast,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
            border: Border.all(
              color: isSelected ? color : (Theme.of(context).brightness == Brightness.dark ? AppColors.borderDark : AppColors.borderLight),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMd),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isSelected ? color : null),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? color : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorPicker(Color color) {
    final isSelected = _selectedColor == color;
    return GestureDetector(
      onTap: () => setState(() => _selectedColor = color),
      child: AnimatedContainer(
        duration: AppConstants.animationFast,
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                  width: 3,
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: AnimatedSwitcher(
          duration: AppConstants.animationFast,
          transitionBuilder: (child, anim) =>
              ScaleTransition(scale: anim, child: child),
          child: isSelected
              ? const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 22,
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildIconPicker(IconData icon) {
    final isSelected = _selectedIcon == icon;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => setState(() => _selectedIcon = icon),
      child: AnimatedContainer(
        duration: AppConstants.animationFast,
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected
              ? _selectedColor.withOpacity(0.15)
              : (isDark
                  ? AppColors.backgroundDark
                  : AppColors.backgroundLight),
          border: Border.all(
            color: isSelected
                ? _selectedColor
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMd),
        ),
        child: Icon(
          icon,
          color: isSelected
              ? _selectedColor
              : (isDark
                  ? AppColors.secondaryTextDark
                  : AppColors.secondaryTextLight),
          size: 24,
        ),
      ),
    );
  }
}
