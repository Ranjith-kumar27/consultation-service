import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

import '../bloc/call_bloc.dart';
import '../bloc/call_event.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive_config.dart';

class CallPage extends StatefulWidget {
  final String channelName;
  final String? callId;

  const CallPage({super.key, required this.channelName, this.callId});

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  late RtcEngine _engine;
  bool _localUserJoined = false;
  int? _remoteUid;
  bool _muted = false;

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  Future<void> _initAgora() async {
    try {
      debugPrint('[Agora] Starting initialization...');
      // Request permissions
      final status = await [Permission.microphone, Permission.camera].request();
      debugPrint('[Agora] Permissions status: $status');

      if (AppConstants.agoraAppId == "YOUR_AGORA_APP_ID" ||
          AppConstants.agoraAppId.isEmpty) {
        debugPrint(
          '[Agora] CRITICAL ERROR: Agora App ID is not configured correctly!',
        );
        throw Exception("Agora App ID not configured correctly.");
      }

      debugPrint(
        '[Agora] Creating engine with App ID: ${AppConstants.agoraAppId}',
      );
      // Create engine
      _engine = createAgoraRtcEngine();
      await _engine.initialize(
        const RtcEngineContext(
          appId: AppConstants.agoraAppId,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );
      debugPrint('[Agora] Engine initialized successfully');

      _engine.registerEventHandler(
        RtcEngineEventHandler(
          onError: (ErrorCodeType err, String msg) {
            debugPrint('[Agora EVENT] onError: $err, msg: $msg');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Agora Error: $err - $msg"),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 5),
                ),
              );
            }
          },
          onConnectionStateChanged:
              (
                RtcConnection connection,
                ConnectionStateType state,
                ConnectionChangedReasonType reason,
              ) {
                debugPrint(
                  '[Agora EVENT] onConnectionStateChanged: channel ${connection.channelId}, state $state, reason $reason',
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Agora State: ${state.name} (${reason.name})",
                      ),
                      backgroundColor: Colors.blue,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            debugPrint(
              '[Agora EVENT] onJoinChannelSuccess: channel ${connection.channelId}, localUid: ${connection.localUid}',
            );
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Joined channel: ${connection.channelId}"),
                  backgroundColor: Colors.green,
                ),
              );
            }
            setState(() => _localUserJoined = true);
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            debugPrint(
              '[Agora EVENT] onUserJoined: Remote user $remoteUid joined',
            );
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Remote user joined: $remoteUid"),
                  backgroundColor: Colors.green,
                ),
              );
            }
            setState(() => _remoteUid = remoteUid);
          },
          onUserOffline:
              (
                RtcConnection connection,
                int remoteUid,
                UserOfflineReasonType reason,
              ) {
                debugPrint(
                  '[Agora EVENT] onUserOffline: Remote user $remoteUid went offline, reason $reason',
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Remote user left: $remoteUid"),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
                setState(() => _remoteUid = null);
                _endCall();
              },
          onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
            debugPrint(
              '[Agora EVENT] onTokenPrivilegeWillExpire: Token is about to expire!',
            );
          },
        ),
      );

      debugPrint('[Agora] Enabling video and starting preview...');
      await _engine.enableVideo();
      await _engine.startPreview();

      debugPrint(
        '[Agora] Joining channel with channelId: ${widget.channelName}, uid: 0',
      );
      await _engine.joinChannel(
        token: "",
        channelId: widget.channelName,
        uid: 0,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
          publishMicrophoneTrack: true,
          publishCameraTrack: true,
        ),
      );
      debugPrint('[Agora] joinChannel API call completed.');
    } catch (e) {
      debugPrint("Agora Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to initialize call: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  void _endCall() {
    context.read<CallBloc>().add(EndCallEvent(widget.callId));
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(child: _remoteVideo()),
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 100.rw,
              height: 150.rh,
              child: Center(
                child: _localUserJoined
                    ? AgoraVideoView(
                        controller: VideoViewController(
                          rtcEngine: _engine,
                          canvas: const VideoCanvas(uid: 0),
                          useFlutterTexture: true,
                        ),
                      )
                    : const CircularProgressIndicator(),
              ),
            ),
          ),
          _toolbar(),
        ],
      ),
    );
  }

  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: widget.channelName),
          useFlutterTexture: true,
        ),
      );
    } else {
      return Text(
        'Waiting for remote user...',
        style: TextStyle(color: Colors.white, fontSize: 16.rt),
      );
    }
  }

  Widget _toolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.symmetric(vertical: 48.rh),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RawMaterialButton(
            onPressed: () {
              setState(() => _muted = !_muted);
              _engine.muteLocalAudioStream(_muted);
            },
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: _muted ? AppColors.primary : Colors.white,
            padding: EdgeInsets.all(12.rw),
            child: Icon(
              _muted ? Icons.mic_off : Icons.mic,
              color: _muted ? Colors.white : AppColors.primary,
              size: 20.rt,
            ),
          ),
          RawMaterialButton(
            onPressed: _endCall,
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: EdgeInsets.all(15.rw),
            child: Icon(Icons.call_end, color: Colors.white, size: 35.rt),
          ),
          RawMaterialButton(
            onPressed: () => _engine.switchCamera(),
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: EdgeInsets.all(12.rw),
            child: Icon(
              Icons.switch_camera,
              color: AppColors.primary,
              size: 20.rt,
            ),
          ),
        ],
      ),
    );
  }
}
