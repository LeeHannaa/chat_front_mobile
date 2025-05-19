import 'dart:convert';
import 'dart:developer';
import 'package:chat_application/apis/noteApi.dart';
import 'package:chat_application/model/model_apt.dart';
import 'package:chat_application/src/data/keyData.dart';
import 'package:flutter/material.dart';
import 'package:chat_application/size_config.dart';
import 'package:go_router/go_router.dart';
import '../component/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AptDetailPage extends StatefulWidget {
  const AptDetailPage({super.key, required this.aptName, required this.aptId});
  final int aptId; // 매물 id
  final String aptName;

  @override
  State<AptDetailPage> createState() => _AptDetailPageState();
}

class _AptDetailPageState extends State<AptDetailPage> {
  int? myId;
  // myId 불러오는 함수
  Future<void> _loadMyId() async {
    myId = await SharedPreferencesHelper.getMyId();
  }

  Apt? _apt;
  Future<void> fetchData() async {
    final apiAddress = dotenv.get('API_ANDROID_ADDRESS');

    final response =
        await http.get(Uri.parse('$apiAddress/apt/detail/${widget.aptId}'));

    if (response.statusCode == 200) {
      setState(() {
        _apt = Apt.fromJson(json.decode(response.body));
        log(response.body);
      });
    } else {
      log('Failed to load data: ${response.statusCode}');
    }
  }

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  Future<void> sendNote() async {
    final phone = phoneController.text.replaceAll(RegExp(r'\D'), ''); // 숫자만
    final note = noteController.text.trim();

    if (phone.isEmpty || note.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('전화번호와 문의 내용을 입력해주세요.')),
      );
      return;
    }

    bool response = await postNoteByNonMember(widget.aptId, phone, note);

    if (response) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('쪽지를 전송했습니다!')),
      );
      phoneController.clear();
      noteController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('전송에 실패했습니다.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMyId();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context); // 화면 크기 설정
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                  myId != null
                      ? _apt!.userId == myId
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 10),
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
                                      'myId': myId,
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
                            )
                      : SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  labelText: '전화번호 입력 (숫자만)',
                                ),
                              ),
                              TextField(
                                controller: noteController,
                                maxLines: 3,
                                decoration: const InputDecoration(
                                  labelText: '문의 내용을 입력하세요',
                                  alignLabelWithHint: true,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: sendNote,
                                child: const Text('쪽지 문의'),
                              ),
                            ],
                          ),
                        ),
                ],
              ),
      ),
    );
  }
}
