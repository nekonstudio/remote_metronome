# Remote Metronome
Metronome application written with Flutter for Android mobile devices. 
 Application has three main features:
 - playing basic metronome
 - creating setlists consisting of multiple metronomes
 - remote synchronized simultaneous metronome playing on multiple devices

## Basic metronome

Play metronome sounds based on settings: tempo, beats pear bar and click per beat. 

![Simple metronome screen](https://i.postimg.cc/wT2hjbbn/simlpe-metronome.gif)

## Setlists

Create multiple setlists containing multiple metronome tracks with different setting playback settings. 
Track can be:
 - simple - with only one metronome settings
 - complex - with one or more sections, each one containing different metronome settings
 
![Setlists screen](https://i.postimg.cc/Rq5h1YL1/setlistgif.gif) 
![Adding new track](https://i.postimg.cc/1RqyZJHS/new-track.gif)

## Remote synchronized playing

In the application you use previously described features in remote synchronized mode. 
In this mode you can create a session, where one device (host) can trigger playing metronome on another connected devices (clients). Host is synchronized with connected clients and every time he plays metronome on his device, other devices starts to play in synchronization with host device. The connection is made using [Nearby Connections API](https://developers.google.com/nearby/connections/overview).


*Left screenshot - host, right screenshot - client*

![Host connecting screen](https://i.postimg.cc/NMD4XThb/host-sync-start.gif) ![Client connecting screen](https://i.postimg.cc/8zftYjWP/client-sync-start.gif)

![Host screen](https://i.postimg.cc/sgy0M5NQ/host.gif) ![Client screen](https://i.postimg.cc/cJCh3hMH/client.gif)