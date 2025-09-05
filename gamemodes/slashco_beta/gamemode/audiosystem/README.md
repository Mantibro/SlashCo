# Audio System

This audio system was created as a replacement for the engine sound system, as it's more flexible.  
Using the `IGModAudioChannel` you have generally far more control over the audio than with the engine stuff.  
Additionally, you can play far more sound files and don't have to use `.wav` at `44100` or `.mp3` files.

Depending on what is trying to be done, it would sometimes still be better to use `CreateSound` instead of this system, but that purely depends on the use case.