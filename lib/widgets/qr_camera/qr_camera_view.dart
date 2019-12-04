import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentinelx/channels/system_channel.dart';

typedef void ControllerCallback(CameraController controller);
typedef void OnDecodeComplete(String code);

class QRCameraView extends StatefulWidget {
  final double cameraHeight;
  final ControllerCallback controllerCallback;

  QRCameraView({@required this.cameraHeight, this.controllerCallback});

  @override
  _QRCameraViewState createState() => _QRCameraViewState();
}

class _QRCameraViewState extends State<QRCameraView> {
  CameraController _cameraController;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.cameraHeight,
      child: AndroidView(
        viewType: 'plugins.sentinelx.qr_camera',
        onPlatformViewCreated: (int id) {
          _cameraController = CameraController(id);
          if (widget.controllerCallback != null) {
            this.widget.controllerCallback(_cameraController);
          }
        },
      ),
    );
  }
}

class CameraController {
  MethodChannel _channel;
  OnDecodeComplete _decodeComplete;

  CameraController(int id) {
    this._channel = new MethodChannel('plugins.sentinelx.qr_camera_$id');
  }

  setDecodeListener(OnDecodeComplete value) {
    _decodeComplete = value;
  }

  Future<void> startPreview() async {
    bool run = await SystemChannel().askCameraPermission();
    if (run) {
      _channel.invokeMethod('start_preview').then((va) {
        if (_decodeComplete != null) {
          _decodeComplete(va);
        }
      });
    }
  }

  Future<void> stopPreview() async {
    return _channel.invokeMethod('stop_preview');
  }
}
