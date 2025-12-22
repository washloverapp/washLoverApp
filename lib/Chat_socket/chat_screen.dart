import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_flutter_mapwash/Chat_socket/controller.dart';
import 'package:my_flutter_mapwash/Chat_socket/socket.io.dart';
import 'package:my_flutter_mapwash/Profile/API/api_profile.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends ConsumerStatefulWidget {
  String device_id;
  ChatScreen(this.device_id, {super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatState();
}

class _ChatState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final _controller = TextEditingController();
  FocusNode myFocusNode = FocusNode();
  TrackingScrollController tk = TrackingScrollController();

  _onScroll() {
    // if (myFocusNode.hasFocus) {
    //   Scrollable.ensureVisible(
    //     context,
    //     duration: Duration(milliseconds: 300), // Optional smooth scrolling
    //     curve: Curves.easeOut, // Optional animation curve
    //   );
    // }
    if (tk.position.userScrollDirection == ScrollDirection.reverse) {
      // print('scrolled down');
      FocusScope.of(context).requestFocus(FocusNode());
      Scrollable.ensureVisible(
        myFocusNode.context!, // Use the context of the FocusNode
        duration: Duration(milliseconds: 1000),
        curve: Curves.fastLinearToSlowEaseIn,
      );
      // ref.read(slideTopProvider.notifier).state = false;
      //the setState function
    } else if (tk.position.userScrollDirection == ScrollDirection.forward) {
      // print('scrolled up');
      FocusScope.of(context).requestFocus(myFocusNode);
      Scrollable.ensureVisible(
        myFocusNode.context!, // Use the context of the FocusNode
        duration: Duration(milliseconds: 1000),
        curve: Curves.fastEaseInToSlowEaseOut,
      );
      // ref.read(slideTopProvider.notifier).state = true;
      //setState function
    }
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $launchUri';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    final service = SocketService();

    // Cleanup: เมื่อ Provider ถูก Dispose ให้ยกเลิกการเชื่อมต่อ
    service.disconnect();
    super.dispose();
  }

  Map<String, dynamic> profile = {};
  @override
  void initState() {
    super.initState();
    tk.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(chatNotifierProvider.notifier).clearChat();
      final service = SocketService();
      // เชื่อมต่อทันทีที่ Provider ถูกสร้างขึ้น
      profile = await api_profile.fetchProfile();
      print('sssss---s');
      print(widget.device_id);
      print(profile['nickname']);
      print('aaaaa---s');
      service.connect(profile['nickname'], widget.device_id, ref);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    double sizeH = MediaQuery.sizeOf(context).height;

    // Watch สถานะของข้อความทั้งหมด
    final messages = ref.watch(chatNotifierProvider);

    // อ่าน Notifier เพื่อเข้าถึงฟังก์ชัน send()
    final chatNotifier = ref.read(chatNotifierProvider.notifier);

    // สมมติว่านี่คือ ID ผู้ใช้งานปัจจุบันของคุณ

    var room = widget.device_id;
    var currentUsername = profile['nickname'];

    final Color senderColor = Color(0xFF42A5F5); // สีฟ้าสวยๆ
    final Color receiverColor = Colors.white; // สีเทาอ่อน

    print(messages.length);

    return PopScope(
      // canPop: false,
      child: Scaffold(
        body: Column(
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              // height: sizeH * .1 ,
              // height: slideTop ? sizeH * .12 : 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        spacing: 10,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Material(
                              color: CupertinoColors.systemGrey6,
                              elevation: 1,
                              // shadowColor: CupertinoColors.systemGrey6,
                              shape: CircleBorder(),
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: Center(
                                  child: Icon(
                                    Icons.chevron_left,
                                    color: CupertinoColors.secondaryLabel,
                                    size: sizeH * .03,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Row(
                            spacing: 5,
                            children: [
                              Icon(Icons.account_circle, color: Color(0xFF42A5F5), size: sizeH * .05),
                              Text(
                                'คนขับรถ',
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium!.copyWith(color: Colors.black54, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          showCupertinoModalPopup<void>(
                            context: context,
                            builder: (BuildContext context) => CupertinoActionSheet(
                              // title: const Text('โทรหา'),
                              message: Text(
                                'หมายเลขโทรศัพท์',
                                style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                              ),

                              actions: <CupertinoActionSheetAction>[
                                CupertinoActionSheetAction(
                                  /// This parameter indicates the action would be a default
                                  /// default behavior, turns the action's text to bold text.
                                  isDefaultAction: true,
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    makePhoneCall('0123456789');

                                    // launchUrl(Uri(scheme: 'tel', path: '0123456789'));
                                  },
                                  child: Text(
                                    '0123456789',
                                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                          color: Color(0xFF42A5F5),
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                                // CupertinoActionSheetAction(
                                //   onPressed: () {
                                //     Navigator.pop(context);
                                //   },
                                //   child: const Text('Action'),
                                // ),
                                // CupertinoActionSheetAction(
                                //   /// This parameter indicates the action would perform
                                //   /// a destructive action such as delete or exit and turns
                                //   /// the action's text color to red.
                                //   isDestructiveAction: true,
                                //   onPressed: () {
                                //     Navigator.pop(context);
                                //   },
                                //   child: const Text('Destructive Action'),
                                // ),
                              ],
                            ),
                          );
                          // launchUrl(Uri(scheme: 'tel', path: '0123456789'));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Icon(FontAwesomeIcons.phoneVolume, color: Color(0xFF42A5F5)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Expanded(
              child: Stack(
                children: [
                  ListView.builder(
                    controller: tk,

                    // keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    // reverse: true ทำให้ข้อความใหม่สุดอยู่ด้านล่าง
                    reverse: true,
                    // ต้องแสดงข้อความย้อนกลับ: messages.length - 1 - index
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      // print(jsonEncode(messages[index]));
                      // print(messages[index].msg);
                      //       //if (messages.length > 2) {
                      //   String Hour_before = messages[index - 2 - index].timestamp.hour.toString().padLeft(2, '0');
                      //   // Format the minute to be 2 digits
                      //   String Minute_before = messages[index - 2 - index].timestamp.minute.toString().padLeft(2, '0');
                      //   // String displayTime_before = '$Hour_before:$Minute_before';
                      // }

                      var message = messages[messages.length - 1 - index];
                      print(message.msg);
                      print(message.user);
                      print(message.timestamp);
                      var currentUsername = profile['nickname'];
                      final isSender = message.user == currentUsername;
                      final color = isSender ? senderColor : receiverColor;
                      final textColor = isSender ? Colors.white : Colors.black54;
                      final timeColor = isSender ? Colors.white54 : Colors.grey.shade500;

                      // Format the hour to be 2 digits
                      String formattedHour = message.timestamp.hour.toString().padLeft(2, '0');
                      // Format the minute to be 2 digits
                      String formattedMinute = message.timestamp.minute.toString().padLeft(2, '0');

                      String displayTime = '$formattedHour:$formattedMinute';

                      return Align(
                        alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
                            children: [
                              // แสดง Nip ทางซ้าย (ถ้าเป็นผู้รับ)
                              // if (!isSender)
                              //   CustomPaint(
                              //     size: const Size(10, 10),
                              //     painter: ChatNipPainter(bubbleColor: color, isSender: isSender),
                              //   ),

                              // จำกัดความกว้างของข้อความ
                              ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 0),
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(10),
                                      topRight: const Radius.circular(10),
                                      // กำหนดมุมให้ติดกับหาง (ถ้าเป็นผู้ส่ง: ล่างซ้ายกลม, ล่างขวาไม่มี. ถ้าผู้รับ: ล่างซ้ายไม่มี, ล่างขวากลม)
                                      bottomLeft: isSender ? const Radius.circular(10) : Radius.zero,
                                      bottomRight: isSender ? Radius.zero : const Radius.circular(10),
                                    ),
                                  ),
                                  child: SelectionArea(
                                    child: Column(
                                      crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          message.msg,
                                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                                color: textColor,
                                                fontWeight: FontWeight.normal,
                                              ),
                                        ),
                                        Text(
                                          displayTime,
                                          style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                                color: timeColor,
                                                fontWeight: FontWeight.normal,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // แสดง Nip ทางขวา (ถ้าเป็นผู้ส่ง)
                              // if (isSender)
                              //   CustomPaint(
                              //     size: const Size(10, 10),
                              //     painter: ChatNipPainter(bubbleColor: color, isSender: isSender),
                              //   ),
                            ],
                          ),
                        ),
                      );
                      // return ChatBubble(message: message);

                      // final message = messages[index];
                      // final isMe = message.senderId == currentUserId;
                      //
                      // return Align(
                      //   alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      //   child: Container(
                      //     padding: const EdgeInsets.all(10),
                      //     margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                      //     decoration: BoxDecoration(
                      //       color: isMe ? Colors.blue[100] : Colors.grey[200],
                      //       borderRadius: BorderRadius.circular(12),
                      //     ),
                      //     child: Text(message.text),
                      //   ),
                      // );
                    },
                  ),
                ],
              ),
            ),

            // ช่องสำหรับพิมพ์ข้อความ
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              decoration: const BoxDecoration(
                // color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFEFEFEF), width: 1.0)),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  spacing: 0,
                  children: <Widget>[
                    // ปุ่มแนบไฟล์
                    // IconButton(
                    //   icon: const Icon(Icons.add_circle_outline, color: Color(0xFF007AFF)),
                    //   onPressed: () {},
                    // ),

                    // Custom Styled TextField
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: TextField(
                          focusNode: myFocusNode,
                          controller: _controller,
                          // ใช้ Listener เพื่ออัพเดทปุ่มส่งข้อความ
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(color: Colors.grey),
                            hintText: 'พิมพ์ข้อความ...',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          keyboardType: TextInputType.multiline,
                          minLines: 1,
                          // Start with one line
                          maxLines: null, // Allow unlimited lines
                        ),
                      ),
                    ),

                    // ปุ่มส่งข้อความ (เปลี่ยนเป็นไอคอนไมค์เมื่อว่าง)
                    _controller.text.trim().isEmpty
                        ? IconButton(
                            icon: const Icon(Icons.send_rounded, color: Colors.grey),
                            onPressed: () {}, // สำหรับอัดเสียง
                          )
                        : IconButton(
                            icon: const Icon(Icons.send, color: Color(0xFF007AFF)),
                            onPressed: () {
                              final text = _controller.text.trim();
                              if (text.isNotEmpty) {
                                chatNotifier.send(_controller.text, currentUsername, room);

                                _controller.clear();
                                if (_scrollController.hasClients) {
                                  _scrollController.animateTo(
                                    _scrollController.position.minScrollExtent - 100,
                                    duration: Duration(milliseconds: 500),
                                    curve: Curves.fastLinearToSlowEaseIn,
                                  );
                                }

                                // ไม่ต้องเรียก setState() เพราะ onSend จะไปเรียก Riverpod และ rebuild UI เอง
                              }
                            },
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final Message message;
  final Color senderColor = Color(0xFF42A5F5); // สีฟ้าสวยๆ
  final Color receiverColor = Colors.white; // สีเทาอ่อน

  ChatBubble({required this.message, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSender = message.user == '';
    final color = isSender ? senderColor : receiverColor;
    final textColor = isSender ? Colors.white : Colors.black54;

    // Align เพื่อจัด Bubble ไปทางซ้ายหรือขวา
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            // แสดง Nip ทางซ้าย (ถ้าเป็นผู้รับ)
            // if (!isSender)
            //   CustomPaint(
            //     size: const Size(10, 10),
            //     painter: ChatNipPainter(bubbleColor: color, isSender: isSender),
            //   ),

            // จำกัดความกว้างของข้อความ
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 0),
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(10),
                    topRight: const Radius.circular(10),
                    // กำหนดมุมให้ติดกับหาง (ถ้าเป็นผู้ส่ง: ล่างซ้ายกลม, ล่างขวาไม่มี. ถ้าผู้รับ: ล่างซ้ายไม่มี, ล่างขวากลม)
                    bottomLeft: isSender ? const Radius.circular(10) : Radius.zero,
                    bottomRight: isSender ? Radius.zero : const Radius.circular(10),
                  ),
                ),
                child: Text(
                  message.msg,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium!.copyWith(color: textColor, fontWeight: FontWeight.normal),
                ),
              ),
            ),

            // แสดง Nip ทางขวา (ถ้าเป็นผู้ส่ง)
            // if (isSender)
            //   CustomPaint(
            //     size: const Size(10, 10),
            //     painter: ChatNipPainter(bubbleColor: color, isSender: isSender),
            //   ),
          ],
        ),
      ),
    );
  }
}

class ChatNipPainter extends CustomPainter {
  final Color bubbleColor;
  final bool isSender;

  ChatNipPainter({required this.bubbleColor, required this.isSender});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = bubbleColor;
    final path = Path();

    // Define the coordinates for a simple triangle nip
    if (isSender) {
      // Nip on the right (Sender)
      path.moveTo(size.width, size.height);
      path.lineTo(size.width - 10, size.height);
      path.lineTo(size.width, size.height - 10);
      path.close();
    } else {
      // Nip on the left (Receiver)
      path.moveTo(0, size.height);
      path.lineTo(10, size.height);
      path.lineTo(0, size.height - 10);
      path.close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
