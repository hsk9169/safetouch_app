import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:safetouch/providers/platform_provider.dart';
import 'package:safetouch/providers/session_provider.dart';
import 'package:safetouch/consts/sizes.dart';
import 'package:safetouch/widgets/basic_struct.dart';
import 'package:safetouch/widgets/bottom_buttons.dart';
import 'package:safetouch/widgets/title_band.dart';
import 'package:safetouch/widgets/pop_dialog.dart';
import 'package:safetouch/widgets/book_card.dart';
import 'package:safetouch/models/models.dart';
import 'package:safetouch/services/api_service.dart';

class ReservationCustAvailabilityView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ReservationCustAvailabilityView();
}

class _ReservationCustAvailabilityView
    extends State<ReservationCustAvailabilityView> {
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

  void _updateReservationList() {
    Provider.of<Platform>(context, listen: false).isLoading = true;
    _reservationListFuture = _getReservationList();
    setState(() {});
  }

  void _onTapCall(String phoneNum) {
    if (phoneNum.isNotEmpty) {
      UrlLauncher.launchUrl(Uri(scheme: "tel", path: phoneNum));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('문의 전화번호 정보가 없습니다.'),
          backgroundColor: Colors.black87.withOpacity(0.6),
          duration: const Duration(seconds: 2)));
    }
  }

  void _onTapCheckReply(String id) {
    final sessionProvider = Provider.of<Session>(context, listen: false);
    final platformProvider = Provider.of<Platform>(context, listen: false);
    platformProvider.isLoading = true;
    _apiService
        .getReservationReply(
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
        _renderReplyDialog(value);
      }
    }).whenComplete(() => platformProvider.isLoading = false);
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

  void _renderReplyDialog(TablingReply data) {
    final title = [
      '',
      '고객님은 현재 이용 가능하십니다.',
      '고객님은 ${data.waitMin}분 이후 이용 가능하십니다.',
      '고객님 지금 만석입니다.',
      '고객님 재료소진 되었습니다.',
      '고객님 영업준비중 입니다.',
      '고객님 영업종료 입니다.',
      '',
      '',
      data.etcMsg
    ];
    final icon = [
      '',
      'fun',
      'smile',
      'cry',
      'cry',
      'cry',
      'cry',
      '',
      '',
      'smile'
    ];
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return PopDialog(
            image:
                AssetImage('asset/icons/${icon[int.parse(data.replyDiv)]}.png'),
            imageColor: Colors.black,
            textWidget: Column(children: [
              Text(title[int.parse(data.replyDiv)],
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: context.contentsTextSize * 1.2,
                      fontWeight: FontWeight.bold)),
            ]),
            onPressed: () {
              Navigator.pop(context);
            },
          );
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
                              text: '고객님 상점 예약 감사합니다',
                              image: Image(
                                  image: AssetImage('asset/icons/smile.png'),
                                  width: context.pWidth * 0.2,
                                  height: context.pWidth * 0.2)),
                          _renderInfo(),
                          TitleBand(
                              color: Colors.green,
                              text: '고객 예약 내역',
                              textColor: Colors.white,
                              image: Image(
                                  color: Colors.white,
                                  image: AssetImage('asset/icons/calendar.png'),
                                  width: context.pWidth * 0.2,
                                  height: context.pWidth * 0.2)),
                          _renderGuide(),
                          _renderTablingList(snapshot.data),
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
            Container(
                width: context.pWidth - context.hPadding * 3,
                child: Text('스마트사이니지 상점정보에서 방문하고싶은 상점을 보시고 빈자리확인, 예약을 해주세요',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: context.hPadding * 0.65,
                        fontWeight: FontWeight.normal))),
          ],
        ));
  }

  Widget _renderGuide() {
    return Container(
        width: context.pWidth,
        margin: EdgeInsets.all(context.hPadding * 1.5),
        padding: EdgeInsets.all(context.hPadding * 0.6),
        decoration: BoxDecoration(
            color: Colors.black87, borderRadius: BorderRadius.circular(5)),
        child: Text(
            "취소는 예약 내역 상단 오른쪽 취소 누르시고 변경은 상점문의 하시거나 취소후 다시 QR스캔후 '빈자리확인 / 예약 / 문의'에서 다시 신청해주세요",
            style: TextStyle(
                color: Colors.white, fontSize: context.contentsTextSize)));
  }

  Widget _renderTablingList(List<TablingInfo> list) {
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
            time: list[index].repliedTime,
            isCancelAvailable: true,
            isConfirmed: list[index].repliedFlag == '0',
            isPhoneAvail: true,
            onTapPhoneCall: () => _onTapCall(list[index].storePhone),
            storeName: list[index].storeName,
            openTime: bizTime,
            customerName: list[index].userName,
            phoneNum: list[index].userPhone,
            visitTime: visitTime,
            visitNum: list[index].personCnt,
            menu: list[index].menuName,
            cancelStr: '취소하기',
            confirmStr: '답변 확인하기',
            completeStr: '답변 대기중',
            onTapCancel: () => _onTapCancelReply(list[index].id),
            onTapButton: () => _onTapCheckReply(list[index].id),
          );
        })));
  }
}
