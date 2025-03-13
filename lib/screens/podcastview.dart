import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:global_ios/widgets/app_service.dart';
import 'package:just_audio/just_audio.dart';

class PodcastView extends StatefulWidget {
  final content;
  final title;
  final mediaUrl;
  var description;

  PodcastView({this.content, this.title, this.mediaUrl, this.description});

  @override
  _PodcastViewState createState() => _PodcastViewState();
}

class _PodcastViewState extends State<PodcastView> {
  @override
  void initState() {
    super.initState();
    appService.eventBus.on().listen((event) {
      if (event != "${this.widget.mediaUrl}") {
        player.stop();
      }
    });
  }

  AudioPlayer player = AudioPlayer();
  bool isPlaying = false;

  fnLoadPlayer() async {
    var duration = await player.setUrl(this.widget.content);
    appService.eventBus.fire("${this.widget.mediaUrl}");
    await player.play();

    setState(() {
      isPlaying = true;
    });
  }

  fnPause() {
    player.pause();
    setState(() {
      isPlaying = false;
    });
  }

  getlist(playing, state, buffering) {
    if (state == ProcessingState.loading || buffering == true) {
      return Container(
          margin: const EdgeInsets.all(8.0),
          width: 64.0,
          height: 64.0,
          child: SpinKitCircle(
            color: Colors.grey,
          )
          // CircularProgressIndicator(),
          );
    } else if (playing == true) {
      return IconButton(
        icon: Icon(Icons.pause),
        iconSize: 64.0,
        onPressed: () {
          player.pause();
        },
      );
    } else {
      return IconButton(
        icon: Icon(Icons.play_arrow),
        iconSize: 64.0,
        onPressed: fnLoadPlayer,
      );
    }
  }

  @override
  void dispose() {
    // print("test i am here");
    if (isPlaying) {
      player.pause().then((value) => player.dispose());
    } else {
      player.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          child: Column(
        children: <Widget>[
          FancyShimmerImage(
            imageUrl: widget.mediaUrl,
            boxFit: BoxFit.contain,
            width: 300,
            height: 300,
          ),
          Text(
            widget.title ?? "",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.blueGrey),
          ),
          StreamBuilder(
              stream: player.playerStateStream,
              builder: (context, AsyncSnapshot snapshot) {
                final fullState = snapshot.data;
                final state = fullState?.processingState;
                final playing = fullState?.playing;
                return Row(mainAxisSize: MainAxisSize.min, children: [
                  getlist(playing, state, ProcessingState.buffering),
                  IconButton(
                    icon: Icon(Icons.stop),
                    iconSize: 64.0,
                    onPressed: player.playing ? player.stop : null,
                  )
                ]);
              }),
          StreamBuilder(
            stream: player.durationStream,
            builder: (context, AsyncSnapshot snapshot) {
              final duration = snapshot.data ?? Duration.zero;
              return StreamBuilder<Duration>(
                // stream: player.getPositionStream(),
                stream: player.positionStream,
                builder: (context, snapshot) {
                  var position = snapshot.data ?? Duration.zero;
                  if (position > duration) {
                    position = duration;
                  }

                  // print(position);

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      IconButton(
                          icon: Icon(Icons.replay_10),
                          iconSize: 40.0,
                          onPressed: () {
                            player.seek(position - position ~/ 5);
                          }),
                      SeekBar(
                        duration: duration,
                        position: position,
                        onChanged: (value) {
                          // print(value);
                          // print("0000000000000000000000000000000000000000000000");
                          player.seek(value);
                        },
                        onChangeEnd: (newPosition) {
                          player.seek(newPosition);
                        },
                      ),
                      IconButton(
                          icon: Icon(Icons.forward_10),
                          iconSize: 40.0,
                          onPressed: () {
                            player.seek(position + position ~/ 5);
                          }),
                    ],
                  );
                },
              );
            },
          ),
        ],
      )),
    );
  }
}

class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final ValueChanged<Duration> onChanged;
  final ValueChanged<Duration> onChangeEnd;

  SeekBar({
    required this.duration,
    required this.position,
    required this.onChanged,
    required this.onChangeEnd,
  });

  @override
  _SeekBarState createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double _dragValue = 0;

  @override
  Widget build(BuildContext context) {
    return Slider(
      min: 0.0,
      max: widget.duration.inMilliseconds.toDouble(),
      value: widget.position.inMilliseconds.toDouble(),
      onChanged: (value) {
        setState(() {
          _dragValue = value;
        });
        if (widget.onChanged != null) {
          widget.onChanged(Duration(milliseconds: value.round()));
        }
      },
      onChangeEnd: (value) {
        _dragValue = 0;
        if (widget.onChangeEnd != null) {
          widget.onChangeEnd(Duration(milliseconds: value.round()));
        }
      },
    );
  }
}
