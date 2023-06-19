class PostReport{
  final List<String> reporters;
  final String postId;
  final String postCreator;
  final List<String> reportReason;
  final List<String> reportComment;
  final int count;


  PostReport({
    required this.reporters,
    required this.postId,
    required this.postCreator,
    required this.reportReason,
    required this.reportComment,
    required this.count,
  });

  factory PostReport.fromJson(Map<String, dynamic> json) {
    return PostReport(
      reporters: List<String>.from(json['reporters']),
      postId: json['postId'],
      postCreator: json['postCreator'],
      reportReason: List<String>.from(json['reportReason']),
      reportComment: List<String>.from(json['reportComment']),
      count: json['count'],
    );
  }
}