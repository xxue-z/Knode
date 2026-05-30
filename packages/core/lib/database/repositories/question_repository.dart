import '../dao/question_dao.dart';
import '../dao/wrong_question_dao.dart';
import '../../models/question.dart';

class QuestionRepository {
  final QuestionDao _questionDao;
  final WrongQuestionDao _wrongDao;
  QuestionRepository({required QuestionDao questionDao, required WrongQuestionDao wrongDao})
      : _questionDao = questionDao, _wrongDao = wrongDao;

  Future<List<Question>> getRandom({int limit = 10}) => _questionDao.getRandom(limit: limit);
  Future<List<Question>> getWrongQuestions({int limit = 20}) => _questionDao.getWrongQuestions(limit: limit);
  Future<List<Question>> getBySourceFile(int docId) => _questionDao.getBySourceFile(docId);
  Future<List<Question>> getByIds(List<int> ids) => _questionDao.getByIds(ids);
  Future<int> insert(Question q) => _questionDao.insert(q);
  Future<void> batchInsert(List<Question> questions) => _questionDao.batchInsert(questions);

  /// 去重插入：基于 contentHash 判断是否已存在。
  Future<int> addQuestion(Question q) => _questionDao.upsertWithDedup(q);

  /// 批量去重插入。
  Future<void> batchAddQuestions(List<Question> questions) async {
    for (final q in questions) {
      await _questionDao.upsertWithDedup(q);
    }
  }

  Future<void> markWrong(int questionId) => _wrongDao.upsert(questionId);
  Future<void> clearWrong(int questionId) => _wrongDao.clear(questionId);
}