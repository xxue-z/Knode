import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/question.dart';
import '../../providers/quiz_provider.dart';
import 'wrong_detail.dart';

/// 错题本列表页面，显示所有错题，按错误次数排序。
class WrongListPage extends ConsumerStatefulWidget {
  const WrongListPage({super.key});

  @override
  ConsumerState<WrongListPage> createState() => _WrongListPageState();
}

class _WrongListPageState extends ConsumerState<WrongListPage> {
  String _sortBy = 'wrong_count'; // wrong_count | difficulty
  bool _descending = true;

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(questionRepositoryProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('错题本'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (v) => setState(() {
              if (v == _sortBy) {
                _descending = !_descending;
              } else {
                _sortBy = v;
                _descending = true;
              }
            }),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'wrong_count', child: Text('按错误次数')),
              const PopupMenuItem(value: 'difficulty', child: Text('按难度')),
            ],
          ),
        ],
      ),
      body: FutureBuilder<List<Question>>(
        future: repo.getWrongQuestions(limit: 100),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final questions = snapshot.data ?? [];
          if (questions.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('暂无错题，继续保持！'),
                ],
              ),
            );
          }

          // 排序
          final sorted = List<Question>.from(questions);
          if (_sortBy == 'difficulty') {
            sorted.sort((a, b) => _descending
                ? b.difficulty.compareTo(a.difficulty)
                : a.difficulty.compareTo(b.difficulty));
          }

          return ListView.builder(
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              final q = sorted[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _difficultyColor(q.difficulty),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(q.stem, maxLines: 2, overflow: TextOverflow.ellipsis),
                  subtitle: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _difficultyColor(q.difficulty).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _difficultyLabel(q.difficulty),
                          style: TextStyle(
                            fontSize: 11,
                            color: _difficultyColor(q.difficulty),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _typeLabel(q.type),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WrongDetailPage(question: q),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _difficultyColor(int difficulty) {
    switch (difficulty) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _difficultyLabel(int difficulty) {
    switch (difficulty) {
      case 1:
        return '简单';
      case 2:
        return '中等';
      case 3:
        return '困难';
      default:
        return '未知';
    }
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'single_choice':
        return '单选';
      case 'multi_choice':
        return '多选';
      case 'true_false':
        return '判断';
      case 'fill_blank':
        return '填空';
      case 'short_answer':
        return '简答';
      default:
        return type;
    }
  }
}
