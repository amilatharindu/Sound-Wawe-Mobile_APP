import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musicwave/album_songs.dart';

class AllAlbumsScreen extends StatelessWidget {
  final Map<String, List<Map<String, dynamic>>> albums;
  final AudioPlayer audioPlayer;

  const AllAlbumsScreen({
    super.key,
    required this.albums,
    required this.audioPlayer,
    required List<Map<String, dynamic>> favoriteSongs,
    required List<Map<String, dynamic>> playlist,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Albums'),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.0), // Add padding around the ListView
        itemCount: albums.length,
        itemBuilder: (context, index) {
          final albumName = albums.keys.elementAt(index);
          final albumSongs = albums[albumName]!;
          final coverArt = albumSongs.isNotEmpty
              ? albumSongs[0]['albumArt']
              : 'https://via.placeholder.com/150';

          return Container(
            margin:
                EdgeInsets.only(bottom: 16.0), // Add margin between containers
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 97, 93, 90),
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
                  coverArt,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.album, size: 50, color: Colors.grey);
                  },
                ),
              ),
              title: Text(
                albumName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              subtitle: Text(
                '${albumSongs.length} songs',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              trailing: Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AlbumSongsScreen(
                      albumName: albumName,
                      songs: albumSongs,
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
