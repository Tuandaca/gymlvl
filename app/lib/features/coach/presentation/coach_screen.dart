import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/localization_engine.dart';
import '../../../core/theme/app_theme.dart';
import '../data/coach_repository.dart';

class CoachScreen extends ConsumerStatefulWidget {
  const CoachScreen({super.key});
  @override
  ConsumerState<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends ConsumerState<CoachScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (await ref.read(coachControllerProvider.notifier).send(_input.text)) {
      if (!mounted) return;
      _input.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.jumpTo(_scroll.position.maxScrollExtent);
        }
      });
    }
  }

  String _error(String code) {
    return switch (code) {
      'coach_unconfigured' => translateText(
        ref,
        vi: 'AI Coach chưa được cấu hình. Bạn vẫn có thể ghi lại buổi tập và theo dõi tiến độ.',
        en: 'AI Coach is not configured yet. Workout tracking and progress remain available.',
      ),
      'daily_limit' => translateText(
        ref,
        vi: 'Bạn đã dùng hết 20 lượt hôm nay. Hãy quay lại ngày mai.',
        en: 'You have used today’s 20 requests. Come back tomorrow.',
      ),
      'unauthorized' => translateText(
        ref,
        vi: 'Phiên đăng nhập đã hết hạn. Hãy đăng nhập lại.',
        en: 'Your session expired. Please sign in again.',
      ),
      _ => translateText(
        ref,
        vi: 'Coach hiện chưa phản hồi. Câu hỏi đã được giữ lại; hãy thử lại sau.',
        en: 'Coach is unavailable. Your question is preserved; please try again later.',
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(coachControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('AI COACH')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Text(
                    translateText(
                      ref,
                      vi: 'Gợi ý do AI tạo, không thay đổi dữ liệu tập luyện. Khi bạn gửi câu hỏi, mục tiêu và lịch sử tập 7 ngày sẽ được chia sẻ với dịch vụ AI đã cấu hình. Ngừng bài tập gây đau và tìm tư vấn chuyên môn khi cần.',
                      en: 'AI suggestions do not change your workout records. Sending a question shares your goals and 7-day workout history with the configured AI service. Stop painful activity and seek qualified guidance when needed.',
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                Expanded(
                  child: state.messages.isEmpty
                      ? Center(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.auto_awesome,
                                  size: 48,
                                  color: AppTheme.cyanNeon,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  translateText(
                                    ref,
                                    vi: 'Lên kế hoạch cho buổi tập tiếp theo',
                                    en: 'Plan your next training session',
                                  ),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  translateText(
                                    ref,
                                    vi: 'Hỏi về kỹ thuật, phục hồi hoặc tiến độ của bạn.',
                                    en: 'Ask about technique, recovery, or your progress.',
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scroll,
                          padding: const EdgeInsets.all(20),
                          itemCount: state.messages.length,
                          itemBuilder: (context, index) {
                            final message = state.messages[index];
                            final user = message.role == 'user';
                            return Align(
                              alignment: user
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                constraints: const BoxConstraints(
                                  maxWidth: 640,
                                ),
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: user
                                      ? AppTheme.cyanNeon.withValues(alpha: 0.1)
                                      : AppTheme.panelBackground,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: SelectableText(message.content),
                              ),
                            );
                          },
                        ),
                ),
                if (state.errorCode != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: Semantics(
                      liveRegion: true,
                      child: Text(_error(state.errorCode!)),
                    ),
                  ),
                if (state.sending) const LinearProgressIndicator(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _input,
                          enabled: !state.sending,
                          minLines: 1,
                          maxLines: 4,
                          maxLength: 2000,
                          decoration: InputDecoration(
                            labelText: translateText(
                              ref,
                              vi: 'Hỏi Coach',
                              en: 'Ask Coach',
                            ),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: IconButton.filled(
                          tooltip: translateText(
                            ref,
                            vi: 'Gửi câu hỏi',
                            en: 'Send question',
                          ),
                          onPressed: state.sending ? null : _send,
                          icon: const Icon(Icons.arrow_upward),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
