import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'package:musicwave/all_albums.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'favorites.dart';
import 'player.dart';
import 'artist.dart';

class MusicPlayerScreen extends StatefulWidget {
  final Function(bool) toggleTheme;
  final int currentIndex;
  final Function(int) onTabTapped;

  const MusicPlayerScreen({
    super.key,
    required this.toggleTheme,
    required this.currentIndex,
    required this.onTabTapped,
  });

  @override
  _MusicPlayerScreenState createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Map<String, dynamic>> playlist = [];
  List<Map<String, dynamic>> favoriteSongs = [];
  bool isLoading = true;
  bool hasError = false;
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> filteredPlaylist = [];
  Map<String, List<Map<String, dynamic>>> albums = {};
  int? _currentlyPlayingIndex;

  static const String apiUrl =
      'https://itunes.apple.com/search?term=pop&entity=song&limit=150&country=US';

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchSongs();
    _loadFavoriteSongs();
    _listenToPlayerState();
  }

  void _listenToPlayerState() {
    _audioPlayer.currentIndexStream.listen((index) {
      setState(() {
        _currentlyPlayingIndex = index;
      });
    });
  }

  Future<void> fetchSongs() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tracks = data['results'];

        setState(() {
          playlist = List<Map<String, dynamic>>.from(tracks)
              .map((song) => {
                    'title': song['trackName'],
                    'artist': song['artistName'],
                    'url': song['previewUrl'],
                    'albumArt': song['artworkUrl100'],
                    'albumName': song['collectionName'] ?? 'Unknown Album',
                    'isFavorite': false,
                  })
              .toList();

          for (var song in playlist) {
            if (favoriteSongs
                .any((favSong) => favSong['title'] == song['title'])) {
              song['isFavorite'] = true;
            }
          }

          albums = {};
          for (var song in playlist) {
            final albumName = song['albumName'];
            if (!albums.containsKey(albumName)) {
              albums[albumName] = [];
            }
            albums[albumName]!.add(song);
          }

          filteredPlaylist = List.from(playlist);
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  Future<void> _loadFavoriteSongs() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteSongsJson = prefs.getStringList('favoriteSongs') ?? [];
    setState(() {
      favoriteSongs = favoriteSongsJson
          .map((songJson) => json.decode(songJson) as Map<String, dynamic>)
          .toList();
    });
  }

  Future<void> _saveFavoriteSongs() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteSongsJson =
        favoriteSongs.map((song) => json.encode(song)).toList();
    await prefs.setStringList('favoriteSongs', favoriteSongsJson);
  }

  void toggleFavorite(int index) async {
    final song = filteredPlaylist[index];
    final playlistIndex =
        playlist.indexWhere((s) => s['title'] == song['title']);

    if (playlistIndex != -1) {
      setState(() {
        playlist[playlistIndex]['isFavorite'] =
            !playlist[playlistIndex]['isFavorite'];
        if (playlist[playlistIndex]['isFavorite']) {
          favoriteSongs.add(playlist[playlistIndex]);
        } else {
          favoriteSongs.removeWhere(
              (s) => s['title'] == playlist[playlistIndex]['title']);
        }
      });

      await _saveFavoriteSongs();
    }
  }

  void searchSongs(String query) {
    setState(() {
      filteredPlaylist = playlist
          .where((song) =>
              song['title'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void filterSongsByAlbum(String albumName) {
    setState(() {
      filteredPlaylist = albums[albumName] ?? [];
    });
  }

  void resetSongs() {
    setState(() {
      filteredPlaylist = List.from(playlist);
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sound Wave',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily:
                'Playwrite_India', // Ensure this matches the font family name
          ),
        ),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              widget.toggleTheme(!isDark);
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.secondary))
          : hasError
              ? Center(
                  child: Text('Failed to load songs. Please try again later.',
                      style: TextStyle(color: Colors.red)))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Search songs...',
                          prefixIcon: Icon(Icons.search,
                              color: Theme.of(context).colorScheme.secondary),
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: searchSongs,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Albums',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AllAlbumsScreen(
                                    albums: albums,
                                    audioPlayer: _audioPlayer,
                                    favoriteSongs: favoriteSongs,
                                    playlist: playlist,
                                  ),
                                ),
                              );
                            },
                            child: Text('View All Albums'),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 180,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: albums.length,
                        itemBuilder: (context, index) {
                          final albumName = albums.keys.elementAt(index);
                          final albumSongs = albums[albumName]!;
                          final coverArt = albumSongs.isNotEmpty
                              ? albumSongs[0]['albumArt']
                              : 'https://via.placeholder.com/150';
                          return GestureDetector(
                            onTap: () => filterSongsByAlbum(albumName),
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(12.0)),
                                      child: Image.network(
                                        coverArt,
                                        width: 170,
                                        height: 125,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            width: 140,
                                            height: 140,
                                            color: Colors.grey[300],
                                            child: Icon(Icons.album,
                                                size: 60,
                                                color: Colors.grey[600]),
                                          );
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: SizedBox(
                                        width: 150,
                                        child: Text(
                                          albumName.length > 20
                                              ? '${albumName.substring(0, 20)}...'
                                              : albumName,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Songs',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              resetSongs();
                            },
                            child: Text('View All Songs'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredPlaylist.length,
                        itemBuilder: (context, index) {
                          final isCurrentlyPlaying =
                              _currentlyPlayingIndex == index;
                          return Card(
                            margin: EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 10.0),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  filteredPlaylist[index]['albumArt'],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.music_note,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary);
                                  },
                                ),
                              ),
                              title: Text(filteredPlaylist[index]['title'],
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(filteredPlaylist[index]['artist'],
                                  style: TextStyle(color: Colors.grey)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isCurrentlyPlaying)
                                    Icon(Icons.equalizer,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary),
                                  IconButton(
                                    icon: Icon(
                                      filteredPlaylist[index]['isFavorite']
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => toggleFavorite(index),
                                  ),
                                ],
                              ),
                              onTap: () {
                                setState(() {
                                  _currentlyPlayingIndex = index;
                                });
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PlayerScreen(
                                      song: filteredPlaylist[index],
                                      playlist: filteredPlaylist,
                                      audioPlayer: _audioPlayer,
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MusicPlayerScreen(
                  toggleTheme: widget.toggleTheme,
                  currentIndex: 0,
                  onTabTapped: widget.onTabTapped,
                ),
              ),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FavoritesScreen(
                  favoriteSongs: favoriteSongs,
                  audioPlayer: _audioPlayer,
                  currentIndex: 1,
                  onTabTapped: widget.onTabTapped,
                  playlist: playlist,
                  toggleFavorite: (int) {},
                ),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ArtistScreen(
                  playlist: playlist,
                  currentIndex: 2,
                  onTabTapped: widget.onTabTapped,
                  favoriteSongs: favoriteSongs,
                ),
              ),
            );
          }
        },
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
      ),
    );
  }
}
