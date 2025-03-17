import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musicwave/player.dart';

class AlbumSongsScreen extends StatelessWidget {
  final String albumName;
  final List<Map<String, dynamic>> songs;
  final AudioPlayer audioPlayer;

  const AlbumSongsScreen({
    super.key,
    required this.albumName,
    required this.songs,
    required this.audioPlayer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(albumName),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.0), // Add padding around the ListView
        itemCount: songs.length,
        itemBuilder: (context, index) {
          final song = songs[index];
          return Container(
            margin:
                EdgeInsets.only(bottom: 12.0), // Add margin between containers
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 97, 93, 90),
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.white,
                  blurRadius: 6.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding:
                  EdgeInsets.all(16.0), // Add padding inside the ListTile
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  song['albumArt'],
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.music_note, size: 50, color: Colors.grey);
                  },
                ),
              ),
              title: Text(
                song['title'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              subtitle: Text(
                song['artist'],
                style: TextStyle(color: Colors.white),
              ),
              trailing:
                  Icon(Icons.play_arrow, color: Colors.grey), // Add a play icon
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlayerScreen(
                      song: song,
                      playlist: songs,
                      audioPlayer: audioPlayer,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
