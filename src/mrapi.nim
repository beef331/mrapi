import jsffi, asyncjs, dom
export jsffi, dom

proc getAudioRecorder*(name: string, constraint: JsObject){.importC:"GetAudioRecorder".}
proc getAudioSource*(): JsObject{.importC:"GetAudioSource".}

proc getScreenRecorder*(name: string, constraint: JsObject){.importC:"GetScreenRecorder".}


proc audioConstraint*: JsObject =
  result = newJsObject()
  result.audio = true

proc videoConstraint*: JsObject =
  result = newJsObject()
  result.video = true
  result.audio = true
  result.cursor = "always"

proc startAudioRecorder*(recorder: JsObject){.importC:"StartRecorder".}
proc stopAudioRecorder*(recorder: JsObject){.importC:"StopRecorder".}

proc playBlob*(blob: JsObject, source: JsObject){.importC:"PlayBlob".}
proc playVideoStream*(stream: JsObject, element: Element){.importC:"PlayVideoStream".}

var 
  onSoundRecorderMade*{.exportC.}: proc(name: string, recorder: JsObject)
  onScreenRecorderMade*{.exportC.}: proc(name: string, recorder: JsObject)
  onSourceData*{.exportC.}: proc(name: string, blob: JsObject)

{.emit: """
function GetAudioRecorder(name, constraints)
{
  navigator.mediaDevices.getUserMedia(constraints).then(function(stream)
  {
    if (onSoundRecorderMade){
      let mediaRecorder = new MediaRecorder(stream);
      mediaRecorder.ondataavailable = function(e) {
        var chunks = [];
        chunks.push(e.data);
        onSourceData(name, chunks[0]);
      }
      mediaRecorder.onstop = function(e){
      }
      onSoundRecorderMade(name, mediaRecorder);
    }
  });
}

function GetScreenRecorder(name, constraint)
{
  navigator.mediaDevices.getDisplayMedia(constraint).then(function(stream){
    if(onScreenRecorderMade){
      onScreenRecorderMade(name, stream);
    }
  });
}

function GetAudioSource(){
  let audio = new Audio;
  var mediaSource = new MediaSource;
  audio.src = URL.createObjectURL(mediaSource);
  let audioSource =  {"audio": audio, "mediasource": mediaSource}
  mediaSource.onsourceopen = () => audioSource.buffer = mediaSource.addSourceBuffer("audio/webm;codecs=opus");
  return audioSource;
}


function PlayBlob(blob, audioSource)
{
  let fileReader = new FileReader();
  fileReader.readAsArrayBuffer(blob);

  fileReader.onload = function(event) {
    let arrayBuffer = fileReader.result;
    if(audioSource.audio.error != null) console.log(audioSource.audio.error);
    audioSource.buffer.appendBuffer(arrayBuffer);
    audioSource.audio.play();
  };
}

function PlayVideoStream(stream, element)
{
  element.srcObject = stream;
}

function StartRecorder(recorder)
{
  recorder.start(100);
}

function StopRecorder(recorder)
{
  recorder.stop();
}

""".}