import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data' show Uint8List;

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:global_ios/screens/login.dart';
import 'package:global_ios/screens/upload_local_podcast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

enum Media {
  file,
  buffer,
  asset,
  stream,
  remoteExampleFile,
}
enum AudioState {
  isPlaying,
  isPaused,
  isStopped,
  isRecording,
  isRecordingPaused,
}

/// Boolean to specify if we want to test the Rentrance/Concurency feature.
/// If true, we start two instances of FlautoPlayer when the user hit the "Play" button.
/// If true, we start two instances of FlautoRecorder and one instance of FlautoPlayer when the user hit the Record button
final exampleAudioFilePath =
    "https://file-examples.com/wp-content/uploads/2017/11/file_example_MP3_700KB.mp3";
final albumArtPath =
    "https://file-examples.com/wp-content/uploads/2017/10/file_example_PNG_500kB.png";

class CreatePodcast extends StatefulWidget {
  final currentUser;
  CreatePodcast({this.currentUser});
  @override
  _CreatePodcastState createState() => new _CreatePodcastState();
}

class _CreatePodcastState extends State<CreatePodcast> {
  bool _isRecording = false;
  bool process = false;
  //   late FlutterToast flutterToast;
  bool artFlag = false;

  List<String?> _path = [
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
  ];

  // StreamSubscription? _recorderSubscription;
  StreamSubscription? _playerSubscription;

  FlutterSoundPlayer? playerModule = FlutterSoundPlayer();
  FlutterSoundRecorder? recorderModule = FlutterSoundRecorder();

  String _recorderTxt = '00:00:00';
  String _playerTxt = '00:00:00';
  double? _dbLevel;
  late File file;
  // File? filepath;
  var filepath;

  double sliderCurrentPosition = 0.0;
  double maxDuration = 1.0;
  Media _media = Media.file;
  Codec _codec = Codec.aacADTS;

  bool _encoderSupported = true; // Optimist
  bool _decoderSupported = true; // Optimist

  // Whether the user wants to use the audio player features
  bool _isAudioPlayer = false;
  TextEditingController blogTitleController = TextEditingController();
  TextEditingController blogDescriptionController = TextEditingController();
  double? _duration = null;

  Future<void> _initializeExample(bool withUI) async {
    await playerModule?.closeAudioSession();
    _isAudioPlayer = withUI;
    if (withUI) {
      await playerModule?.openAudioSessionWithUI(
          focus: AudioFocus.requestFocusTransient,
          category: SessionCategory.playAndRecord,
          mode: SessionMode.modeDefault,
          audioFlags: outputToSpeaker,
          device: AudioDevice.speaker);
    } else {
      await playerModule?.openAudioSession(
          focus: AudioFocus.requestFocusTransient,
          category: SessionCategory.playAndRecord,
          mode: SessionMode.modeDefault,
          audioFlags: outputToSpeaker,
          device: AudioDevice.speaker);
    }
    await playerModule?.setSubscriptionDuration(Duration(milliseconds: 10));
    await recorderModule?.setSubscriptionDuration(Duration(milliseconds: 10));
    initializeDateFormatting();
    // setCodec(_codec);
  }

  Future<void> init() async {
    playerModule = await FlutterSoundPlayer().openAudioSession();
    recorderModule = FlutterSoundRecorder();

    // recorderModule!.openAudioSession(
    //     focus: AudioFocus.requestFocusTransient,
    //     category: SessionCategory.playAndRecord,
    //     mode: SessionMode.modeDefault,
    //     device: AudioDevice.speaker);
    await _initializeExample(false);

    if (Platform.isAndroid) {
      copyAssets();
    }
  }

  Future<void> copyAssets() async {
    // var dataBuffer =  (await rootBundle.load('assets/canardo.png')).buffer.asUint8List();
    var dataBuffer =
        (await rootBundle.load('assets/images/flogo.png')).buffer.asUint8List();
    var path = '${await playerModule?.getResourcePath()}/assets';
    if (!await Directory(path).exists()) {
      await Directory(path).create(recursive: true);
    }
    await File('$path/canardo.png').writeAsBytes(dataBuffer);
  }

  @override
  void initState() {
    super.initState();
    init();
    // flutterToast = FlutterToast(context);
  }

  // void cancelRecorderSubscriptions() {
  //   if (_recorderSubscription != null) {
  //     _recorderSubscription!.cancel();
  //     _recorderSubscription = null;
  //   }
  // }

  void cancelPlayerSubscriptions() {
    if (_playerSubscription != null) {
      _playerSubscription!.cancel();
      _playerSubscription = null;
    }
  }

  @override
  void dispose() {
    super.dispose();
    cancelPlayerSubscriptions();
    // cancelRecorderSubscriptions();
    releaseFlauto();
  }

  Future<void> releaseFlauto() async {
    try {
      await playerModule?.closeAudioSession();
      await recorderModule?.closeAudioSession();
    } catch (e) {
      print('Released unsuccessful');
      print(e);
    }
  }

  late var bpath;

  // void startRecorder() async {
  //   try {
  //     // String path = await flutterSoundModule.startRecorder
  //     // (
  //     //   paths[_codec.index],
  //     //   codec: _codec,
  //     //   sampleRate: 16000,
  //     //   bitRate: 16000,
  //     //   numChannels: 1,
  //     //   androidAudioSource: AndroidAudioSource.MIC,
  //     // );
  //     // Request Microphone permission if needed
  //     PermissionStatus status = await Permission.microphone.request();

  //     if (status != PermissionStatus.granted) {
  //       throw RecordingPermissionException("Microphone permission not granted");
  //     }

  //     Directory tempDir = await getTemporaryDirectory();
  //     print(tempDir);

  //     String path =
  //         '${tempDir.path}/${recorderModule!.logger}-flutter_sound${ext[_codec.index]}';
  //     bpath = path;
  //     bpath = tempDir;
  //     await recorderModule!.startRecorder(
  //       toFile: path,
  //       // toFile: bpath,
  //       codec: Codec.defaultCodec,
  //       bitRate: 8000,
  //       sampleRate: 8000,
  //       // audioSource: AudioSource.voice_communication,
  //     );
  //     print('startRecorder');

  //     // _recorderSubscription = recorderModule?.onProgress!.listen((e) {
  //     //   if (e != null) {
  //     //     DateTime date = new DateTime.fromMillisecondsSinceEpoch(
  //     //         e.duration.inMilliseconds,
  //     //         isUtc: true);
  //     //     String txt = DateFormat('mm:ss:SS', 'en_GB').format(date);

  //     //     this.setState(() {
  //     //       _recorderTxt = txt.substring(0, 8);
  //     //       if (_recorderTxt == "11:00:00") {
  //     //         stopRecorder();
  //     //       }
  //     //       _dbLevel = e.decibels;
  //     //     });
  //     //   }
  //     // });

  //   //   this.setState(() {
  //   //     this._isRecording = true;
  //   //     // this._path[_codec.index] = path;
  //   //     this._path[_codec.index] = bpath;
  //   //   });
  //   } catch (err) {
  //   //   print('startRecorder error: $err');
  //   //   setState(() {
  //   //     stopRecorder();
  //   //     this._isRecording = false;
  //       // if (_recorderSubscription != null) {
  //       //   _recorderSubscription!.cancel();
  //       //   _recorderSubscription = null;
  //       // }
  //     // });
  //   }
  // }

  Future<void> getDuration() async {
    switch (_media) {
      case Media.file:
      case Media.buffer:
        Duration? d;
        d = await flutterSoundHelper.duration(_path[_codec.index]!);
        _duration = d != null ? d.inMilliseconds / 1000.0 : null;
        break;
      case Media.asset:
        _duration = null;
        break;
      case Media.remoteExampleFile:
        _duration = null;
        break;
    }
    setState(() {});
  }

  // void stopRecorder() async {
  //   try {
  //     await recorderModule?.stopRecorder();
  //     print('stopRecorder');
  //     // cancelRecorderSubscriptions();
  //     getDuration();
  //   } catch (err) {
  //     print('stopRecorder error: $err');
  //   }
  //   this.setState(() {
  //     this._isRecording = false;
  //   });
  // }

  Future<bool> fileExists(String path) async {
    return await File(path).exists();
  }

  // In this simple example, we just load a file in memory.This is stupid but just for demonstration  of startPlayerFromBuffer()
  Future<Uint8List?> makeBuffer(String path) async {
    try {
      if (!await fileExists(path)) return null;
      File file = File(path);
      file.openRead();
      var contents = await file.readAsBytes();
      print('The file is ${contents.length} bytes long.');
      return contents;
    } catch (e) {
      print(e);
      return null;
    }
  }

  List<String> assetSample = [
    'assets/samples/sample.aac',
    'assets/samples/sample.aac',
    'assets/samples/sample.opus',
    'assets/samples/sample_opus.caf',
    'assets/samples/sample.mp3',
    'assets/samples/sample.ogg',
    'assets/samples/sample.pcm',
    'assets/samples/sample.wav',
    'assets/samples/sample.aiff',
    'assets/samples/sample_pcm.caf',
    'assets/samples/sample.flac',
    'assets/samples/sample.mp4',
    'assets/samples/sample.amr', // amrNB
    'assets/samples/sample.amr', // amrWB
  ];

  void _addListeners() {
    cancelPlayerSubscriptions();
    _playerSubscription = playerModule?.onProgress!.listen((e) {
      maxDuration = e.duration.inMilliseconds.toDouble();
      if (maxDuration <= 0) maxDuration = 0.0;

      sliderCurrentPosition =
          min(e.position.inMilliseconds.toDouble(), maxDuration);
      if (sliderCurrentPosition < 0.0) {
        sliderCurrentPosition = 0.0;
      }

      DateTime date = new DateTime.fromMillisecondsSinceEpoch(
          e.position.inMilliseconds,
          isUtc: true);
      String txt = DateFormat('mm:ss:SS', 'en_GB').format(date);
      this.setState(() {
        this._playerTxt = txt.substring(0, 8);
      });
    });
  }

  String? audioFilePath;

  Future<void> startPlayer() async {
    try {
      //String path;
      Uint8List? dataBuffer;
      if (_media == Media.asset) {
        dataBuffer = (await rootBundle.load(assetSample[_codec.index]))
            .buffer
            .asUint8List();
      } else if (_media == Media.file) {
        // Do we want to play from buffer or from file ?
        if (await fileExists(_path[_codec.index]!))
          audioFilePath = this._path[_codec.index];
      } else if (_media == Media.buffer) {
        // Do we want to play from buffer or from file ?
        if (await fileExists(_path[_codec.index]!)) {
          dataBuffer = await makeBuffer(this._path[_codec.index]!);
          if (dataBuffer == null) {
            throw Exception('Unable to create the buffer');
          }
        }
      } else if (_media == Media.remoteExampleFile) {
        // We have to play an example audio file loaded via a URL
        audioFilePath = exampleAudioFilePath;
      }

      if (_isAudioPlayer) {
        late String albumArtUrl;
        String albumArtAsset = "";
        String? albumArtFile;
        if (_media == Media.remoteExampleFile)
          albumArtUrl = albumArtPath;
        else {
          albumArtFile = ((playerModule?.getResourcePath().toString())! +
              "/assets/canardo.png");
          print(albumArtFile);
        }

        final track = Track(
          trackPath: audioFilePath!,
          dataBuffer: dataBuffer!,
          trackTitle: "This is a record",
          trackAuthor: "from flutter_sound",
          albumArtUrl: albumArtUrl,
          albumArtAsset: albumArtAsset,
          albumArtFile: albumArtFile!,
        );
        await playerModule?.startPlayerFromTrack(track,
            /*canSkipForward:true, canSkipBackward:true,*/
            whenFinished: () {
          print('I hope you enjoyed listening to this song');
          setState(() {});
        }, onSkipBackward: () {
          print('Skip backward');
          stopPlayer();
          startPlayer();
        }, onSkipForward: () {
          print('Skip forward');
          stopPlayer();
          startPlayer();
        }, onPaused: (bool doPause) {
          if (doPause)
            playerModule?.pausePlayer();
          else
            playerModule?.resumePlayer();
        });
      } else {
        if (audioFilePath != null) {
          await playerModule?.startPlayer(
              fromURI: audioFilePath!,
              codec: _codec,
              whenFinished: () {
                print('Play finished');
                setState(() {});
              });
        } else if (dataBuffer != null) {
          await playerModule?.startPlayer(
              fromDataBuffer: dataBuffer,
              codec: _codec,
              whenFinished: () {
                print('Play finished');
                setState(() {});
              });
        }
      }

      _addListeners();
      print('startPlayer');
      // await flutterSoundModule.setVolume(1.0);
    } catch (err) {
      print('error: $err');
    }
    setState(() {});
  }

  Future<void> stopPlayer() async {
    try {
      await playerModule?.stopPlayer();
      print('stopPlayer');
      if (_playerSubscription != null) {
        _playerSubscription!.cancel();
        _playerSubscription = null;
      }
      sliderCurrentPosition = 0.0;
    } catch (err) {
      print('error: $err');
    }
    this.setState(() {
      //this._isPlaying = false;
    });
  }

  void pauseResumePlayer() {
    if (playerModule!.isPlaying) {
      playerModule?.pausePlayer();
    } else {
      playerModule?.resumePlayer();
    }
  }

  // void pauseResumeRecorder() {
  //   if (recorderModule!.isPaused) {
  //     setState(() {
  //       recordingFlag = true;
  //     });
  //     recorderModule?.resumeRecorder();
  //   } else {
  //     setState(() {
  //       recordingFlag = false;
  //     });
  //     recorderModule?.pauseRecorder();
  //   }
  // }

  void seekToPlayer(int milliSecs) async {
    await playerModule?.seekToPlayer(Duration(milliseconds: milliSecs));
    print('seekToPlayer');
  }

  void Function()? onPauseResumePlayerPressed() {
    if (playerModule == null) return null;
    if (playerModule!.isPaused || playerModule!.isPlaying) {
      return pauseResumePlayer;
    }

    return null;
  }

  // void Function()? onPauseResumeRecorderPressed() {
  //   if (recorderModule == null) return null;
  //   if (recorderModule!.isPaused || recorderModule!.isRecording) {
  //     return pauseResumeRecorder;
  //   }

  //   return null;
  // }

  void Function()? onStopPlayerPressed() {
    if (playerModule == null) return null;
    return (playerModule!.isPlaying || playerModule!.isPaused)
        ? stopPlayer
        : null;
  }

  void Function()? onStartPlayerPressed() {
    if (playerModule == null) return null;
    if (_media == Media.file ||
        _media == Media.buffer) // A file must be already recorded to play it
    {
      if (_path[_codec.index] == null) return null;
    }
    if (_media == Media.remoteExampleFile &&
        _codec != Codec.mp3) // in this example we use just a remote mp3 file
      return null;

    // Disable the button if the selected codec is not supported
    if (!_decoderSupported) return null;
    return (playerModule!.isStopped) ? startPlayer : null;
  }

  // String? podCastUrl;

  // Future<String?> uploadPodcast(podCast) async {
  //   String postId = Uuid().v4();
  //   // StorageUploadTask uploadTask =
  //   //     storageRef.child('post_$postId.aac').putFile(podCast);
  //   // StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
  //   // String? downloadUrl = await (storageSnap.ref.getDownloadURL() as FutureOr<String?>);
  //   // podCastUrl = downloadUrl;
  //   // return downloadUrl;
  // }

  // bool recordingFlag = false;
  var albumArtUrl;

  // startStopRecorder() {
  //   if (recorderModule!.isRecording || recorderModule!.isPaused) {
  //     stopRecorder();

  //     file = File(bpath);
  //   } else
  //     startRecorder();
  // }

  // void Function()? onStartRecorderPressed() {
  //   //if (_media == t_MEDIA.ASSET || _media == t_MEDIA.BUFFER || _media == t_MEDIA.REMOTE_EXAMPLE_FILE) return null;
  //   // Disable the button if the selected codec is not supported
  //   if (recorderModule == null || !_encoderSupported) return null;
  //   return startStopRecorder;
  // }

  // Icon recorderAssetImage() {
  //   if (onStartRecorderPressed() == null) return Icon(Icons.mic);
  //   return (recorderModule!.isStopped)
  //       ? Icon(
  //           Icons.mic,
  //           size: 40,
  //         )
  //       : Icon(
  //           Icons.stop,
  //           size: 40,
  //         );
  // }

  // setCodec(Codec codec) async {
  //   if (recorderModule?.isEncoderSupported(codec) == true) {
  //     _encoderSupported = await recorderModule!.isEncoderSupported(codec);
  //   }
  //   if (playerModule?.isDecoderSupported(codec) == true) {
  //     _decoderSupported = await playerModule!.isDecoderSupported(codec);
  //   }

  //   setState(() {
  //     _codec = codec;
  //   });
  // }

  void Function(bool)? audioPlayerSwitchChanged() {
    if ((!playerModule!.isStopped)
        // ||(!recorderModule!.isStopped)
        ) return null;
    return ((newVal) async {
      try {
        await _initializeExample(newVal);
        setState(() {});
      } catch (err) {
        print(err);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // final recorderProgressIndicator = _isRecording
    //     ? LinearProgressIndicator(
    //         value: 100.0 / 160.0 * (this._dbLevel ?? 1) / 100,
    //         valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
    //         backgroundColor: Colors.red,
    //       )
    //     : Container();
    // final playerControls = Row(
    //   children: <Widget>[
    //     Container(
    //       width: 56.0,
    //       height: 56.0,
    //       child: ClipOval(
    //         child: FlatButton(
    //           onPressed: () {
    //             onStartPlayerPressed();
    //           },
    //           padding: EdgeInsets.all(8.0),
    //           child: Icon(
    //             onStartPlayerPressed() != null ? Icons.mic_none : Icons.mic,
    //           ),
    //         ),
    //       ),
    //     ),
    //     Container(
    //       width: 56.0,
    //       height: 56.0,
    //       child: ClipOval(
    //         child: FlatButton(
    //           onPressed: onPauseResumePlayerPressed(),
    //           padding: EdgeInsets.all(8.0),
    //           child: Icon(
    //             onPauseResumePlayerPressed() != null
    //                 ? Icons.play_arrow
    //                 : Icons.pause,
    //             color: Colors.black,
    //           ),
    //         ),
    //       ),
    //     ),
    //     Container(
    //       width: 56.0,
    //       height: 56.0,
    //       child: ClipOval(
    //         child: FlatButton(
    //           onPressed: onStopPlayerPressed(),
    //           padding: EdgeInsets.all(8.0),
    //           child: Icon(onStopPlayerPressed() != null ? Icons.stop : null),
    //         ),
    //       ),
    //     ),
    //   ],
    //   mainAxisAlignment: MainAxisAlignment.center,
    //   crossAxisAlignment: CrossAxisAlignment.center,
    // );
    // final playerSlider = Container(
    //     height: 56.0,
    //     child: Slider(
    //         value: min(sliderCurrentPosition, maxDuration),
    //         min: 0.0,
    //         max: maxDuration,
    //         onChanged: (double value) async {
    //           await playerModule!
    //               .seekToPlayer(Duration(milliseconds: value.toInt()));
    //         },
    //         divisions: maxDuration == 0.0 ? 1 : maxDuration.toInt()));

    // Widget recorderSection = Column(
    //     crossAxisAlignment: CrossAxisAlignment.center,
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     children: <Widget>[
    //       Container(
    //         margin:const EdgeInsets.only(top: 12.0, bottom: 16.0),
    //         child: Text(
    //           this._recorderTxt,
    //           style:const TextStyle(
    //             fontSize: 35.0,
    //             color: Colors.black,
    //           ),
    //         ),
    //       ),
    //       _isRecording
    //           ? LinearProgressIndicator(
    //               value: 100.0 / 160.0 * (this._dbLevel ?? 1) / 100,
    //               valueColor:const AlwaysStoppedAnimation<Color>(Colors.green),
    //               backgroundColor: Colors.red)
    //           : Container(),
    //       Row(
    //         children: <Widget>[
    //           Container(
    //             width: 56.0,
    //             height: 50.0,
    //             child: ClipOval(
    //               child: FlatButton(
    //                 onPressed: onStartRecorderPressed(),
    //                 padding: EdgeInsets.all(8.0),
    //                 child: recorderAssetImage(),
    //               ),
    //             ),
    //           ),
    //           Container(
    //             width: 56.0,
    //             height: 50.0,
    //             child: ClipOval(
    //               child: FlatButton(
    //                 onPressed: onPauseResumeRecorderPressed(),
    //                 disabledColor: Colors.white,
    //                 padding: EdgeInsets.all(8.0),
    //                 child: Icon(
    //                   onPauseResumeRecorderPressed() != null
    //                       ? recordingFlag
    //                           ? Icons.pause
    //                           : Icons.play_arrow
    //                       : null,
    //                   size: 40,
    //                 ),
    //               ),
    //             ),
    //           ),
    //         ],
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         crossAxisAlignment: CrossAxisAlignment.center,
    //       ),
    //     ]);

// ----------------- player ---------------------------------------------

    Widget playerSection = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(top: 12.0, bottom: 16.0),
          child: Text(
            this._playerTxt,
            style: const TextStyle(
              fontSize: 35.0,
              color: Colors.black,
            ),
          ),
        ),
        Row(
          children: <Widget>[
            Container(
              width: 56.0,
              height: 50.0,
              child: ClipOval(
                child: FlatButton(
                    onPressed: onStartPlayerPressed(),
                    disabledColor: Colors.white,
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(onStartPlayerPressed() != null
                        ? Icons.play_arrow
                        : null)),
              ),
            ),
            Container(
              width: 56.0,
              height: 50.0,
              child: ClipOval(
                child: FlatButton(
                  onPressed: onPauseResumePlayerPressed(),
                  disabledColor: Colors.white,
                  padding: EdgeInsets.all(8.0),
                  child: Icon(onPauseResumePlayerPressed() != null
                      ? Icons.pause
                      : null),
                ),
              ),
            ),
            Container(
              width: 56.0,
              height: 50.0,
              child: ClipOval(
                child: FlatButton(
                  onPressed: onStopPlayerPressed(),
                  disabledColor: Colors.white,
                  padding: EdgeInsets.all(8.0),
                  child:
                      Icon(onStopPlayerPressed() != null ? Icons.stop : null),
                ),
              ),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
        ),
        Container(
          height: 30.0,
          child: Slider(
              value: min(sliderCurrentPosition, maxDuration),
              min: 0.0,
              max: maxDuration,
              onChanged: (double value) async {
                await playerModule!
                    .seekToPlayer(Duration(milliseconds: value.toInt()));
              },
              divisions: maxDuration == 0.0 ? 1 : maxDuration.toInt()),
        ),
        Container(
          height: 30.0,
          child: Text(_duration != null ? "Duration: $_duration sec." : ''),
        ),
      ],
    );

// ------------------Image picker----------------------------------------------------

    Future createPodcastInFireStore({
      String? title,
      String? description,
      String? content,
      String? albumArt,
    }) async {
      String postId = Uuid().v4();
      try {
        await postsRef
            .doc(widget.currentUser.id)
            .collection('userPosts')
            .doc(postId)
            .set({
          'postId': postId,
          'ownerId': widget.currentUser.id,
          'username': widget.currentUser.username,
          'title': title,
          'type': 'PODCAST',
          'description': description,
          'content': content,
          'timestamp': timestamp,
          'likes': {},
          'mediaUrl': albumArt,
        });
      } catch (e) {
        print(e);
      }
    }

    var _image;
    final picker = ImagePicker();

    void buildPickImage() async {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      setState(() {
        // if (pickedFile != null) {
        _image = File(pickedFile!.path);
        //   print('this is picked image');
        //   print(_image.toString());
        // } else {
        //   print('no Image selected');
        // }
      });
    }

    var pickedImage;
    final _pickr = ImagePicker();
    void buidImage() async {
      final pick = await _pickr.pickImage(source: ImageSource.gallery);

      setState(() {
        pickedImage = File(pick!.path);
      });
    }

    Future<String?> uploadAlbumArt(profile) async {
      String postId = const Uuid().v4();
      // try {
      final ref = FirebaseStorage.instance.ref().child('profile_$postId.png');
      // } catch (e) {
      //   print(e);
      // }
      await ref.putFile(profile);
      final downloadUrl = await ref.getDownloadURL();
      print(downloadUrl);

      // StorageUploadTask uploadTask =
      //     storageRef.child('profile_$postId.png').putFile(profile);
      // StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
      // String? downloadUrl = await (storageSnap.ref.getDownloadURL() as FutureOr<String?>);

      setState(() {
        albumArtUrl = downloadUrl;
      });
      print("done");

      return downloadUrl;
    }

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Create Podcast'),
          actions: <Widget>[
            FlatButton(
              child: Text(
                process ? "Uploading" : "POST",
                style: TextStyle(
                  color: Colors.white,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () async {
                setState(() {
                  process = true;
                });
                print(albumArtUrl);
//
                // await uploadPodcast(file)
                //     .then(
                //       (value) => createPodcastInFireStore(
                //         title: blogTitleController.text,
                //         description: blogDescriptionController.text,
                //         albumArt: albumArtUrl,
                //         content: podCastUrl,
                //       ),
                //     )
                //     .whenComplete(
                //       () => Navigator.of(context).pop(),
                //     );
                _showToast(
                  title: "PODCAST is Uploaded",
                  color: Colors.green,
                  icon: Icons.check,
                );
              },
            )
          ],
        ),
        body: Stack(
          children: <Widget>[
            ListView(
              children: <Widget>[
                // recorderSection,
                const SizedBox(
                  height: 40,
                ),
                const Center(
                  child: Text(
                    "Preview",
                    style: TextStyle(fontSize: 30),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  padding: const EdgeInsets.only(top: 10),
                  child: TextField(
                    controller: blogTitleController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), labelText: "Title"),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Container(
                  height: 200,
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 30),
                  padding: EdgeInsets.only(top: 10),
                  child: TextField(
                    maxLines: 4,
                    minLines: 3,
                    maxLength: 200,
                    controller: blogDescriptionController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), labelText: "Description"),
                  ),
                ),

                // ----------------------------------------------------------------

                // // if (_image != null)
                // CircleAvatar(
                //   radius: 30,
                //   backgroundImage:
                //       pickedImage != null ? FileImage(pickedImage) : null,
                // ),
                // TextButton(
                //   onPressed: buidImage,
                //   child: const Text('get image'),
                // ),

                // Container(
                //   child: _image == null
                //       ? Text('data')
                //       :
                //       //  Image.file(_image)
                //       Text(_image!.toString()),
                // ),
                const SizedBox(
                  height: 30,
                ),
                artFlag
                    ? const LinearProgressIndicator()
                    : Container(
                        margin: const EdgeInsets.symmetric(horizontal: 50),
                        child: RaisedButton(
                          onPressed: () async {
                            if (albumArtUrl == null) {
                              buildPickImage();
                              setState(() {
                                artFlag = true;
                              });
                              await uploadAlbumArt(_image);
                              setState(() {
                                artFlag = false;
                              });
                            } else {
                              setState(() {
                                albumArtUrl = null;
                              });
                            }
                          },
                          color: albumArtUrl != null
                              ? Colors.red
                              : Colors.deepPurple,
                          child: Text(
                            albumArtUrl != null
                                ? "Remove Album Art"
                                : "Upload Album Art",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                albumArtUrl != null
                    ? Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        height: 200,
                        width: 150,
                        child: Image.network(
                          albumArtUrl!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Container(),

                //  ------------------------------------------------------------
                playerSection,
                Padding(
                  padding: EdgeInsets.only(top: 20.0, left: 70, right: 70),
                  child: RaisedButton(
                    elevation: 15,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Text(
                      'Or Upload from Files',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.0,
                      ),
                    ),
                    color: Colors.blue,
                    onPressed: () async {
                      filepath = await FilePicker.platform.pickFiles(
                        type: FileType.audio,
                        //   allowedExtensions: ['pdf','docx'], //here you can add any of extention what you need to pick
                      );

                      print(filepath);
                      print("filepath");

                      // ---------------------------------------------------music---

                      filepath = await FilePicker.platform.pickFiles(
                        type: FileType.audio,
                      ) as File;

                      if (File(filepath.toString()).lengthSync() < 52428800) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LocalPodcast(
                              assetPath: filepath,
                              currentUser: currentUser,
                            ),
                          ),
                        );
                      } else {
                        _showToast(
                            title: "File Size is Over 50 MB",
                            color: Colors.red,
                            icon: Icons.cancel);
                      }
                    },
                  ),
                ),
              ],
            ),
            process
                ? Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                        child: SpinKitThreeBounce(
                      color: Colors.grey,
                      size: 35,
                    )
                        // CircularProgressIndicator(
                        //   valueColor:
                        //       new AlwaysStoppedAnimation<Color>(Colors.white),
                        // )
                        ))
                : Container(),
          ],
        ));
  }

  _showToast({required title, color, icon}) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: color,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
          ),
          SizedBox(
            width: 12.0,
          ),
          Text(
            title,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );

    // return flutterToast.showToast(
    //   child: toast,
    //   gravity: ToastGravity.BOTTOM,
    //   toastDuration: Duration(seconds: 2),
    // );
  }
}
