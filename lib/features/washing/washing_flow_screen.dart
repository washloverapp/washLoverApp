import 'package:flutter/material.dart';
import 'package:my_flutter_mapwash/features/washing/steps/step_1_laundry_type.dart';
import 'package:my_flutter_mapwash/features/washing/steps/step_2_detergent.dart';

class WashingFlowScreen extends StatefulWidget {
  const WashingFlowScreen({super.key});

  @override
  State<WashingFlowScreen> createState() => _WashingFlowScreenState();
}

class _WashingFlowScreenState extends State<WashingFlowScreen> {
  int _currentStep = 0;

  // รายการของ Step ทั้งหมดในกระบวนการ
  List<Step> get _steps => [
        Step(
          title: const Text('เลือกประเภทการซัก'),
          content: const Step1LaundryType(),
          isActive: _currentStep >= 0,
        ),
        Step(
          title: const Text('เลือกน้ำยา'),
          content: const Step2Detergent(),
          isActive: _currentStep >= 1,
        ),
        // ตัวอย่าง Step ที่ 3: สามารถสร้างไฟล์ใหม่แล้วเรียกใช้ได้เลย
        Step(
          title: const Text('ขั้นตอนที่ 3'),
          content: const Text('Widget สำหรับขั้นตอนที่ 3'),
          isActive: _currentStep >= 2,
        ),
        // เพิ่ม Step อื่นๆ ที่นี่จนครบ 10 ขั้นตอน
        Step(
          title: const Text('ยืนยันคำสั่งซื้อ'),
          content: const Text('หน้าจอสำหรับยืนยันการสั่งซื้อ'),
          isActive: _currentStep >= 9,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เลือกรายการซัก'),
      ),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: () {
          // Logic เมื่อผู้ใช้กดปุ่ม "ถัดไป"
          final isLastStep = _currentStep == _steps.length - 1;
          if (isLastStep) {
            // โค้ดสำหรับยืนยันคำสั่งซื้อ
            print('ยืนยันการสั่งซื้อ!');
          } else {
            setState(() {
              _currentStep += 1;
            });
          }
        },
        onStepCancel: () {
          // Logic เมื่อผู้ใช้กดปุ่ม "ย้อนกลับ"
          if (_currentStep == 0) {
            return;
          }
          setState(() {
            _currentStep -= 1;
          });
        },
        controlsBuilder: (context, details) {
          // ออกแบบปุ่ม "ถัดไป" และ "ย้อนกลับ" เอง
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                if (_currentStep != 0)
                  OutlinedButton(
                    onPressed: details.onStepCancel,
                    child: const Text('ย้อนกลับ'),
                  ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  child: Text(_currentStep == _steps.length - 1 ? 'ยืนยัน' : 'ถัดไป'),
                ),
              ],
            ),
          );
        },
        steps: _steps,
      ),
    );
  }
}