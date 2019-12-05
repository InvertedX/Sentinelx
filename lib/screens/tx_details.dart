import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentinelx/channels/api_channel.dart';
import 'package:sentinelx/channels/system_channel.dart';
import 'package:sentinelx/models/tx.dart';
import 'package:sentinelx/models/tx_details_response.dart';
import 'package:sentinelx/shared_state/app_state.dart';
import 'package:sentinelx/utils/format_util.dart';
import 'package:sentinelx/utils/utils.dart';

class TxDetails extends StatefulWidget {
  final Tx tx;
  final GlobalKey<ScaffoldState> scaffoldKey;

  TxDetails(this.tx, this.scaffoldKey);

  @override
  _TxDetailsState createState() => _TxDetailsState();
}

class _TxDetailsState extends State<TxDetails> {
  String fees = "";
  String feeRate = "";
  String blockHeight = "";
  bool isLoading = true;

  @override
  void initState() {
    loadTx();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          color: Theme.of(context).primaryColorDark,
          child: Center(
              child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 32),
            child: Text("${satToBtc(widget.tx.result)} BTC",
                style: Theme.of(context)
                    .textTheme
                    .headline
                    .copyWith(color: Colors.white),
                textAlign: TextAlign.center),
          )),
        ),
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _buildRow("Date", "${formatDateAndTime(widget.tx.time)}"),
                Divider(),
                _buildRow("Fees", fees),
                Divider(),
                _buildRow("Feerate", feeRate),
                Divider(),
                _buildRow("Block Height", blockHeight),
                Divider(),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 12),
                        child: Text(
                          "Tx hash",
                          style: Theme.of(context).textTheme.subtitle,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 12),
                        child: InkWell(
                            onTap: () => _copy(widget.tx.hash),
                            child: Text(
                              "${widget.tx.hash}",
                              maxLines: 2,
                              style: TextStyle(fontSize: 12),
                            )),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  child: Center(
                      child: FlatButton.icon(
                          onPressed: () => openInExplorer(context),
                          icon: Icon(Icons.open_in_browser),
                          label: Text("Open in explorer"))),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: Text(
              title,
              style: Theme.of(context).textTheme.subtitle,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: (isLoading && value == "")
                ? SizedBox(
                    child: CircularProgressIndicator(strokeWidth: 1),
                    height: 12,
                    width: 12,
                  )
                : Text(
                    value,
                    maxLines: 2,
                  ),
          ),
        ],
      ),
    );
  }

  void loadTx() async {
    bool networkOkay = await checkNetworkStatusBeforeApiCall((snackbar) => {});
    if (networkOkay)
      try {
        setState(() {
          isLoading = true;
        });
        TxDetailsResponse txDetailsResponse =
            await ApiChannel().getTx(widget.tx.hash);

        setState(() {
          isLoading = false;
//          feeRate = "${txDetailsResponse.feerate} sats";
//          fees = "${txDetailsResponse.fees} sats";
          blockHeight = "${txDetailsResponse.block.height}";
        });
      } catch (exception) {
        setState(() {
          isLoading = false;
        });
      }
  }

  _copy(String string) {
    Clipboard.setData(new ClipboardData(text: string));
    widget.scaffoldKey.currentState.showSnackBar(
      new SnackBar(
        content: new Text("Copied"),
        duration: Duration(milliseconds: 800),
        behavior: SnackBarBehavior.fixed,
      ),
    );
    Navigator.of(context).pop();
  }

  void openInExplorer(BuildContext context) async {
    var url = '';
    if (AppState().isTestnet) {
      url = "https://blockstream.info/testnet/${widget.tx.hash}";
    } else {
      url = "https://oxt.me/transaction/${widget.tx.hash}";
    }
    try {
      await SystemChannel().openURL(url);
    } catch (er) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Unable to open browser"),
      ));
    }
  }
}
