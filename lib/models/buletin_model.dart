class BuletinModel {
  final String title;
  final String date;
  final String excerpt;
  final String author;
  final String link;

  BuletinModel({
    required this.title,
    required this.date,
    required this.excerpt,
    required this.author,
    required this.link,
  });

  factory BuletinModel.fromJson(Map<String, dynamic> json) {
    return BuletinModel(
      title: json['title'],
      date: json['date'],
      excerpt: json['excerpt'],
      author: json['author'],
      link: json['link'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': date,
      'excerpt': excerpt,
      'author': author,
      'link': link,
    };
  }
}
