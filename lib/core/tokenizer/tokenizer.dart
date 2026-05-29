abstract class Tokenizer {
  List<String> tokenize(String text);
  String tokenizeToString(String text) => tokenize(text).join(' ');
}