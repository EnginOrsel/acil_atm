import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        centerTitle: true,
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Uygulama Hakkında'),
            subtitle: Text('Sürüm 2.7.0'),
          ),
          ListTile(
            leading: Icon(Icons.privacy_tip_outlined),
            title: Text('Gizlilik Politikası'),
            subtitle: Text('Verileriniz güvendedir.'),
          ),
          ListTile(
            leading: Icon(Icons.feedback_outlined),
            title: Text('Geri Bildirim Gönder'),
            subtitle: Text('Uygulama hakkında düşüncelerinizi paylaşın.'),
          ),
        ],
      ),
    );
  }
}
