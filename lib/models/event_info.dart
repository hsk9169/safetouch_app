class EventInfo {
  String? eventId;
  String eventMsg;
  List<String>? eventImageGetList;
  List<EventImage>? eventImagePostList;
  String startTime;
  String endTime;
  String todayEventFlag;

  EventInfo({
    this.eventId,
    required this.eventMsg,
    this.eventImageGetList,
    this.eventImagePostList,
    required this.startTime,
    required this.endTime,
    required this.todayEventFlag,
  });

  factory EventInfo.initialize() {
    return EventInfo(
        eventId: '',
        eventMsg: '',
        eventImagePostList: [],
        startTime: '',
        endTime: '',
        todayEventFlag: '0');
  }

  factory EventInfo.fromJson(Map<String, dynamic> json) {
    return EventInfo(
      eventId: json['id'],
      eventMsg: json['event_msg'],
      eventImageGetList: json['event_images']
          .map<String>((element) => element.toString())
          .toList(),
      eventImagePostList: json['event_images']
          .map<EventImage>((element) => EventImage(fileName: element))
          .toList(),
      startTime: json['start_time'],
      endTime: json['end_time'],
      todayEventFlag: json['today_event_flag'],
    );
  }

  Map<String, dynamic> toJson() => eventId == null
      ? {
          'event_msg': eventMsg,
          'event_image_list':
              eventImagePostList!.map((element) => element.toJson()).toList(),
          'start_time': startTime,
          'end_time': endTime,
          'today_event_flag': todayEventFlag,
        }
      : {
          'id': eventId,
          'event_msg': eventMsg,
          'event_image_list':
              eventImagePostList!.map((element) => element.toJson()).toList(),
          'start_time': startTime,
          'end_time': endTime,
          'today_event_flag': todayEventFlag,
        };
}

class EventImage {
  String fileName;
  String? content;
  String? filePath;

  EventImage({
    required this.fileName,
    this.content,
    this.filePath,
  });

  factory EventImage.fromJson(Map<String, dynamic> json) {
    return EventImage(fileName: json['event_image']);
  }

  Map<String, dynamic> toJson() => content != null
      ? {
          'event_image': fileName,
          'attach_event_image': content,
        }
      : {
          'event_image': fileName,
        };
}
