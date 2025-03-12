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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Header("${widget.aptName} 세부 정보 페이지"),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // TODO : 매물의 id랑 나의 userId를 같이 넘겨서 해당 id에 일치하는 방이 있으면 그 방을 전달받고 아니면 새로 방 생성
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
