import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="video-player"
export default class extends Controller {
  static targets = [ "video" ]
  static values = { videoUrl: String }

  // Connect the video player when the controller is connected
  connect() {
    const player = videojs(
      this.videoTarget.id,
      {},
      function onPlayerReady() {
        this.play();
      }
    );

    player.hlsQualitySelector();
    player.src({
      src: this.videoUrlValue,
      type: 'application/x-mpegURL',
      withCredentials: true
    });
  }

  // Disconnect the video player when the controller is disconnected
  disconnect() {
    videojs(this.videoTarget.id).dispose();
  }
}
