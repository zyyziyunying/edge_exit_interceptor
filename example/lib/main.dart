import 'package:flutter/material.dart';
import 'package:edge_exit_interceptor/edge_exit_interceptor.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Edge Exit Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edge Exit Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Open the guarded page and swipe from the left edge. '
                'A confirm dialog appears before route pop.',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const GuardedExitPage(),
                  ),
                );
              },
              child: const Text('Open Guarded Page'),
            ),
          ],
        ),
      ),
    );
  }
}

class GuardedExitPage extends StatefulWidget {
  const GuardedExitPage({super.key});

  @override
  State<GuardedExitPage> createState() => _GuardedExitPageState();
}

class _GuardedExitPageState extends State<GuardedExitPage> {
  Future<void> _handleEdgeTrigger(EdgeExitTriggerDetails details) async {
    final bool? shouldExit = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Leave this page?'),
          content: Text(
            'Swipe detected (offset: ${details.dragOffset.toStringAsFixed(1)}). '
            'Confirm to pop this route.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (shouldExit == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return EdgeExitInterceptor(
      onTrigger: _handleEdgeTrigger,
      child: Scaffold(
        appBar: AppBar(title: const Text('Guarded Exit Page')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Try a left-edge swipe to trigger the guarded exit dialog.\n'
              'Confirm pops. Cancel stays.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
