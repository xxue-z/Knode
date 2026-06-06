import 'package:flutter/material.dart';
import 'package:knode_app/gen/strings.dart';
import 'package:knode_app/screens/storage_settings.dart';

const _strings = L10nStringsMixin();

class WikiSettingsPage extends StatelessWidget {
  const WikiSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_strings.knode_app_wiki_settings), centerTitle: true),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.folder_outlined),
            title: Text(_strings.knode_app_storage_path),
            subtitle: Text(_strings.knode_app_storage_path_subtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StorageSettingsPage()),
            ),
          ),
        ],
      ),
    );
  }
}
