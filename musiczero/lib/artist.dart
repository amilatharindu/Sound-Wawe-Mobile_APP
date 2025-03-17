import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'player.dart';
import 'home.dart';
import 'favorites.dart';

class ArtistScreen extends StatelessWidget {
  final List<Map<String, dynamic>> favoriteSongs;
  final List<Map<String, dynamic>> playlist;
  final int currentIndex; // Pass the current index
  final Function(int) onTabTapped; // Callback to update the index

  const ArtistScreen({
    super.key,
    required this.playlist,
    required this.favoriteSongs,
    required this.currentIndex,
    required this.onTabTapped,
  });

  @override
  Widget build(BuildContext context) {
    // Group songs by artist
    final Map<String, List<Map<String, dynamic>>> artists = {};
    for (var song in playlist) {
      final artistName = song['artist'];
      if (!artists.containsKey(artistName)) {
        artists[artistName] = [];
      }
      artists[artistName]!.add(song);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Artists'),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        itemCount: artists.length,
        itemBuilder: (context, index) {
          final artistName = artists.keys.elementAt(index);
          final artistSongs = artists[artistName]!;
          final artistImage = artistSongs.isNotEmpty
              ? artistSongs[0]['albumArt']
              : 'https://via.placeholder.com/150';

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ArtistDetailScreen(
                    artistName: artistName,
                    artistSongs: artistSongs,
                  ),
                ),
              );
            },
            child: Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor, // Use theme card color
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(artistImage),
                    radius: 25,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        artistName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color, // Use theme text color
                        ),
                      ),
                      Text(
                        '${artistSongs.length} songs',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color, // Use theme text color
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex, // Use the passed currentIndex
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MusicPlayerScreen(
                  toggleTheme: (isDark) {}, // Pass your toggleTheme function
                  currentIndex: 0, // Pass the current index
                  onTabTapped: onTabTapped, // Pass the callback
                ),
              ),
            ).then((_) {
              onTabTapped(2); // Reset to Artists screen index when returning
            });
          } else if (index == 1) {
            // Navigate to Favorites
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FavoritesScreen(
                  favoriteSongs: favoriteSongs, // Pass the actual favoriteSongs list
                  audioPlayer: AudioPlayer(),
                  currentIndex: 1,
                  onTabTapped: onTabTapped,
                  playlist: playlist,
                  toggleFavorite: (int) {},
                ),
              ),
            ).then((_) {
              onTabTapped(2); // Reset to Artists screen index when returning
            });
          } else if (index == 2) {
            // Already on Artists screen
          }
        },
      ),
    );
  }
}

class ArtistDetailScreen extends StatelessWidget {
  final String artistName;
  final List<Map<String, dynamic>> artistSongs;

  const ArtistDetailScreen({
    super.key,
    required this.artistName,
    required this.artistSongs,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(artistName),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage(artistSongs[0]['albumArt']),
              radius: 50,
            ),
          ),
          const SizedBox(height: 16), // Added SizedBox for spacing
          Expanded(
            child: ListView.builder(
              itemCount: artistSongs.length,
              itemBuilder: (context, index) {
                final song = artistSongs[index];
                return Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor, // Use theme card color
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
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
                          return const Icon(Icons.music_note,
                              color: Colors.grey);
                        },
                      ),
                    ),
                    title: Text(
                      song['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color, // Use theme text color
                      ),
                    ),
                    subtitle: Text(
                      song['albumName'] ?? 'Unknown Album',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color, // Use theme text color
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlayerScreen(
                            song: song,
                            playlist: artistSongs,
                            audioPlayer: AudioPlayer(), // Pass the audioPlayer
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}