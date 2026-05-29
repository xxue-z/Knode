import 'dart:convert';
import 'package:shelf/shelf.dart' as shelf;

class QuizHandler {
  final dynamic _examRepository;
  final dynamic _questionRepository;
  QuizHandler(this._examRepository, this._questionRepository);

  Future<Map<String, dynamic>> getQuestions(shelf.Request req) async {
    try {
      final questions = await _questionRepository.getRandom(limit: 10);
      return {'questions': questions.map((q) => {
        'id': q.id, 'type': q.type, 'stem': q.stem, 'options': q.options, 'difficulty': q.difficulty
      }).toList()};
    } catch (e) {
      return {'error': e.toString(), 'questions': []};
    }
  }

  Future<Map<String, dynamic>> submitAnswer(shelf.Request req) async {
    try {
      final body = await req.readAsString();
      final data = jsonDecode(body);
      final questionId = data['questionId'] as int;
      final userAnswer = data['answer'] as String;
      final questions = await _questionRepository.getByIds([questionId]);
      if (questions.isEmpty) return {'error': 'Question not found'};
      final q = questions.first;
      final isCorrect = q.answer == userAnswer;
      return {'questionId': questionId, 'isCorrect': isCorrect, 'correctAnswer': q.answer, 'explanation': q.explanation};
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}