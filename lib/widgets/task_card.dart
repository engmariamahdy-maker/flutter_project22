import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../theme/app_colors.dart';
import '../constants/app_constants.dart';
import '../utils/date_formatter.dart';
import 'priority_badge.dart';

class TaskCard extends StatefulWidget {
  final TaskModel task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppConstants.animationNormal,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: ValueKey(widget.task.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) => widget.onDelete(),
      background: _buildDismissBackground(),
      confirmDismiss: (direction) async {
        final result = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('حذف المهمة'),
            content: Text('هل أنت متأكد من حذف مهمة "${widget.task.title}"؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                child: const Text('حذف'),
              ),
            ],
          ),
        );
        return result ?? false;
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: GestureDetector(
          onLongPress: widget.onEdit,
          onTapDown: (_) {
            setState(() => _isPressed = true);
            _controller.forward();
          },
          onTapUp: (_) {
            setState(() => _isPressed = false);
            _controller.reverse();
          },
          onTapCancel: () {
            setState(() => _isPressed = false);
            _controller.reverse();
          },
          child: AnimatedContainer(
            duration: AppConstants.animationFast,
            curve: Curves.easeInOut,
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusLg),
              border: Border.all(
                color: isDark
                    ? (_isPressed
                        ? AppColors.primary.withValues(alpha: 0.5)
                        : AppColors.borderDark)
                    : (_isPressed
                        ? AppColors.primary.withValues(alpha: 0.3)
                        : AppColors.borderLight),
                width: _isPressed ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : AppColors.primaryTextLight)
                      .withValues(alpha: _isPressed ? 0.12 : 0.06),
                  blurRadius: _isPressed ? 20 : 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCheckbox(isDark),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTaskTitle(isDark),
                      const SizedBox(height: 10),
                      _buildMetaInfoWrap(isDark),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _buildIconIndicator(isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskTitle(bool isDark) {
    return AnimatedDefaultTextStyle(
      duration: AppConstants.animationFast,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: widget.task.isCompleted
            ? (isDark
                ? AppColors.secondaryTextDark
                : AppColors.secondaryTextLight)
            : (isDark
                ? AppColors.primaryTextDark
                : AppColors.primaryTextLight),
        decoration: widget.task.isCompleted
            ? TextDecoration.lineThrough
            : TextDecoration.none,
      ),
      child: Text(
        widget.task.title,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildMetaInfoWrap(bool isDark) {
    final Color secondaryColor = isDark
        ? AppColors.secondaryTextDark
        : AppColors.secondaryTextLight;

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _buildInfoChip(
          icon: Icons.access_time_rounded,
          label: DateFormatter.formatDateShort(widget.task.createdAt),
          iconColor: secondaryColor,
          textColor: secondaryColor,
        ),
        if (widget.task.dueDate != null)
          _buildInfoChip(
            icon: Icons.event_rounded,
            label: DateFormatter.formatDateShort(widget.task.dueDate!),
            iconColor: widget.task.color,
            textColor: widget.task.color,
            textWeight: FontWeight.w500,
          ),
        PriorityBadge(
          priority: widget.task.priority,
          compact: true,
        ),
      ],
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color iconColor,
    required Color textColor,
    FontWeight textWeight = FontWeight.w400,
  }) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: iconColor,
          ),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: textColor,
                fontWeight: textWeight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckbox(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: GestureDetector(
        onTap: widget.onToggle,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: AppConstants.animationNormal,
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color:
                widget.task.isCompleted ? widget.task.color : Colors.transparent,
            border: Border.all(
              color: widget.task.isCompleted
                  ? widget.task.color
                  : (isDark ? AppColors.borderDark : AppColors.borderLight),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: AnimatedSwitcher(
            duration: AppConstants.animationFast,
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: widget.task.isCompleted
                ? const Icon(
                    Icons.check_rounded,
                    key: ValueKey('check'),
                    size: 18,
                    color: Colors.white,
                  )
                : const SizedBox.shrink(key: ValueKey('empty')),
          ),
        ),
      ),
    );
  }

  Widget _buildIconIndicator(bool isDark) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: widget.task.color.withValues(
            alpha: widget.task.isCompleted ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMd),
      ),
      child: Icon(
        widget.task.icon,
        color: widget.task.color,
        size: 24,
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      alignment: AlignmentDirectional.centerStart,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.danger,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLg),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'حذف',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
