import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:safetouch/providers/platform_provider.dart';
import 'package:safetouch/providers/session_provider.dart';
import 'package:safetouch/consts/sizes.dart';
import 'package:safetouch/widgets/basic_struct.dart';
import 'package:safetouch/widgets/bottom_buttons.dart';
import 'package:safetouch/widgets/title_band.dart';
import 'package:safetouch/widgets/pop_dialog.dart';
import 'package:safetouch/models/models.dart';
import 'package:safetouch/services/api_service.dart';

class AppReviewView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AppReviewView();
}

class _AppReviewView extends State<AppReviewView> {
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _initData();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<Platform>(context, listen: false).isLoading = true;
    });
  }

  void _initData() {}

  @override
  Widget build(BuildContext context) {
    return BasicStruct(
        isMenuList: true,
        appbarColor: Colors.white,
        childWidget: SingleChildScrollView(
            controller: ScrollController(), child: SizedBox()));
  }
}
