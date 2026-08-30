import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../domain/action_log_entry.dart';

class ActionHistoryPanel extends StatefulWidget {
  final List<ActionLogEntry> logs;

  const ActionHistoryPanel({super.key, required this.logs});

  @override
  State<ActionHistoryPanel> createState() => _ActionHistoryPanelState();
}

class _ActionHistoryPanelState extends State<ActionHistoryPanel> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (!_expanded) {
      return Positioned(
        bottom: 140,
        right: 20,
        child: FloatingActionButton.small(
          backgroundColor: AppColors.hauntedCharcoal,
          child: const Icon(Icons.history, color: AppColors.candleIvory),
          onPressed: () => setState(() => _expanded = true),
        ),
      );
    }

    return Positioned(
      bottom: 140,
      right: 20,
      width: 300,
      height: 400,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.abyssBlack.withValues(alpha: 0.95),
          border: Border.all(color: AppColors.fogGray),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('ACTION HISTORY', style: TextStyle(color: AppColors.candleIvory, letterSpacing: 2)),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.fogGray),
                    onPressed: () => setState(() => _expanded = false),
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: widget.logs.length,
                itemBuilder: (context, index) {
                  final log = widget.logs[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      children: [
                        Text('${log.timestamp.hour}:${log.timestamp.minute.toString().padLeft(2, '0')}', style: const TextStyle(color: AppColors.fogGray, fontSize: 12)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            log.text,
                            style: TextStyle(
                              color: log.isImportant ? AppColors.bloodWine : AppColors.candleIvory,
                              fontWeight: log.isImportant ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              height: 40,
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.hauntedCharcoal))),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('ALL', style: TextStyle(color: AppColors.bloodWine, fontWeight: FontWeight.bold)),
                  Text('MOVES', style: TextStyle(color: AppColors.fogGray)),
                  Text('CARDS', style: TextStyle(color: AppColors.fogGray)),
                  Text('EVENTS', style: TextStyle(color: AppColors.fogGray)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
