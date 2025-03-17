import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'player.dart';
import 'home.dart'; // Import home.dart for navigation
import 'artist.dart'; // Import artist.dart for navigation

class FavoritesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> favoriteSongs;
  final AudioPlayer audioPlayer;
  final int currentIndex; // Pass the current index
  final Function(int) onTabTapped; // Callback to update the index
  final List<Map<String, dynamic>> playlist; // Add playlist as a parameter
  final Function(int) toggleFavorite; // Add toggleFavorite function

  const FavoritesScreen({
    super.key,
    required this.favoriteSongs,
    required this.audioPlayer,
    required this.currentIndex,
    required this.onTabTapped,
    required this.playlist, // Add playlist to the constructor
    required this.toggleFavorite, // Add toggleFavorite to the constructor
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Songs'),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: favoriteSongs.isEmpty
          ? Center(
              child: Text(
                'No favorite songs yet.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            )
          : ListView.builder(
              itemCount: favoriteSongs.length,
              itemBuilder: (context, index) {
                final song = favoriteSongs[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        song['albumArt'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.music_note,
                              color: Theme.of(context).colorScheme.secondary);
                        },
                      ),
                    ),
                    title: Text(song['title'],
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(song['artist'],
                        style: TextStyle(color: Colors.grey)),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.favorite,
                        color: Colors.red, // Always show as favorite in this screen
                      ),
                      onPressed: () {
                        // Find the index of the song in the main playlist
                        final songIndex = playlist.indexWhere((s) => s['title'] == song['title']);
                        if (songIndex != -1) {
                          toggleFavorite(songIndex); // Toggle the favorite status
                        }
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlayerScreen(
                            song: song,
                            playlist: favoriteSongs,
                            audioPlayer: audioPlayer,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex, // Use the passed currentIndex
                                   // Color for the selected icon
        unselectedItemColor: Colors.grey, // Color for unselected icons
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: '',
          ),
        ],
        onTap: (index) {
          onTabTapped(index); // Update the current index
          if (index == 0) {
            // Navigate to Home
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MusicPlayerScreen(
                  toggleTheme: (isDark) {}, // Pass your toggleTheme function
                  currentIndex: 0,
                  onTabTapped: onTabTapped,
                ),
              ),
            );
          } else if (index == 1) {
            // Already on Favorites screen
          } else if (index == 2) {
            // Navigate to Artists
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ArtistScreen(
                  playlist: playlist, // Pass the actual playlist
                  currentIndex: 2,
                  onTabTapped: onTabTapped,
                  favoriteSongs: favoriteSongs,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}