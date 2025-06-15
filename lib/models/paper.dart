// paper.dart
class Paper {
  final String title;
  final String authors;
  final String abstractText;
  final String link;
  final int? year;
  final int? citations;

  Paper({
    required this.title,
    required this.authors,
    required this.abstractText,
    required this.link,
    this.year,
    this.citations,
  });

  factory Paper.fromJson(Map<String, dynamic> json) {
    return Paper(
      title: json['title']?.toString() ?? '',
      authors: json['authors']?.toString() ?? 'Unknown Authors',
      abstractText: json['analysis']?.toString() ?? json['abstract']?.toString() ?? '',
      link: json['url']?.toString() ?? json['link']?.toString() ?? '',
      year: json['year'] as int?,
      citations: json['citations'] as int?,
    );
  }

  // Helper method to create from API response
  factory Paper.fromApiResponse(String key, Map<String, dynamic> data) {
    return Paper(
      title: data['title']?.toString() ?? 'Untitled',
      authors: data['authors']?.toString() ?? 'Unknown Authors',
      abstractText: data['analysis']?.toString() ?? '',
      link: data['url']?.toString() ?? '',
      year: data['year'] as int?,
      citations: data['citations'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'authors': authors,
      'abstract': abstractText,
      'link': link,
      'year': year,
      'citations': citations,
    };
  }

  @override
  String toString() {
    return 'Paper(title: $title, authors: $authors, year: $year, citations: $citations)';
  }
}