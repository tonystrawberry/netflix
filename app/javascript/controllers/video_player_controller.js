import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="video-player"
export default class extends Controller {
  static targets = [ "video" ]
  static values = { videoUrl: String }

  connect() {
    // https://spekiyoblog.com/how-to-set-cookie-to-hlsjs-request/
    // const config =
    //   {
    //       xhrSetup: function (xhr, url)
    //       {
    //         xhr.withCredentials = true; // do send cookies

    //       },
    //       fetchSetup: function (context, initParams)
    //       {
    //         console.log("fetchSetup");
    //           // Always send cookies, even for cross-origin calls.
    //           initParams.credentials = 'include';
    //           return new Request(context.url, initParams);
    //       },
    //   };

    // if (Hls.isSupported()) {
    //   console.log("HLS supported");
    //   var hls = new Hls(config);

    //   hls.loadSource(this.videoUrlValue);
    //   hls.attachMedia(this.videoTarget);
    //   this.videoTarget.play();
    // } else if (this.videoTarget.canPlayType('application/vnd.apple.mpegurl')) {
    //   this.videoTarget.src = this.videoUrlValue;
    //   this.videoTarget.addEventListener('canplay',function() {
    //     this.videoTarget.play();
    //   });
    // }

    const options = {};

    var player = videojs(this.videoTarget.id, options, function onPlayerReady() {
      videojs.log('Your player is ready!');

      // In this context, `this` is the player that was created by Video.js.
      // this.play();

      // How about an event listener?
      this.on('ended', function() {
        videojs.log('Awww...over so soon?!');
      });
    });
    // player.hlsQualitySelector();
    player.src({
      src: this.videoUrlValue,
      type: 'application/x-mpegURL',
      withCredentials: true
  });


  }
}
