when not defined(js): {.error: "This is a JS API, learn to read".}
import ./src/mrapi
var 
  microphone = jsNull
  screen = jsNull
  audioSource = getAudioSource()

proc onSoundRecMade(name: string, rec: JsObject)=
  microphone = rec
  microphone.startAudioRecorder()

proc onScreenRecMade(name: string, rec: JsObject)=
  screen = rec
  screen.playVideoStream(document.getElementsByTagName("video")[0])

proc onData(name: string, blob: JsObject)=
  blob.playBlob(audioSource)

onSoundRecorderMade = onSoundRecMade
onScreenRecorderMade = onScreenRecMade
onSourceData = onData 

getAudioRecorder("microphone", audioConstraint())
getScreenRecorder("screen", videoConstraint())