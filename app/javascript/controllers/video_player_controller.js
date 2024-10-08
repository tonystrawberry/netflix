import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="video-player"
export default class extends Controller {
  static targets = [ "video" ]

  connect() {
    if (Hls.isSupported()) {
      var hls = new Hls();

      hls.loadSource('https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8');
      hls.attachMedia(this.videoTarget);
      this.videoTarget.play();
    } else if (this.videoTarget.canPlayType('application/vnd.apple.mpegurl')) {
      this.videoTarget.src = 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8';
      this.videoTarget.addEventListener('canplay',function() {
        this.videoTarget.play();
      });
    }
  }
}
