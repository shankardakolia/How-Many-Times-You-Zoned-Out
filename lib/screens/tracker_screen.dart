import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/zone_out_provider.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ZoneOutProvider>().loadTodayEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<ZoneOutProvider>(
          builder: (context, provider, _) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  Text(
                    'Today\'s Zone Outs',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      '${provider.todayCount}',
                      key: ValueKey(provider.todayCount),
                      style: const TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                  ),
                  const Spacer(flex: 1),
                  SizedBox(
                    width: 220,
                    height: 220,
                    child: Material(
                      elevation: 8,
                      shape: const CircleBorder(),
                      shadowColor: const Color(0xFF1E3A8A).withValues(alpha: 0.3),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => provider.addEntry(),
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF1E3A8A),
                                Color(0xFF2D5BFF),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                              child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.psychology,
                                size: 56,
                                color: Colors.white,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Zoned Out',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Approx. Duration: ${provider.currentDuration}s',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Slider(
                          value: provider.currentDuration.toDouble(),
                          min: 0,
                          max: 60,
                          divisions: 60,
                          activeColor: const Color(0xFF1E3A8A),
                          inactiveColor: const Color(0xFF1E3A8A).withValues(alpha: 0.2),
                          label: '${provider.currentDuration}s',
                          onChanged: (value) {
                            provider.setDuration(value.round());
                          },
                        ),
                        Text(
                          '0s                   60s',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 1),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
