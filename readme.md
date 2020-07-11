# Playing with vision

Agents see the world around them through

```
zorgToday at 4:06 PM
@AndrewMicallef make a short SoundData, e.g. 1024 or 2048 samples long (there's a variant of it that takes a length, bit depth, sample rate and channel count), then create one QueueableSource; while the QSource has free buffers, fill the SD in a loop and queue that into the QS.
and forget about FFI, you don't need it
these are already coded to make use of that and luaJIT anyway
setSample i mean
and checking for empty QS buffers is done with a method it gives you... shitty laptop so i cant look it up quickly enough :v
AndrewMicallefToday at 4:09 PM
no worries, I think the above is more than enough for me to go on
Appreciate it :slight_smile:
zorgToday at 4:10 PM
sure; one more thing though; my solution is for both syntesis and realtime playback
if you only want to render something "offline", then you don't need a Qsource (nor a sounddata, you could just write all the data directly to disk)
or, if you just want to procgen sound effects, you could do that into (longer) sounddata only, then create regular sources from those, and play them back like normal (like they were made from files on disk i mean)
AndrewMicallefToday at 4:13 PM
hmm, have to think through my design a  little, I realised that there are soundeffects I can apply, but I'm not really sure if I want those. Basically what I'm aiming for is to have some 'agents' singing to each other, and i want to know exactly what waveform each of them is producing, so I know what the others can hear. And I want them to respond to each others chirping (so they change their tone / pitch depending on who they hear around them)
So I think I want to have the first solution,
zorgToday at 4:15 PM
yep, i think so too; short buffer means much more responsive design
for the sake of simplicity, i hope you're also just sending more simpler data to the other agents; parsing audio waveforms is hard
in terms of what they "hear" i mean
AndrewMicallefToday at 4:16 PM
haha, yeah they hear a vector of the paramaters used to generate the waveform
(although the complex way would be cool too... for the sake of my own satisfaction)
escape to cancel • enter to save
```
