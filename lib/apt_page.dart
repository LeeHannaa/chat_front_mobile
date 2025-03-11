import 'package:flutter/material.dart';
import 'package:chat_application/size_config.dart';
import 'package:go_router/go_router.dart';
import 'src/widgets.dart';

class AptPage extends StatefulWidget {
  const AptPage({super.key});
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
        title: const Text('장성동 현대아파트 매물'),
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
            const Header("매물 세부 정보 있는 페이지"),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // TODO : 각 매물마다 연결되는 채팅 방 번호나, 유저의 번호? 생각해 볼 것
                ElevatedButton(
                  onPressed: () {
                    context.push('/chat',
                        extra: {'id': 3, 'name': '동그라미하우스'}); // 채팅 페이지로 이동
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
