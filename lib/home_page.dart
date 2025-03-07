import 'package:flutter/material.dart';
import 'package:chat_application/size_config.dart';
import 'package:go_router/go_router.dart';
import 'src/widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
          children: <Widget>[
            const Header("디디하우스 페이지"),
            Builder(
              builder: (context) {
                return GestureDetector(
                  onTap: () {
                    context.push('/apt');
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
                    child: const Center(
                      child: Text(
                        '장성동 매물',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
