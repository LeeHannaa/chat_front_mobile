import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:chat_application/size_config.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import 'model/model_apt.dart';
import 'src/widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Apt> _apts = [];
  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('http://localhost:8080/apt'));

    if (response.statusCode == 200) {
      // JSON 형식의 응답을 Dart 객체로 변환하여 데이터 리스트에 저장
      setState(() {
        _apts = json
            .decode(response.body)
            .map<Apt>((json) => Apt.fromJson(json))
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
        title: Text(widget.title),
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
            itemCount: _apts.length,
            itemBuilder: (context, index) {
              final apt = _apts[index];
              return GestureDetector(
                onTap: () {
                  context.push('/apt',
                      extra: {'aptId': apt.id, 'aptName': apt.aptName});
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
                      apt.aptName,
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
