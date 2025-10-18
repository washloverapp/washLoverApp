import 'package:flutter/material.dart';
import 'package:my_flutter_mapwash/Header/headerOrder.dart';
import 'package:my_flutter_mapwash/Notification/notificationdetail.dart';

// --- Data Model ---
class NotificationModel {
  final String title;
  final String subtitle;
  final String time;
  final IconData? icon;

  NotificationModel({
    this.title = '',
    this.subtitle = '',
    this.time = '',
    this.icon,
  });
}

// --- Main Widget ---
class NotificationScreen extends StatelessWidget {
  final List<NotificationModel> notifications = [
    NotificationModel(
      title: 'เครื่องซัก/อบ',
      subtitle: 'เครื่องอบผ้าหมายเลข 14 ทำงานเสร็จเรียบร้อยแล้วค่ะ',
      time: '08 ต.ค. 2568 23:00',
    ),
    NotificationModel(
      title: 'ผ้าของคุณ กำลังจะอบเสร็จในอีก 5 นาที',
      subtitle: 'อย่าลืมกลับมาหยิบผ้าออกจากเครื่องด้วยน้า',
      time: '08 ต.ค. 2568 22:56',
    ),
    NotificationModel(
      title: 'เครื่องซัก/อบ',
      subtitle: 'เครื่องซักผ้าหมายเลข 5 ทำงานเสร็จเรียบร้อยแล้วค่ะ',
      time: '08 ต.ค. 2568 22:18',
    ),
    NotificationModel(
      title: 'ผ้าของคุณ กำลังจะซักเสร็จในอีก 5 นาที',
      subtitle: 'อย่าลืมกลับมาหยิบผ้าออกจากเครื่องด้วยน้า',
      time: '08 ต.ค. 2568 22:13',
    ),
    NotificationModel(
      title: 'เครื่องซัก/อบ',
      subtitle: 'เครื่องอบผ้าหมายเลข 10 ทำงานเสร็จเรียบร้อยแล้วค่ะ',
      time: '29 ก.ย. 2568 22:01',
    ),
    NotificationModel(
      title: 'ผ้าของคุณ กำลังจะอบเสร็จในอีก 5 นาที',
      subtitle: 'อย่าลืมกลับมาหยิบผ้าออกจากเครื่องด้วยน้า',
      time: '29 ก.ย. 2568 21:56',
    ),
    NotificationModel(
      title: 'เครื่องซัก/อบ',
      subtitle: 'เครื่องซักผ้าหมายเลข 2 ทำงานเสร็จเรียบร้อยแล้วค่ะ',
      time: '29 ก.ย. 2568 20:41',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: headerOrder(
        title: 'แจ้งเตือน',
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "NOTIFICATIONS",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 203, 203, 203),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  return NotificationTile(
                    item: notifications[index],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Tile Widget ---
class NotificationTile extends StatelessWidget {
  final NotificationModel item;

  const NotificationTile({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotificationDetailScreen(item: item),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey, width: 0.5),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: item.title.contains('ผ้าของคุณ')
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.time,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
