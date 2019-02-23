import 'package:flutter/material.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/widgets/page.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:package_info/package_info.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Page(
      appBarStyle: PageAppBarStyle(
        title: "Settings",
      ),
      child: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              top: paddingDefault,
              left: paddingDefault,
              right: paddingDefault,
            ),
            child: HeadingText("About"),
          ),
          ListTile(
            title: Text("Version"),
            trailing: FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (BuildContext context,
                  AsyncSnapshot<PackageInfo> snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        snapshot.data.version,
                        // Same style used in ListTile.title.
                        style: Theme.of(context).textTheme.subhead.copyWith(
                          color: Colors.black54,
                        ),
                      );
                    } else {
                      return Text("...");
                    }
                  },
            ),
          ),
          MinDivider(),
        ],
      ),
    );
  }
}