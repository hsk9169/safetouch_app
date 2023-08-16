import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:safetouch/consts/sizes.dart';
import 'package:safetouch/services/api_service.dart';
import 'package:safetouch/widgets/basic_struct.dart';
import 'package:safetouch/providers/platform_provider.dart';
import 'package:safetouch/widgets/main_card.dart';
import 'package:safetouch/widgets/pop_dialog.dart';

class MainView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainView();
}

class _MainView extends State<MainView> {
  ApiService _apiService = ApiService();

  @override
  void initState() {
    _checkQrLink();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  void _checkQrLink() {
    if (!Provider.of<Platform>(context, listen: false).qrCheck &&
        Provider.of<Platform>(context, listen: false).userDiv == '2') {
      _apiService.checkLinkAvailable().then((value) async {
        if (value) {
          final link = Uri.parse('http://itgocorp.com/app.php');
          if (!await launchUrl(link, mode: LaunchMode.externalApplication)) {
            throw Exception('Could not launch link');
          }
        }
      }).whenComplete(() {
        Provider.of<Platform>(context, listen: false).qrCheck = true;
      });
    }
  }

  void _renderDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return PopDialog(
            image: AssetImage('asset/icons/document.png'),
            imageColor: Colors.black,
            textWidget: Column(children: [
              Padding(padding: EdgeInsets.all(context.hPadding * 0.2)),
              Text('이용안내',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: context.contentsTextSize * 1.6,
                      fontWeight: FontWeight.bold)),
              Padding(padding: EdgeInsets.all(context.hPadding * 0.2)),
              Text('스마트사이니지 세이프터치 기기에서',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: context.contentsTextSize * 1.2,
                      fontWeight: FontWeight.bold)),
              Text('QR스캔으로 이용하는 앱입니다.',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: context.contentsTextSize * 1.2,
                      fontWeight: FontWeight.bold)),
              Padding(padding: EdgeInsets.all(context.hPadding * 0.2)),
              Text('주변 스마트사이니지 세이프터치',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: context.contentsTextSize * 1.1,
                      fontWeight: FontWeight.normal)),
              Text('상점정보에서 방문하고싶은 상점을 터치!',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: context.contentsTextSize * 1.1,
                      fontWeight: FontWeight.normal)),
              Text('QR스캔하면 빈자리확인, 예약, 문의',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: context.contentsTextSize * 1.1,
                      fontWeight: FontWeight.normal)),
              Text('화면으로 자동연결후 앱설치하고',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: context.contentsTextSize * 1.1,
                      fontWeight: FontWeight.normal)),
              Text('이용하세요',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: context.contentsTextSize * 1.1,
                      fontWeight: FontWeight.normal)),
            ]),
            onPressed: () => Navigator.pop(context),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final userDiv = Provider.of<Platform>(context, listen: false).userDiv;
    return BasicStruct(
        isMenuList: true,
        appbarColor: userDiv == '1' ? Colors.orange : Colors.yellow,
        childWidget: Container(
            width: context.pWidth,
            padding: EdgeInsets.only(
              left: context.hPadding,
              right: context.hPadding,
              top: context.vPadding * 2,
            ),
            child:
                userDiv == '1' ? _renderStoreMenu() : _renderCustomerMenu()));
  }

  Widget _renderStoreMenu() {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Image(
              image: AssetImage('asset/icons/smile.png'),
              width: context.pWidth * 0.1,
              height: context.pWidth * 0.1),
          Padding(
            padding: EdgeInsets.all(context.hPadding * 0.3),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('상점 이용안내',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: context.vPadding * 1.6,
                    fontWeight: FontWeight.bold)),
            Text('상점주님 환영합니다',
                style: TextStyle(
                    color: Colors.black54,
                    fontSize: context.vPadding,
                    fontWeight: FontWeight.normal))
          ])
        ]),
        Padding(
          padding: EdgeInsets.all(context.vPadding),
        ),
        MainCard(
            onPressed: () => context.goNamed('add_store'),
            title: '상점 정보 등록하기',
            content: '상점 정보를 등록하여 자신의 상점을\n마케팅 해보세요',
            image: Image(
                image: AssetImage('asset/icons/phone.png'),
                width: context.pWidth * 0.2,
                height: context.pWidth * 0.2),
            color: Colors.green),
        Padding(
          padding: EdgeInsets.all(context.vPadding),
        ),
        Row(
          children: [
            Expanded(
                child: MainCard(
                    onPressed: () => context.goNamed('add_event'),
                    title: '이벤트 등록',
                    content: '이벤트를 등록하여\n매출 상승시키기',
                    image: Image(
                        image: AssetImage('asset/icons/crown.png'),
                        width: context.pWidth * 0.2,
                        height: context.pWidth * 0.2),
                    color: Colors.orange)),
            Padding(
              padding: EdgeInsets.all(context.hPadding * 0.5),
            ),
            Expanded(
                child: MainCard(
                    onPressed: () => context.goNamed('reserv_store_avail'),
                    title: '예약 내역',
                    titleColor: Colors.black,
                    content: '예약 내역을 한눈에\n확인해보기',
                    image: Image(
                        image: AssetImage('asset/icons/search.png'),
                        width: context.pWidth * 0.2,
                        height: context.pWidth * 0.2),
                    color: Colors.yellow)),
          ],
        ),
        Padding(
          padding: EdgeInsets.all(context.vPadding),
        ),
        Row(
          children: [
            Expanded(
                child: MainCard(
              onPressed: () => context.goNamed('app_review_view'),
              title: '설문조사, 이벤트,\n아이디어',
              content: '편리한 서비스제공을\n위해 참여해주세요',
              image: Image(
                  image: AssetImage('asset/icons/fun.png'),
                  width: context.pWidth * 0.2,
                  height: context.pWidth * 0.2),
              color: Color.fromARGB(255, 130, 66, 221),
            )),
            Padding(
              padding: EdgeInsets.all(context.hPadding * 0.5),
            ),
            Expanded(
                child: MainCard(
                    onPressed: () => context.goNamed('table_store_avail'),
                    title: '고객 빈자리 확인 내역',
                    content: '방문전 빈자리확인을\n요청하셨어요',
                    image: Image(
                        image: AssetImage('asset/icons/love.png'),
                        width: context.pWidth * 0.2,
                        height: context.pWidth * 0.2),
                    color: Colors.green)),
          ],
        )
      ],
    );
  }

  Widget _renderCustomerMenu() {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Image(
              image: AssetImage('asset/icons/smile.png'),
              width: context.pWidth * 0.1,
              height: context.pWidth * 0.1),
          Padding(
            padding: EdgeInsets.all(context.hPadding * 0.3),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('고객 이용안내',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: context.vPadding * 1.6,
                    fontWeight: FontWeight.bold)),
            Text('고객님 환영합니다',
                style: TextStyle(
                    color: Colors.black54,
                    fontSize: context.vPadding,
                    fontWeight: FontWeight.normal))
          ])
        ]),
        Padding(
          padding: EdgeInsets.all(context.vPadding),
        ),
        MainCard(
            onPressed: () => _renderDialog(),
            //onPressed: () => context.goNamed('request_book'),
            title: '상점 빈자리 확인, 예약, 문의',
            content:
                '스마트사이니지 상점정보에서 방문하고싶은 상점을 터치!\nQR스캔하면 빈자리확인, 예약, 문의 화면으로 자동연결',
            image: Image(
                image: AssetImage('asset/icons/calendar.png'),
                width: context.pWidth * 0.2,
                height: context.pWidth * 0.2),
            color: Colors.green),
        Padding(
          padding: EdgeInsets.all(context.vPadding),
        ),
        Row(
          children: [
            Expanded(
                child: MainCard(
                    onPressed: () => context.goNamed('noti_setting_view'),
                    title: '정보수신 서비스',
                    content: '단 한사람만을 위한\n광고 맞춤 서비스',
                    image: Image(
                        image: AssetImage('asset/icons/key.png'),
                        width: context.pWidth * 0.2,
                        height: context.pWidth * 0.2),
                    color: Color.fromARGB(255, 109, 143, 206))),
            Padding(
              padding: EdgeInsets.all(context.hPadding * 0.5),
            ),
            Expanded(
                child: MainCard(
                    onPressed: () => context.goNamed('reserv_cust_avail'),
                    title: '예약 내역',
                    titleColor: Colors.black,
                    content: '예약 내역을 한눈에\n확인해보기',
                    image: Image(
                        image: AssetImage('asset/icons/search.png'),
                        width: context.pWidth * 0.2,
                        height: context.pWidth * 0.2),
                    color: Colors.yellow)),
          ],
        ),
        Padding(
          padding: EdgeInsets.all(context.vPadding),
        ),
        Row(
          children: [
            Expanded(
                child: MainCard(
                    onPressed: () => context.goNamed('app_review_view'),
                    title: '설문조사, 이벤트,\n아이디어',
                    content: '편리한 서비스제공을\n위해 참여해주세요',
                    image: Image(
                        image: AssetImage('asset/icons/fun.png'),
                        width: context.pWidth * 0.2,
                        height: context.pWidth * 0.2),
                    color: Color.fromARGB(255, 130, 66, 221))),
            Padding(
              padding: EdgeInsets.all(context.hPadding * 0.5),
            ),
            Expanded(
                child: MainCard(
                    onPressed: () => context.goNamed('table_cust_avail'),
                    title: '빈자리 확인 내역',
                    content: '방문전 빈자리확인을\n요청하셨어요',
                    image: Image(
                        image: AssetImage('asset/icons/love.png'),
                        width: context.pWidth * 0.2,
                        height: context.pWidth * 0.2),
                    color: Colors.green)),
          ],
        )
      ],
    );
  }
}
