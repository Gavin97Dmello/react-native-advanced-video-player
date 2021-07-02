# React Native Advanced Video Player
[![Build Status](https://travis-ci.org/joemccann/dillinger.svg?branch=master)](https://travis-ci.org/joemccann/dillinger)

A video player for react native with advanced controls made for react native.

  - Swipe To Seek
  - Native Brightness & Volume Controls
  - Playing videos directly from a link or from a local path
  - Supports RTMP & HLS live streaming

### Peer Dependencies

This packages depends on the below packages to function properly:
* [Orientation Locker](https://www.npmjs.com/package/react-native-orientation-locker) - Uses to force the user include landscape/portrait mode
* [Safe aArea](https://www.npmjs.com/package/react-native-safe-area) - Uses to calculate fullscreen dimensions for iOS with safe area insets
* [Home Indicator](https://www.npmjs.com/package/react-native-home-indicator) - Uses to hide iOS home indicator on newer gen iPhones

### Installation
Install the dependencies at the root of your React Native project.

##### For React Native > 0.60

```sh
$ npm install --save react-native-advanced-video-player
```
##### For React Native < 0.59
```sh
$ npm install --save react-native-advanced-video-player
$ react-native link react-native-advanced-video-player
```

### Additional Configurations
#### Android
##### MainApplication.java

```java
import com.rn_advanced_video_player.AdvancedVideoPackage;

@Override
protected List<ReactPackage> getPackages() {
    List<ReactPackage> packages = new PackageList(this).getPackages();
    ...
    packages.add(new AdvancedVideoPackage());
    return packages;
}
```

#### iOS
Download the icons required for the iOS side to work from the link below:-
https://drive.google.com/drive/folders/1MJgxymYo5_6rjimKgKXn5OIwSkckb0C3?usp=sharing

Paste the icons into your Project.xcworkspace/Images.xcassets directory

### Basic Usage
```sh
import RNVideoPlayer from "react-native-advanced-video-player";

<RNVideoPlayer
    source={"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"}
    playerStyle={{
      width: 300,
      height: 450
    }}
/>
````

### Props
| Property | Type | Default | Descrption |
| ------ | ------ | ----- | ------ |
| source | string | null | URL or path to video |
| playerStyle | object | {} | Styling for the player container |
| fullscreen | boolean | false | Determines whether the button should show fullscreen or not at first |
| swipeToSeek | boolean | true | When true, user can swipe on the container to seek the video. *NOT AVAILABLE for RTMP stream* |
| seekBarColor | string | #ffffff | Custom color for seekbar |
| showFullscreenControls | boolean | true | Shows the fullscreen and back button |
| showLikeButton | boolean | true | Shows the like button |
| showShareButton | boolean | true | Shows the share button |
| showDownloadButton | boolean | true | Shows the download button |

### Callbacks
| Property | Descrption |
| ------ | ------ |
| onFullscreen | When the fullscreen button is pressed |
| onBackPressed | When the back button is pressed |
| onLikePressed | When the like button is pressed |
| onSharePressed | When the share button is pressed |
| onDownloadPressed | When the download button is pressed |
| onControlsShow | When the controls overlay is shown |
| onControlsHide | When the controls overlay is hidden |
| onEnterFullsceen | When the video player enters fullscreen mode |
| onLeaveFullscreen | When the video player leaves fullscreen mode |

### Methods
| Property | Descrption |
| ------ | ------ |
| pause | Pauses the videoplayer |
| play | Plays the videoplayer |
| mutePlayer | Mutes the videoplayer |
| unmutePlayer | Unmutes the videoplayer |
| showSystemHUD | Method to switch to showing native iOS volume bar HUD | *ONLY FOR iOS |
| killVideoPlayer | Kills video player instance, *CALL to make sure video is stopped playing in background* |

### Todos

 - Add more props to make it more configurable

License
----

MIT


**Free Software, Hell Yeah!**

[//]: # (These are reference links used in the body of this note and get stripped out when the markdown processor does its job. There is no need to format nicely because it shouldn't be seen. Thanks SO - http://stackoverflow.com/questions/4823468/store-comments-in-markdown-syntax)


   [dill]: <https://github.com/joemccann/dillinger>
   [git-repo-url]: <https://github.com/joemccann/dillinger.git>
   [john gruber]: <http://daringfireball.net>
   [df1]: <http://daringfireball.net/projects/markdown/>
   [markdown-it]: <https://github.com/markdown-it/markdown-it>
   [Ace Editor]: <http://ace.ajax.org>
   [node.js]: <http://nodejs.org>
   [Twitter Bootstrap]: <http://twitter.github.com/bootstrap/>
   [jQuery]: <http://jquery.com>
   [@tjholowaychuk]: <http://twitter.com/tjholowaychuk>
   [express]: <http://expressjs.com>
   [AngularJS]: <http://angularjs.org>
   [Gulp]: <http://gulpjs.com>

   [PlDb]: <https://github.com/joemccann/dillinger/tree/master/plugins/dropbox/README.md>
   [PlGh]: <https://github.com/joemccann/dillinger/tree/master/plugins/github/README.md>
   [PlGd]: <https://github.com/joemccann/dillinger/tree/master/plugins/googledrive/README.md>
   [PlOd]: <https://github.com/joemccann/dillinger/tree/master/plugins/onedrive/README.md>
   [PlMe]: <https://github.com/joemccann/dillinger/tree/master/plugins/medium/README.md>
   [PlGa]: <https://github.com/RahulHP/dillinger/blob/master/plugins/googleanalytics/README.md>
