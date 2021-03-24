# Remote Metronome
Metronome application written with Flutter for Android mobile devices. 
 Application has three main features:
 - playing basic metronome
 - creating setlists consisting of multiple metronomes
 - remote synchronized simultaneous metronome playing on multiple devices

## Basic metronome

Play metronome sounds based on settings: tempo, beats per bar and clicks per beat. 

![Simple metronome screen](https://i.postimg.cc/wT2hjbbn/simlpe-metronome.gif)

## Setlists

Create multiple setlists containing multiple metronome tracks with different setting playback settings. 
Track can be:
 - simple - with only one metronome settings
 - complex - with one or more sections, each one containing different metronome settings
 
![Setlists screen](https://i.postimg.cc/Rq5h1YL1/setlistgif.gif) 
![Adding new track](https://i.postimg.cc/1RqyZJHS/new-track.gif)

## Remote synchronized playing

In the application you can use previously described features in remote synchronized mode. 
In this mode you can create a session, where one device (host) can connect and synchronize with other devices running an instance of this application (clients). Once connection is established, if host starts to play metronome, this other devices start to play in synchronization with host's device. The connection between devices is made using [Nearby Connections API](https://developers.google.com/nearby/connections/overview).


*Left screenshot - host, right screenshot - client*

![Host connecting screen](https://i.postimg.cc/NMD4XThb/host-sync-start.gif) ![Client connecting screen](https://i.postimg.cc/8zftYjWP/client-sync-start.gif)

![Host screen](https://i.postimg.cc/sgy0M5NQ/host.gif) ![Client screen](https://i.postimg.cc/cJCh3hMH/client.gif)