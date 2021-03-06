import 'package:kuncie_music/core.dart';

class AlbumController extends SuperController<Album> {
  AlbumController({required this.albumRepository});
  static AlbumController to = Get.find();
  IAlbumRepository albumRepository;
  Album? albumsArtist;

  @override
  void onInit() async {
    super.onInit();

    getTopAlbums();
  }

  Future<void> getTopAlbums() async {
    //Loading, Success, Error handle with 1 line of code
    return append(() => albumRepository.getTopAlbums);
  }

  Future<void> getArtistAlbums(String id) async {
    albumsArtist = await albumRepository.getArtistAlbums(id);
    update();
  }

  @override
  void onDetached() {
    // Implement onDetached
  }

  @override
  void onInactive() {
    // Implement onInactive
  }

  @override
  void onPaused() {
    // Implement onPaused
  }

  @override
  void onResumed() {
    // Implement onResumed
  }
}
