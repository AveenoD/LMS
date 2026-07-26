import 'package:youtube_player_iframe/youtube_player_iframe.dart';

void main() {
  YoutubePlayerController? c;
  c?.playerStateStream.listen((state) {
    if (state == PlayerState.playing) {
      print('playing');
    }
  });
}
