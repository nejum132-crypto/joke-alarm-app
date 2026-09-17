import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

class ScheduleTab extends ConsumerWidget {
  const ScheduleTab({super.key});

  Future<void> _addTime(BuildContext context, WidgetRef ref) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      await ref.read(scheduleControllerProvider.notifier).addTime(picked);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final times = ref.watch(scheduleControllerProvider).times;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: GestureDetector(
            onTap: () => _addTime(context, ref),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/character_clock.png', width: 150),
                const SizedBox(height: 8),
                const Text(
                  '탭해서 알림 시간 추가',
                  style: TextStyle(color: Color(0xFF8A7462)),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: times.isEmpty
              ? const Center(child: Text('아직 등록된 알림 시간이 없어요'))
              : ListView.builder(
                  itemCount: times.length,
                  itemBuilder: (context, index) {
                    final time = times[index];
                    return ListTile(
                      leading: const Icon(Icons.alarm),
                      title: Text(time.format(context)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => ref
                            .read(scheduleControllerProvider.notifier)
                            .removeTime(time),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
