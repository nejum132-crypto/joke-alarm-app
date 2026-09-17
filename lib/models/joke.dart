class Joke {
  final String id;
  final String content;

  const Joke({required this.id, required this.content});

  factory Joke.fromMap(Map<String, dynamic> map) {
    return Joke(id: map['id'] as String, content: map['content'] as String);
  }

  Map<String, dynamic> toMap() => {'id': id, 'content': content};
}
