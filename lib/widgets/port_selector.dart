import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentinelx/channels/network_channel.dart';
import 'package:sentinelx/models/db/prefs_store.dart';

class PortSelector extends StatefulWidget {
  @override
  _PortSelectorState createState() => _PortSelectorState();
}

class _PortSelectorState extends State<PortSelector> {
  TextEditingController _textEditingController = new TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    this.init();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16),
                child: Text(
                  'Enter Port number',
                )),
            Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: _textEditingController,
                        validator: (val) {
                          RegExp regExp = new RegExp(
                            r"^()([1-9]|[1-5]?[0-9]{2,4}|6[1-4][0-9]{3}|65[1-4][0-9]{2}|655[1-2][0-9]|6553[1-5])$",
                            multiLine: false,
                          );
                          if (regExp.hasMatch(val)) {
                            return null;
                          } else {
                            return "Invalid port range";
                          }
                        },
                        decoration: InputDecoration(),
                        inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                        keyboardType: TextInputType.number,
                        maxLength: 5,
                        autofocus: true,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: FlatButton(child: Text("Set Port"), onPressed: setPort),
                  )
                ],
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void setPort() async {
    if (_formKey.currentState.validate()) {
      var portString = _textEditingController.text.toString();
      var port = int.parse(portString);
      PrefsStore().put(PrefsStore.TOR_PORT, port);
      await NetworkChannel().setTorPort(port);
      Navigator.of(context).pop();
    }
  }

  void init() async {
    await Future.delayed(Duration(milliseconds: 500));
    var port = await PrefsStore().getInt(PrefsStore.TOR_PORT);
    if (port == null) {
    } else {
      _textEditingController.text = port.toString();
    }
  }
}
