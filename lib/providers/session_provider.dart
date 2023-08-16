import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:safetouch/models/session_data.dart';
import 'package:safetouch/models/models.dart';

class Session extends ChangeNotifier {
  SessionData _sessionData = SessionData.initialize();
  StoreInfo _storeInfo = StoreInfo.initialize();
  CustomerInfo _customerInfo = CustomerInfo.initialize();

  SessionData get sessionData => _sessionData;
  StoreInfo get storeInfo => _storeInfo;
  CustomerInfo get customerInfo => _customerInfo;

  set sessionData(SessionData value) {
    _sessionData = value;
    notifyListeners();
  }

  set storeInfo(StoreInfo value) {
    _storeInfo = value;
    notifyListeners();
  }

  set customerInfo(CustomerInfo value) {
    _customerInfo = value;
    notifyListeners();
  }
}
