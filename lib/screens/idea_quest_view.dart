import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:safetouch/models/ad_store_info.dart';
import 'package:safetouch/providers/platform_provider.dart';
import 'package:safetouch/providers/session_provider.dart';
import 'package:safetouch/consts/sizes.dart';
import 'package:safetouch/widgets/basic_struct.dart';
import 'package:safetouch/widgets/bottom_buttons.dart';
import 'package:safetouch/widgets/contained_button.dart';
import 'package:safetouch/widgets/title_band.dart';
import 'package:safetouch/widgets/pop_dialog.dart';
import 'package:safetouch/models/models.dart';
import 'package:safetouch/services/api_service.dart';

class IdeaQuestView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _IdeaQuestView();
}

class _IdeaQuestView extends State<IdeaQuestView> {
  final ApiService _apiService = ApiService();
  bool _isQuestOpened = false;
  bool _isEventOpened = false;
  bool _isIdeaOpened = false;
  late TextEditingController _ideaTextController;
  String _idea = '';
  final Uri _custUrl =
      Uri.parse('http://itgocorp.com/app/research.php?sort=user');
  final Uri _storeUrl =
      Uri.parse('http://itgocorp.com/app/research.php?sort=store');

  @override
  void initState() {
    super.initState();
    _initData();
    _ideaTextController = TextEditingController(text: _idea);
    _ideaTextController.addListener(_onIdeaChanged);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      //Provider.of<Platform>(context, listen: false).isLoading = true;
    });
  }

  void _initData() {
    //_dataFuture = _getAdStoreInfo();
  }

  void _launchQuestUrl() {
    final userDiv = Provider.of<Platform>(context, listen: false).userDiv;
    launchUrl(userDiv == '1' ? _storeUrl : _custUrl).then((value) {
      if (!value) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('설문조사 링크를 열 수가 없습니다.'),
            backgroundColor: Colors.black87.withOpacity(0.6),
            duration: const Duration(seconds: 2)));
      }
    });
  }

  void _onIdeaChanged() {
    setState(() => _idea = _ideaTextController.text);
  }

  void _onTapPostIdea() {
    final sessionProvider = Provider.of<Session>(context, listen: false);
    final platformProvider = Provider.of<Platform>(context, listen: false);
    platformProvider.isLoading = true;
    _apiService
        .postCustIdea(
            platformProvider.userDiv,
            sessionProvider.sessionData.userId,
            sessionProvider.sessionData.userToken,
            _idea)
        .then((value) {
      if (value is String) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(value),
            backgroundColor: Colors.black87.withOpacity(0.6),
            duration: const Duration(seconds: 2)));
      } else {
        _renderDialog();
      }
    }).whenComplete(() => platformProvider.isLoading = false);
  }

  void _renderDialog() {
    final userDiv = Provider.of<Platform>(context, listen: false).userDiv;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return PopDialog(
              image: AssetImage('asset/icons/love.png'),
              imageColor: Color.fromARGB(255, 130, 66, 221),
              textWidget: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                        userDiv == '1'
                            ? '상점주님 소중한 답변 감사합니다.'
                            : '고객님 소중한 답변 감사합니다.',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: context.contentsTextSize * 1.2,
                            fontWeight: FontWeight.bold)),
                    Padding(
                      padding: EdgeInsets.all(context.hPadding * 0.1),
                    ),
                    Text('스마트사이니지 서비스 개발에',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: context.contentsTextSize * 1.2,
                            fontWeight: FontWeight.bold)),
                    Padding(
                      padding: EdgeInsets.all(context.hPadding * 0.1),
                    ),
                    Text('많은 도움이 됩니다.',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: context.contentsTextSize * 1.2,
                            fontWeight: FontWeight.bold)),
                  ]),
              onPressed: () {
                Navigator.pop(context);
                context.goNamed('main');
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    final userDiv = Provider.of<Platform>(context, listen: false).userDiv;
    return BasicStruct(
        isMenuList: true,
        appbarColor: Colors.white,
        childWidget: SingleChildScrollView(
            controller: ScrollController(),
            child:
                //FutureBuilder(
                //    future: _dataFuture,
                //    builder:
                //        (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                //      if (snapshot.data != null) {
                //        return
                Container(
                    color: Colors.white,
                    width: context.pWidth,
                    child: Column(children: [
                      TitleBand(
                          color: Colors.black12,
                          text: userDiv == '1'
                              ? '상점주님 서비스이용 감사합니다'
                              : '고객님 서비스이용 감사합니다',
                          image: Image(
                              image: AssetImage('asset/icons/smile.png'),
                              width: context.pWidth * 0.2,
                              height: context.pWidth * 0.2)),
                      _renderInfo(),
                      TitleBand(
                          color: Color.fromARGB(255, 130, 66, 221),
                          text: '설문조사',
                          textColor: Colors.white,
                          tailWidget: _renderToggleQuest(),
                          image: Image(
                              color: Colors.white,
                              image: AssetImage('asset/icons/letter.png'),
                              width: context.pWidth * 0.2,
                              height: context.pWidth * 0.2)),
                      _renderQuestBody(),
                      Padding(
                        padding: EdgeInsets.all(context.hPadding * 0.7),
                      ),
                      TitleBand(
                          color: Color.fromARGB(255, 130, 66, 221),
                          text: '이벤트',
                          textColor: Colors.white,
                          tailWidget: _renderToggleEvent(),
                          image: Image(
                              color: Colors.white,
                              image: AssetImage('asset/icons/crown.png'),
                              width: context.pWidth * 0.2,
                              height: context.pWidth * 0.2)),
                      _renderEventBody(),
                      Padding(
                        padding: EdgeInsets.all(context.hPadding * 0.7),
                      ),
                      TitleBand(
                          color: Color.fromARGB(255, 130, 66, 221),
                          text: '아이디어',
                          textColor: Colors.white,
                          tailWidget: _renderToggleIdea(),
                          image: Image(
                              color: Colors.white,
                              image: AssetImage('asset/icons/mad.png'),
                              width: context.pWidth * 0.2,
                              height: context.pWidth * 0.2)),
                      _renderIdeaBody(),
                      Padding(
                        padding: EdgeInsets.all(context.hPadding * 0.7),
                      ),
                      BottomButtons(
                          btn3Enabled: true,
                          btn3Text:
                              userDiv == '1' ? '상점 이용안내 바로가기' : '고객 이용안내 바로가기',
                          btn3Color: Colors.black,
                          btn3Pressed: () => context.goNamed('main'))
                    ]))));
  }

  Widget _renderInfo() {
    return Container(
        width: context.pWidth,
        padding: EdgeInsets.all(context.hPadding * 1.2),
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
                child: Text('스마트사이니지, 빈자리확인 예약 문의앱 설문조사 / 이벤트 / 아이디어 접수 입니다',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: context.hPadding * 0.65,
                        fontWeight: FontWeight.normal))),
          ],
        ));
  }

  Widget _renderToggleQuest() {
    return InkWell(
        onTap: () => setState(() => _isQuestOpened = !_isQuestOpened),
        child: Container(
            padding: EdgeInsets.only(
              top: context.hPadding * 0.1,
              bottom: context.hPadding * 0.1,
              left: context.hPadding * 0.6,
              right: context.hPadding * 0.2,
            ),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(5),
                color: Colors.transparent),
            child: Row(
              children: [
                Text('내용보기',
                    style: TextStyle(
                        fontSize: context.contentsTextSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Icon(
                    _isQuestOpened
                        ? Icons.arrow_drop_up_outlined
                        : Icons.arrow_drop_down_outlined,
                    color: Colors.white,
                    size: context.contentsIconSize)
              ],
            )));
  }

  Widget _renderToggleEvent() {
    return InkWell(
        onTap: () => setState(() => _isEventOpened = !_isEventOpened),
        child: Container(
            padding: EdgeInsets.only(
              top: context.hPadding * 0.1,
              bottom: context.hPadding * 0.1,
              left: context.hPadding * 0.6,
              right: context.hPadding * 0.2,
            ),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(5),
                color: Colors.transparent),
            child: Row(
              children: [
                Text('내용보기',
                    style: TextStyle(
                        fontSize: context.contentsTextSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Icon(
                    _isEventOpened
                        ? Icons.arrow_drop_up_outlined
                        : Icons.arrow_drop_down_outlined,
                    color: Colors.white,
                    size: context.contentsIconSize)
              ],
            )));
  }

  Widget _renderToggleIdea() {
    return InkWell(
        onTap: () => setState(() => _isIdeaOpened = !_isIdeaOpened),
        child: Container(
            padding: EdgeInsets.only(
              top: context.hPadding * 0.1,
              bottom: context.hPadding * 0.1,
              left: context.hPadding * 0.6,
              right: context.hPadding * 0.2,
            ),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(5),
                color: Colors.transparent),
            child: Row(
              children: [
                Text('내용보기',
                    style: TextStyle(
                        fontSize: context.contentsTextSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Icon(
                    _isIdeaOpened
                        ? Icons.arrow_drop_up_outlined
                        : Icons.arrow_drop_down_outlined,
                    color: Colors.white,
                    size: context.contentsIconSize)
              ],
            )));
  }

  Widget _renderQuestBody() {
    return _isQuestOpened
        ? Container(
            width: context.pWidth,
            color: Color.fromARGB(255, 235, 237, 253),
            padding: EdgeInsets.only(
              top: context.hPadding * 1.6,
              bottom: context.hPadding * 1.6,
              left: context.hPadding * 1.2,
              right: context.hPadding * 1.2,
            ),
            child: ContainedButton(
              boxWidth: context.pWidth,
              onPressed: () => _launchQuestUrl(),
              color: Color.fromARGB(255, 130, 66, 221),
              text: '설문조사 참여하기',
              textSize: context.contentsTextSize,
              suffixImage: Container(
                  margin: EdgeInsets.only(left: context.hPadding * 0.5),
                  child: Image(
                      image: AssetImage('asset/icons/door.png'),
                      color: Colors.white,
                      width: context.pWidth * 0.05,
                      height: context.pWidth * 0.05)),
            ))
        : const SizedBox();
  }

  Widget _renderEventBody() {
    return _isEventOpened
        ? Container(
            width: context.pWidth,
            color: Color.fromARGB(255, 235, 237, 253),
            padding: EdgeInsets.only(
              top: context.hPadding,
              bottom: context.hPadding,
              left: context.hPadding * 1.2,
              right: context.hPadding * 1.2,
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('images required',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: context.contentsTextSize,
                      fontWeight: FontWeight.bold)),
            ]))
        : const SizedBox();
  }

  Widget _renderIdeaBody() {
    return _isIdeaOpened
        ? Container(
            width: context.pWidth,
            color: Color.fromARGB(255, 235, 237, 253),
            padding: EdgeInsets.only(
              top: context.hPadding,
              bottom: context.hPadding,
              left: context.hPadding * 1.2,
              right: context.hPadding * 1.2,
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              TextField(
                  controller: _ideaTextController,
                  textAlignVertical: TextAlignVertical.top,
                  maxLines: 5,
                  decoration: InputDecoration(
                    fillColor: Colors.transparent,
                    filled: false,
                    hintText: '아이디어를 작성해주세요.',
                    hintStyle: const TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.normal),
                    constraints: BoxConstraints(
                      maxWidth: context.pWidth,
                      maxHeight: context.pHeight * 0.2,
                    ),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 1),
                        borderRadius:
                            BorderRadius.circular(context.pWidth * 0.02)),
                  ),
                  keyboardType: TextInputType.text,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: context.hPadding * 0.7,
                      fontWeight: FontWeight.bold)),
              Padding(padding: EdgeInsets.all(context.hPadding * 0.5)),
              ContainedButton(
                boxWidth: context.pWidth,
                onPressed: () => _idea.isNotEmpty ? _onTapPostIdea() : null,
                color: _idea.isNotEmpty
                    ? Color.fromARGB(255, 130, 66, 221)
                    : Colors.grey,
                text: '아이디어 전송하기',
                textSize: context.contentsTextSize,
              )
            ]))
        : const SizedBox();
  }
}
