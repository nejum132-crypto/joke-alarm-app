import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/on_off_toggle.dart';
import 'character_tab.dart';
import 'favorites_tab.dart';
import 'schedule_tab.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Tops up the rolling notification window in case the app hasn't been
    // opened in a while, and re-rolls today's random "surprise me" times.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(scheduleControllerProvider.notifier).refresh();
      ref.read(randomJokeControllerProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final randomEnabled = ref.watch(randomJokeControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          label: '삶은 계란',
          child: SizedBox(
            height: 40,
            child: Image.asset(
              'assets/images/character_lying.png',
              fit: BoxFit.contain,
              alignment: Alignment.centerLeft,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Tooltip(
              message: '켜면 하루 2번 랜덤한 시간에 아재개그 알림이 와요',
              child: OnOffToggle(
                value: randomEnabled,
                onChanged: (value) => ref
                    .read(randomJokeControllerProvider.notifier)
                    .setEnabled(value),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '홈'),
            Tab(text: '지정 시간'),
            Tab(text: '즐겨찾기'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          CharacterTab(),
          ScheduleTab(),
          FavoritesTab(),
        ],
      ),
      bottomNavigationBar: const SafeArea(child: BannerAdWidget()),
    );
  }
}
