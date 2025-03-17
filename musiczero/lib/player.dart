import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class PlayerScreen extends StatefulWidget {
  final Map<String, dynamic> song;
  final List<Map<String, dynamic>> playlist;
  final AudioPlayer audioPlayer;

  const PlayerScreen({
    super.key,
    required this.song,
    required this.playlist,
    required this.audioPlayer,
  });

  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool isPlaying = false;
  int currentIndex = 0;
  Duration? _currentPosition;
  Duration? _totalDuration;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.playlist.indexOf(widget.song);
    // Initialize the audio player with the current song's URL
    widget.audioPlayer.setUrl(widget.playlist[currentIndex]['url']);

    // Listen to the player state to update the play/pause button
    widget.audioPlayer.playerStateStream.listen((playerState) {
      setState(() {
        isPlaying = playerState.playing;
      });
    });
  }

  void _playSong() async {
    await widget.audioPlayer.play();
  }

  void _pauseSong() async {
    await widget.audioPlayer.pause();
  }

  void _playNext() {
    if (currentIndex < widget.playlist.length - 1) {
      currentIndex++;
    } else {
      currentIndex = 0;
    }
    _loadAndPlaySong();
  }

  void _playPrevious() {
    if (currentIndex > 0) {
      currentIndex--;
    } else {
      currentIndex = widget.playlist.length - 1;
    }
    _loadAndPlaySong();
  }

  void _loadAndPlaySong() async {
    await widget.audioPlayer.setUrl(widget.playlist[currentIndex]['url']);
    if (isPlaying) {
      await widget.audioPlayer.play();
    }
    setState(() {}); // Update the UI to reflect the new song
  }

  void _seekToPosition(Duration position) async {
    await widget.audioPlayer.seek(position);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final currentSong =
        widget.playlist[currentIndex]; // Get the currently playing song

    return Scaffold(
      appBar: AppBar(
        title: Text('Now Playing'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Display the album art of the currently playing song
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.network(
              currentSong['albumArt'],
              width: 200,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.music_note, size: 100, color: Colors.grey);
              },
            ),
          ),
          SizedBox(height: 20),
          // Display the title of the currently playing song
          Text(
            currentSong['title'],
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          // Display the artist of the currently playing song
          Text(
            currentSong['artist'],
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 20),
          // Display the progress bar and duration
          StreamBuilder<Duration>(
            stream: widget.audioPlayer.positionStream,
            builder: (context, snapshot) {
              _currentPosition = snapshot.data ?? Duration.zero;
              return StreamBuilder<Duration?>(
                stream: widget.audioPlayer.durationStream,
                builder: (context, snapshot) {
                  _totalDuration = snapshot.data ?? Duration.zero;
                  return Column(
                    children: [
                      Slider(
                        value: _currentPosition!.inSeconds.toDouble(),
                        min: 0,
                        max: _totalDuration!.inSeconds.toDouble(),
                        onChanged: (value) {
                          _seekToPosition(Duration(seconds: value.toInt()));
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(_currentPosition!),
                              style: TextStyle(fontSize: 14),
                            ),
                            Text(
                              _formatDuration(_totalDuration!),
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          SizedBox(height: 20),
          // Playback controls (previous, play/pause, next)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.skip_previous, size: 30),
                onPressed: _playPrevious,
              ),
              IconButton(
                icon:
                    Icon(isPlaying ? Icons.pause : Icons.play_arrow, size: 40),
                onPressed: () {
                  if (isPlaying) {
                    _pauseSong();
                  } else {
                    _playSong();
                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.skip_next, size: 30),
                onPressed: _playNext,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
