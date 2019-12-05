import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sentinelx/widgets/qr_camera/qr_camera_view.dart';

typedef void OnQrDetect(String code);

class PushUpCameraWrapper extends StatefulWidget {
  final Widget child;
  final double cameraHeight;

  PushUpCameraWrapper({
    this.child,
    Key key,
    @required this.cameraHeight,
  }) : super(key: key);

  @override
  PushUpCameraWrapperState createState() => PushUpCameraWrapperState();
}

class PushUpCameraWrapperState extends State<PushUpCameraWrapper>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<num> animation;
  CameraController _cameraController;
  OnDecodeComplete _decodeComplete;

  @override
  void initState() {
    super.initState();

    controller = new AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    )
      ..addListener(() => setState(() {}))
      ..addStatusListener((state) {
        if (state == AnimationStatus.completed) {
          _cameraController.startPreview();
        }
        if (state == AnimationStatus.dismissed) {
          _cameraController.stopPreview();
        }
      });

    final Animation curve =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    animation = Tween(begin: 0.0, end: widget.cameraHeight).animate(curve);
  }

  start() {
    controller.forward();
  }

  setDecodeListener(OnDecodeComplete value) {
    _decodeComplete = value;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.bottomCenter,
          child: QRCameraView(
            cameraHeight: widget.cameraHeight,
            controllerCallback: (CameraController co) {
              _cameraController = co;
              _cameraController.setDecodeListener((val) {
                controller.reverse();
                if (this._decodeComplete != null) this._decodeComplete(val);
              });
            },
          ),
        ),
        Transform.translate(
          offset: Offset(0, (animation.value * -1).toDouble()),
          child: GestureDetector(
              child: Container(
                child: widget.child,
                color: Colors.transparent,
              ),
              onHorizontalDragDown: (d) {
                if (animation.isCompleted) {
                  controller.reverse();
                }
              },
              onVerticalDragCancel: () {
                if (animation.isCompleted) {
                  controller.reverse();
                }
              },
              onTap: () {
                if (animation.isCompleted) {
                  controller.reverse();
                }
              }),
        ),
      ],
    );
  }
}
