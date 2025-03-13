import 'dart:convert';
import 'dart:developer';

import 'package:chat_application/model/model_apt.dart';
import 'package:flutter/material.dart';
import 'package:chat_application/size_config.dart';
import 'package:go_router/go_router.dart';
import 'src/widgets.dart';

import 'package:http/http.dart' as http;

class AptPage extends StatefulWidget {
  const AptPage({super.key, required this.aptName, required this.aptId});
  final int aptId; // 매물 id
  final String aptName;

  @override
  State<AptPage> createState() => _AptPageState();
}

class _AptPageState extends State<AptPage> {
  int myId = 1;
  Apt? _apt;
  Future<void> fetchData() async {
    final response = await http
        .get(Uri.parse('http://localhost:8080/apt/detail/${widget.aptId}'));

    if (response.statusCode == 200) {
      setState(() {
        _apt = Apt.fromJson(json.decode(response.body));
        log(response.body);
      });
    } else {
      log('Failed to load data: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context); // 화면 크기 설정
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.aptName),
        actions: [
          IconButton(
            icon: const Icon(Icons.wechat), // 채팅 아이콘
            onPressed: () => context.push('/chatlist'), // 채팅 리스트로 이동
          ),
        ],
      ),
      body: Center(
        child: _apt == null
            ? const Center(child: CircularProgressIndicator()) // 로딩 중일 때
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Header("${widget.aptName} 세부 정보 페이지"),
                  const SizedBox(height: 20),
                  _apt!.userId == myId
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {},
                              child: const Text("수정하기"),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                context.push('/chat', extra: {
                                  'id': widget.aptId,
                                  'name': widget.aptName,
                                  'from': 'apt'
                                }); // 채팅 페이지로 이동
                              },
                              child: const Text("채팅 문의"),
                            ),
                            const SizedBox(width: 20),
                            ElevatedButton(
                              onPressed: () {},
                              child: const Text("전화 문의"),
                            ),
                          ],
                        ),
                ],
              ),
      ),
    );
  }
}
