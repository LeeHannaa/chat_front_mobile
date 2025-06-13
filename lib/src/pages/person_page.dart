import 'dart:convert';
import 'dart:developer';
import 'package:chat_application/apis/chatApi.dart';
import 'package:chat_application/model/model_user.dart';
import 'package:flutter/material.dart';
import 'package:chat_application/size_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../data/keyData.dart';

class PersonPage extends StatefulWidget {
  const PersonPage({super.key});

  @override
  State<PersonPage> createState() => _PersonPageState();
}

class _PersonPageState extends State<PersonPage> {
  int? myId;
  String? myName;
  Future<void> _loadMyIdAndMyName() async {
    myId = await SharedPreferencesHelper.getMyId();
    myName = await SharedPreferencesHelper.getMyName();
  }

  late List<User> _users = [];
  Future<void> fetchData() async {
    final apiAddress = dotenv.get('API_ANDROID_ADDRESS');
    final response = await http.get(Uri.parse('$apiAddress/user/all'));

    if (response.statusCode == 200) {
      // JSON 형식의 응답을 Dart 객체로 변환하여 데이터 리스트에 저장
      setState(() {
        _users = json
            .decode(response.body)
            .map<User>((json) => User.fromJson(json))
            .toList();
        log(response.body);
      });
    } else {
      log('Failed to load data: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMyIdAndMyName();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    // ui 구성
    return Scaffold(
      // 기본적인 앱 레이아웃
      appBar: AppBar(
        // 상단 바
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("개인 연락 테스트"),
        actions: [
          IconButton(
            icon: const Icon(Icons.wechat), // 채팅 아이콘
            onPressed: () => context.push('/chatlist'),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          ListView.builder(
            itemCount: _users.length,
            itemBuilder: (context, index) {
              final user = _users[index];
              return GestureDetector(
                onTap: () async {
                  var roomId = await fetchConnectUserChat(user.userIdx, myId!);
                  // TODO : 선택한 유저의 채팅방으로 이동
                  context.push('/chat', extra: {
                    'id': roomId,
                    'myId': myId,
                    'name': user.userId,
                    'from': "person"
                  });
                },
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "${user.userId} - 채팅ㄱ",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
