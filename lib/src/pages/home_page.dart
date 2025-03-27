import 'dart:developer';

import 'package:chat_application/src/data/keyData.dart';
import 'package:flutter/material.dart';
import 'package:chat_application/size_config.dart';
import 'package:go_router/go_router.dart';

import '../../../../apis/userApi.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _idController = TextEditingController();
  int? myId;
  String? myName;
  Future<void> _saveMyIdAndName(int myId, String myName) async {
    await SharedPreferencesHelper.saveMyId(myId);
    await SharedPreferencesHelper.saveMyName(myName);
    setState(() {
      this.myId = myId; // 데이터 저장 후 UI 갱신
      this.myName = myName;
    });
  }

  Future<void> _loadMyIdAndMyName() async {
    myId = await SharedPreferencesHelper.getMyId();
    myName = await SharedPreferencesHelper.getMyName();
  }

  @override
  void initState() {
    _loadMyIdAndMyName();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  /// API 호출 및 데이터 저장
  Future<void> _fetchUserData() async {
    String inputId = _idController.text.trim();
    if (inputId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID를 입력해주세요.')),
      );
      return;
    }
    try {
      final userData = await fetchUserInfo(int.parse(inputId));
      setState(() {
        log("userData 확인 : $userData");
        _saveMyIdAndName(userData['id'], userData['name']);
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('유저 정보를 불러오지 못했습니다.')),
      );
    }
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
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.wechat), // 채팅 아이콘
            onPressed: () => context.push('/chatlist'),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Column의 크기를 최소화하여 중앙 정렬 효과
          children: [
            ElevatedButton(
              onPressed: () {
                context.push('/aptlist');
              },
              child: const Text('매물 페이지 이동'),
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 200, // 입력창 너비
                  height: 40, // 입력창 높이
                  child: TextField(
                    controller: _idController,
                    decoration: const InputDecoration(
                      labelText: '개인 ID 입력',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onSubmitted: (_) => _fetchUserData(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _fetchUserData,
                  child: const Text('불러오기'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            (myId != null && myName != null)
                ? Column(
                    children: [
                      Text(myId.toString()),
                      Text(myName!),
                    ],
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
