import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:safetouch/providers/platform_provider.dart';
import 'package:safetouch/providers/session_provider.dart';
import 'package:safetouch/consts/sizes.dart';
import 'package:safetouch/widgets/basic_struct.dart';
import 'package:safetouch/widgets/bottom_buttons.dart';
import 'package:safetouch/widgets/title_band.dart';
import 'package:safetouch/widgets/book_card.dart';
import 'package:safetouch/models/models.dart';
import 'package:safetouch/services/api_service.dart';
import 'package:safetouch/widgets/pop_dialog.dart';

class ReservationStoreAvailabilityView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ReservationStoreAvailabilityView();
}

class _ReservationStoreAvailabilityView
    extends State<ReservationStoreAvailabilityView> {
  final ApiService _apiService = ApiService();
  late Future<dynamic> _reservationListFuture;

  @override
  void initState() {
    super.initState();
    _initData();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<Platform>(context, listen: false).isLoading = true;
    });
  }

  void _initData() {
    _reservationListFuture = _getReservationList();
  }

  Future<dynamic> _getReservationList() {
    final sessionProvider = Provider.of<Session>(context, listen: false);
    final platformProvider = Provider.of<Platform>(context, listen: false);
    return _apiService
        .getReservationList(
            platformProvider.userDiv,
            sessionProvider.sessionData.userId,
            sessionProvider.sessionData.userToken)
        .then((value) {
      if (value is String) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(value),
            backgroundColor: Colors.black87.withOpacity(0.6),
            duration: const Duration(seconds: 2)));
        return null;
      } else {
        return value;
      }
    }).whenComplete(() => platformProvider.isLoading = false);
  }

  FutureOr<dynamic> _updateReservationList() {
    Provider.of<Platform>(context, listen: false).isLoading = true;
    _reservationListFuture = _getReservationList();
    setState(() {});
  }

  void _onTapReply(String bookId) {
    context
        .pushNamed('reserv_answer_view', extra: bookId)
        .then((value) => _updateReservationList());
  }

  void _onTapCancelReply(String id) async {
    final sessionProvider = Provider.of<Session>(context, listen: false);
    final platformProvider = Provider.of<Platform>(context, listen: false);
    platformProvider.isLoading = true;
    await _apiService
        .cancelBook(
            platformProvider.userDiv,
            sessionProvider.sessionData.userId,
            sessionProvider.sessionData.userToken,
            id)
        .then((value) {
      if (value is String) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(value),
            backgroundColor: Colors.black87.withOpacity(0.6),
            duration: const Duration(seconds: 2)));
      } else {
        _renderCancelDialog();
      }
    }).whenComplete(() {
      platformProvider.isLoading = false;
      _updateReservationList();
    });
  }

  void _renderCancelDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return PopDialog(
            image: AssetImage('asset/icons/smile.png'),
            imageColor: Colors.black,
            textWidget: Column(children: [
              Text('예약이 취소되었습니다.',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: context.contentsTextSize * 1.2,
                      fontWeight: FontWeight.bold)),
            ]),
            onPressed: () => Navigator.pop(context),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return BasicStruct(
        isMenuList: true,
        appbarColor: Colors.white,
        childWidget: SingleChildScrollView(
            controller: ScrollController(),
            child: FutureBuilder(
                future: _reservationListFuture,
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.data != null) {
                    return Container(
                        color: Colors.white,
                        width: context.pWidth,
                        child: Column(children: [
                          TitleBand(
                              color: Colors.black12,
                              text: '상점주님 예약확인 답변해주세요',
                              image: Image(
                                  image: AssetImage('asset/icons/smile.png'),
                                  width: context.pWidth * 0.2,
                                  height: context.pWidth * 0.2)),
                          _renderInfo(),
                          TitleBand(
                              color: Colors.green,
                              text: '상점 예약 내역',
                              textColor: Colors.white,
                              image: Image(
                                  image: AssetImage('asset/icons/search.png'),
                                  color: Colors.white,
                                  width: context.pWidth * 0.2,
                                  height: context.pWidth * 0.2)),
                          _renderTableList(snapshot.data),
                          BottomButtons(
                              btn3Enabled: true,
                              btn3Text: '빈자리 확인 내역 바로가기',
                              btn3Color: Colors.black,
                              btn3Pressed: () =>
                                  context.goNamed('table_store_avail')),
                        ]));
                  } else {
                    return const SizedBox();
                  }
                })));
  }

  Widget _renderInfo() {
    return Container(
        width: context.pWidth,
        padding: EdgeInsets.all(context.hPadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('\u2022',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: context.hPadding * 0.7,
                    fontWeight: FontWeight.bold)),
            Padding(padding: EdgeInsets.all(context.hPadding * 0.1)),
            SizedBox(
                width: context.pWidth - context.hPadding * 3,
                child: Text('스마트사이니지 상점정보에서 방문하고싶은 상점을 보시고 빈자리확인, 예약을 하셨어요',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: context.hPadding * 0.65,
                        fontWeight: FontWeight.normal))),
          ],
        ));
  }

  Widget _renderTableList(List<TablingInfo> list) {
    return Container(
        padding: EdgeInsets.only(
          left: context.hPadding * 1.5,
          right: context.hPadding * 1.5,
        ),
        margin: EdgeInsets.only(
          top: context.vPadding * 2,
          bottom: context.vPadding * 2,
        ),
        child: Column(
            children: List.generate(list.length, (index) {
          final String bizTime =
              '${list[index].bizTime.substring(0, 2)}:${list[index].bizTime.substring(2, 4)} ~ ${list[index].bizTime.substring(4, 6)}:${list[index].bizTime.substring(
                    6,
                  )}';
          final String visitTime =
              '${list[index].visitTime.substring(0, 2)}:${list[index].visitTime.substring(2)}';
          return BookCard(
            time: list[index].requestTime,
            isCancelAvailable: list[index].canceledFlag == '1',
            isConfirmed: list[index].repliedFlag == '1',
            storeName: list[index].storeName,
            openTime: bizTime,
            customerName: list[index].userName,
            phoneNum: list[index].userPhone,
            visitTime: visitTime,
            visitNum: list[index].personCnt,
            menu: list[index].menuName,
            cancelStr: '예약 취소',
            confirmStr: '답변 전송하기',
            completeStr: '답변 완료',
            onTapCancel: null,
            onTapButton: () => _onTapReply(list[index].id),
          );
        })));
  }
}
