import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="video-player"
export default class extends Controller {
  static targets = [ "video" ]
  static values = { videoUrl: String }

  connect() {
    // Fetch videoURL manually to set cookies
    fetch(this.videoUrlValue, { credentials: 'include' })
      .then(response => response.json())
      .then(data => {
        console.log(data);
      });


    // https://spekiyoblog.com/how-to-set-cookie-to-hlsjs-request/
    const config =
      {
          xhrSetup: function (xhr, url)
          {
            xhr.withCredentials = true; // do send cookies

          },
          fetchSetup: function (context, initParams)
          {
            console.log("fetchSetup");
              // Always send cookies, even for cross-origin calls.
              initParams.credentials = 'include';
              return new Request(context.url, initParams);
          },
      };

    if (Hls.isSupported()) {
      console.log("HLS supported");
      var hls = new Hls(config);

      hls.loadSource(this.videoUrlValue);
      hls.attachMedia(this.videoTarget);
      this.videoTarget.play();
    } else if (this.videoTarget.canPlayType('application/vnd.apple.mpegurl')) {
      this.videoTarget.src = this.videoUrlValue;
      this.videoTarget.addEventListener('canplay',function() {
        this.videoTarget.play();
      });
    }
  }
}
