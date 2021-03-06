import 'package:meta/meta.dart';

const String BASE_URL = 'https://open.hpi.de/courses/';

@immutable
class OpenHpiCourse {
  final String title;
  final Uri link;
  final DateTime startAt;
  final Uri imageUrl;
  final String language;
  final String status;

  const OpenHpiCourse({
    @required this.title,
    @required this.link,
    @required this.startAt,
    @required this.imageUrl,
    @required this.language,
    @required this.status,
  })  : assert(title != null),
        assert(link != null),
        assert(startAt != null),
        assert(imageUrl != null),
        assert(language != null),
        assert(status != null);

  factory OpenHpiCourse.fromJson(Map<String, dynamic> parsedJson) {
    return OpenHpiCourse(
      title: parsedJson['title'] as String,
      link: Uri.parse(BASE_URL + (parsedJson['slug'] as String)),
      startAt: DateTime.parse(parsedJson['start_at'] as String),
      imageUrl: Uri.parse(parsedJson['image_url'] as String),
      language: parsedJson['language'] as String,
      status: parsedJson['status'] as String,
    );
  }
}
