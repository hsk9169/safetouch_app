class NumberHandler {
  String addComma(String value) {
    String ret = '';
    List<String> temp = [];
    final count = value.length ~/ 3;
    if (count == 0) {
      ret = value;
    }
    final remainder = value.length % 3;
    for (int i = 0; i < count; i++) {
      temp.add(
          value.substring(value.length - 3 * (i + 1), value.length - 3 * i));
      if (i + 1 == count && remainder > 0) {
        temp.add(value.substring(0, remainder));
      }
    }
    temp.asMap().forEach((key, value) {
      ret = ret + temp[temp.length - key - 1];
      if (key < temp.length - 1) {
        ret += ',';
      }
    });
    return ret;
  }

  String dateToStr(String date) {
    String year = date.substring(0, 4);
    String month = date.substring(4, 6);
    String day = date.substring(6, 8);
    String time = date.substring(8);
    if (month.substring(0, 1) == '0') {
      month = month.substring(1);
    }
    time = '${time.substring(0, 2)}:${time.substring(2)}';
    return '${year}년 ${month}월 ${day}일 ${time}';
  }
}
