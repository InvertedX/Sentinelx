import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sentinelx/channels/system_channel.dart';
import 'package:sentinelx/models/db/backup_manager.dart';
import 'package:sentinelx/models/db/prefs_store.dart';
import 'package:sentinelx/screens/settings/restore_backup.dart';
import 'package:sentinelx/widgets/appbar_bottom_progress.dart';

class BackUpSettingsScreen extends StatefulWidget {
  @override
  _BackUpSettingsScreenState createState() => _BackUpSettingsScreenState();
}

class _BackUpSettingsScreenState extends State<BackUpSettingsScreen> {
  bool autSave = false;
  bool loading = false;
  GlobalKey<ScaffoldState> scaffold = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffold,
      appBar: AppBar(
        title: Text("BackUp"),
        bottom: AppBarUnderProgress(loading),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text("Backup"),
            subtitle: Text("Create backup and export"),
            onTap: backUp,
          ),
          Divider(),
          ListTile(
            title: Text("Restore"),
            subtitle: Text("This will erase current data"),
            onTap: () {
              Navigator.push(context, new MaterialPageRoute(
                builder: (c) {
                  return RestoreScreen();
                },
              ));
            },
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    this.init();
  }

  void backUp() {
    num _radioValue = 1;
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: StatefulBuilder(
                builder: (context, stateSetter) {
                  return Wrap(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        child: Text(
                          "Back Up options",
                          style: Theme.of(context).textTheme.subhead,
                        ),
                      ),
                      Divider(),
                      ListTile(
                        onTap: () {
                          stateSetter(() {
                            _radioValue = 1;
                          });
                        },
                        title: Text("Plain backup"),
                        trailing: Radio(
                          value: 1,
                          groupValue: _radioValue,
                          onChanged: (val) {
                            stateSetter(() {
                              _radioValue = val;
                            });
                          },
                        ),
                      ),
                      ListTile(
                        onTap: () {
                          stateSetter(() {
                            _radioValue = 2;
                          });
                        },
                        title: Text("Encrypted backup"),
                        trailing: Radio(
                          value: 2,
                          groupValue: _radioValue,
                          onChanged: (val) {
                            stateSetter(() {
                              _radioValue = val;
                            });
                          },
                        ),
                      ),
                      Divider(),
                      ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: double.infinity),
                          child: FlatButton(
                            onPressed: () {
                              if (_radioValue == 1) {
                                Navigator.pop(context);
                                this.plainBackup();
                              }
                              if (_radioValue == 2) {
                                Navigator.pop(context);
                                this.backUpUsingPassword();
                              }
                            },
                            padding: EdgeInsets.all(24),
                            child: Text("Backup"),
                          ))
                    ],
                  );
                },
              ),
            ),
          );
        });
  }

  Future<void> backUpUsingPassword() async {
    TextEditingController _textEditingController = TextEditingController();
    GlobalKey<FormState> _formKey = GlobalKey();

    Function backupWithPassword = (password) async {
      Navigator.pop(context);
      String backup = await BackUpManager().encryptedBackUp(password);
      showBackup(backup, "Encrypted backup");
    };
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16),
                        child: Text(
                          'Enter password',
                        )),
                    Padding(
                      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 4,
                            child: Form(
                              key: _formKey,
                              child: TextFormField(
                                validator: (val) {
                                  if (val.length < 4) {
                                    return "Password length is too short";
                                  } else {
                                    return null;
                                  }
                                },
                                controller: _textEditingController,
                                decoration: InputDecoration(),
                                keyboardType: TextInputType.text,
                                obscureText: true,
                                maxLength: 12,
                                autofocus: true,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: FlatButton(
                                child: Text("Ok"),
                                onPressed: () {
                                  if (_formKey.currentState.validate()) {
                                    backupWithPassword(_textEditingController.text);
                                  }
                                }),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ));
  }

  void plainBackup() async {
    String backup = await BackUpManager().createPlainBackUp();
    showBackup(backup, "Plain backup");
  }

  void showBackup(String backup, String title) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return Card(
              child: SingleChildScrollView(
            child: Wrap(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.subhead,
                  ),
                ),
                Divider(),
                Text(backup),
                Divider(),
                ButtonBar(
                  alignment: MainAxisAlignment.spaceEvenly,
                  layoutBehavior: ButtonBarLayoutBehavior.padded,
                  children: <Widget>[
                    FlatButton(
                      child: Text('Save as file'),
                      onPressed: () async {
                        Navigator.pop(context);
                        var formatter = new DateFormat('dd_MM_yyyy');
                        String name = '${formatter.format(DateTime.now())}_sentinelx_backup.txt';
                        try {
                          bool saved = await SystemChannel().saveToFile(backup, name);
                          if (saved != null && saved)
                            scaffold.currentState.showSnackBar(
                              new SnackBar(
                                content: new Text(
                                  "Backup Saved to file",
                                  style: Theme.of(scaffold.currentContext).textTheme.subhead.copyWith(color: Colors.white),
                                ),
                                backgroundColor: Colors.green,
                                duration: Duration(milliseconds: 900),
                                behavior: SnackBarBehavior.floating,
                                elevation: 1,
                              ),
                            );
                        } catch (e) {
                          scaffold.currentState.showSnackBar(
                            new SnackBar(
                              content: new Text(
                                "Error : $e",
                                style: Theme.of(scaffold.currentContext).textTheme.subhead.copyWith(color: Colors.white),
                              ),
                              backgroundColor: Colors.redAccent,
                              duration: Duration(milliseconds: 900),
                              behavior: SnackBarBehavior.floating,
                              elevation: 1,
                            ),
                          );
                          print(e);
                        }
                      },
                    ),
                    FlatButton(
                      child: Text('Copy to clipboard'),
                      onPressed: () {
                        Clipboard.setData(new ClipboardData(text: backup));
                        Navigator.pop(context);
                        scaffold.currentState.showSnackBar(
                          new SnackBar(
                            content: new Text(
                              "Copied",
                              style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.white),
                            ),
                            backgroundColor: Colors.green,
                            duration: Duration(milliseconds: 900),
                            behavior: SnackBarBehavior.floating,
                            elevation: 1,
                          ),
                        );
                      },
                    ),
                  ],
                )
              ],
            ),
          ));
        });
  }

  void init() async {
    await PrefsStore().getBool(PrefsStore.AUTO_SAVE_BACKUP);
  }
}
