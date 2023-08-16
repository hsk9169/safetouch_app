class TablingReply {
  final String replyDiv;
  final String waitMin;
  final String etcMsg;

  TablingReply(
      {required this.replyDiv, required this.waitMin, required this.etcMsg});

  factory TablingReply.fromJson(Map<String, dynamic> json) {
    return json['vacancy_div'] != null
        ? TablingReply(
            replyDiv: json['vacancy_div'],
            waitMin: json['wait_min'] ?? '',
            etcMsg: json['etc_msg'] ?? '')
        : TablingReply(
            replyDiv: json['book_div'],
            waitMin: json['wait_min'] ?? '',
            etcMsg: json['etc_msg'] ?? '');
  }
}
