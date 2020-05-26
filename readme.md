# Love:ScriptBots

This project is a hobbyists fork of Andrej Karpathy's [ScriptBots], rewritten
in the [love2D] engine.

--------------------------------------------------------------------------------

# RoadMap

* [X] Basic Agent Dynamics
* [X] Basic Metabolism
* [ ] Reproduction
* [ ] Evolution
* [ ] Learning

* [ ] Dynamic Polygon Bodies
* [ ] Geometric Logic
--------------------------------------------------------------------------------

# What I am currently Working on:

## Soft body finalisation

* [ ] Allow organelle to trigger unlinking of membrane segments
* [ ] Allow organelle to grab and hold vertex segments

With the above 2 features implemented I should be able to get organelle mediated
endocytosis (which ultimately means the brain can control eating).

[ScriptBots]:(https://github.com/Ramblurr/scriptbots)
[love2d]:(https://love2d.org/)


2020 - 05 - 26 DISCORD LOG
```
AndrewMicallefToday at 12:30 PM
Can I use shaders in love to write code that runs on the GPU but doesn't have graphics effects, but instead returns some values?
Context: i want to have an artificial neural network control ai in my love game, and ann's run alot of simple code in parrallel
Böb Röss (ffi.free(_G))Today at 12:30 PM
love doesn't have yet direct compute shaders iirc
AndrewMicallefToday at 12:31 PM
?iirc
This wouldn't be very efficient, but could I somehow pipe input values in from a seperate program instead (ie write my ai in python and get it to feed data to my love app somehow)
RynelfToday at 12:34 PM
do you doubt luajit
Böb Röss (ffi.free(_G))Today at 12:34 PM
python ai libs anyways will go interface with C, aren't there Lua AI libs
like torch ?
LuaJIT is fast but for paralel there's so much you can do
AndrewMicallefToday at 12:35 PM
I don't know, I felt a considerable slowdown in some less complex analogous code I wrote on the weekend, so if I could parrallelize it somehow thatd be great :yum:
Böb Röss (ffi.free(_G))Today at 12:35 PM
i blame globals
AndrewMicallefToday at 12:36 PM
Havent looked around (part of my project is for me to build my own network )
Although maybe I might checkout torch if it turns out to be too hard
Ahh torch does sound like the ticket, though it looks like it would make any future distribution a bit of a headache, having to seperatly install torch
Böb Röss (ffi.free(_G))Today at 12:42 PM
you'd want a library file probably
AndrewMicallefToday at 12:42 PM
Also seems to be cuda...i have an amd card
(Im out of the loop not sure if thatll be an issue...but my budget doesnt allow me to buy new hardware)
I might have to put this in the 'too hard basket'
Böb Röss (ffi.free(_G))Today at 12:44 PM
there' are serveral back ends arent there
AndrewMicallefToday at 12:45 PM
(I'll have to do a proper read of the docs, i did just a quick scan tbh)
Böb Röss (ffi.free(_G))Today at 12:46 PM
torch isn't in active dev now tough
AndrewMicallefToday at 12:47 PM
This might be going off topic, but I think I'd want an openGL solution, to be consistant with cross-compatibility
Positive07 (he/him)Today at 1:00 PM
@tessa (he/she/they/???) regarding HC, it's nicer in terms of garbage than Bump, but it doesn't do continuous collision detection. Bump does continuous AABB but has some garbage issues
Maybe consider love.physics?
a13X_BToday at 1:08 PM
@AndrewMicallef you can do it with just pixel and vertex shaders, Max already did it.
tessa (he/she/they/???)Today at 1:21 PM
yeah i'm using love.physics atm
AndrewMicallefToday at 4:18 PM
@a13X_B , @Max  could you pm me more info?
MaxToday at 4:21 PM
@AndrewMicallef I don't do PM's, but check out the enbody toy I linked above, it does an n body particle simulation on the gpu
You can do it but you need to get your head around how to store your data and what the best model for mutating it is
Gpgpu is not easy in opengl
AndrewMicallefToday at 4:22 PM
Sounds like fun, thanks
MaxToday at 4:22 PM
I also have an erosion sim and a neural net lib, one is open source one is not :thumbsup:
a13X_BToday at 4:23 PM
I'd even say not convenient, but yet doable
AndrewMicallefToday at 4:23 PM
Well writting my own neural net was the goal of the project...so that i can live with
MaxToday at 4:23 PM
The general idea is you use a fragment shader to render new data to textures from old data, and potentially also use a point mesh to modify arbitrary points in another texture.
ilovelove2019and2020Today at 7:16 PM
Hello
AndrewMicallefToday at 7:17 PM
Okay so I just had a chance to take a look at enbody. 1) That is super cool, 2) OpenGL looks an awfull lot like regular C code 3) is there any particular point where you transfer  data back to the lua from the shader (not through rendering the pixel values to the screen?)
a13X_BToday at 7:21 PM
@AndrewMicallef probably he doesn't since data transformation and rendering are both done on gpu side. If you want to transfer data back to cpu you can use getImagedata() on your canvas iirc
AimeJohnsonToday at 7:22 PM
newImageData
AndrewMicallefToday at 7:23 PM
Oh that is kinda trippy, but I think I get it. Basically my neural net would be modelled as an image, and you would read out pixel values as the output?
I'm pretty sure I read that in a sci-fi once
Thanks, this has been super enlightening
AimeJohnsonToday at 7:26 PM
Note that reading data back from the GPU is very expensive
You want to minimize the number of times you have to do that as much as possible
AndrewMicallefToday at 7:28 PM
Do you think a once per frame might be a bit much>
phreshfish [🌍♣]Today at 7:29 PM
getting back that data might take more than a frame, so yes
AndrewMicallefToday at 7:29 PM
There seams to be a good deal of ground work I have to do before I get to worrying about this, but there is no reason why I need to model thinking in real time :stuck_out_tongue:
AimeJohnsonToday at 7:32 PM
If you have to do it once per frame, then it might, or rather almost certainly will, become a serious bottleneck
a13X_BToday at 7:33 PM
Is it possible to read data back in a separate thread?
AimeJohnsonToday at 7:33 PM
No
The problem is that you stall the rendering pipeline when you read back, it can take a huge amount of time to synchronize
Plus the bus traffic it generates
a13X_BToday at 7:35 PM
You can double buffer. Does it depend on a canvas size?
AimeJohnsonToday at 7:35 PM
I use it extensively for texture generation, but avoid it for realtime stuff
https://community.khronos.org/t/why-is-gpu-cpu-transfer-slow/58708
Khronos Forums
Why is GPU-CPU transfer slow?
Everywhere I read that GPU to CPU transfers are horribly slow. Now I’ve had my fair share of GPU programming so I know this is true, but I’m wondering why? At first I thought it had to do with the bandwidth between the GPU and CPU. I guess it would have something to do with i...

AndrewMicallefToday at 7:36 PM
At this stage I have no idea about the size and shape of my network, but before I checkout that link, does the size make a material difference in this regard?
AimeJohnsonToday at 7:38 PM
It plays a role, but it depends on a bunch of factors, like bus speed. Stalling is the main problem
AndrewMicallefToday at 7:38 PM
okay, right, so in the real world GPU outputs go direct to visual display and not back to CPU
AimeJohnsonToday at 7:39 PM
On PCs, yes
a13X_BToday at 7:41 PM
Reading back the results asynchronously (after a few frames), allows the GPU continue execution without its threads starving (the stop-and-resume issue outlined above). This improves performance tremendously - the more parallel the GPU, the higher the performance improvement.

So pretty much multibuffer and hope for the best
AndrewMicallefToday at 7:42 PM
I guess I should still do the hard work anyway, if only to learn GLSL, and secondly to see if the buffering is slower than what I have now, (at the moment my program hangs for about a second each time my agent stops to think)
AimeJohnsonToday at 7:42 PM
There are also huge differences between different GPUs. What works fine on one GPU might crawl on another
a13X_BToday at 7:45 PM
maybe you'd be better off with a threaded task scheduler
AndrewMicallefToday at 7:46 PM
Could do, honestly I have no idea what I don't know in this space, and this seams to be another thing I don't know
a13X_BToday at 7:48 PM
thread pool or just a single thread that crunches heavy tasks like ANNs and doesn't stall the main thread
AndrewMicallefToday at 7:53 PM
Sounds also like a good idea... so do something like love.thread.newThread([[ANN code]])
and then pop the ANN output whenever it is available...
If I had multiple agents, I would setup a new thread per agent?
a13X_BToday at 7:55 PM
that would be counterproductive
AndrewMicallefToday at 7:56 PM
:frowning:
a13X_BToday at 7:58 PM
imagine you have agents twice your physical threads, you won't gain any speedup and still lose on thread switching and sync (pumping data with love thread messages)
AndrewMicallefToday at 8:02 PM
ok, I just read the thread pool wikipedia page and while the concept makes sense, I wouldn't have the faintest where to start implementing that.
a13X_BToday at 8:05 PM
start with a single thread that receives a task(a value for example), executes it (transforms the value), and sends the result back
AndrewMicallefToday at 8:07 PM
ok, so I setup a new thread myANN, make it sense something (recieve a value from the world), and output  a command (modify agent's velocity based on value)

```lua
-- for argument let's say the ANN code takes 1 value as input, and outputs another value via an 'output' channel
--sensor = some value

myANN  = love.thread.newThread([[ANN code]])
myANN:start(sensor)
--...

function love.update()
  -- other stuff...
  output = love.thread.getChannel( 'output' ):pop()
  if output then
      agent:move(output)
  end
end


```
a13X_BToday at 8:12 PM
yes, you pretty much send ANN inputs to your thread, as soon as the thread detects them it runs ANN and sends back ANN outputs. keep in mind that you likely won't get results on the same frame
AndrewMicallefToday at 8:15 PM
So my agent will still be thinking every second, but the other stuff in the gameworld will keep buzzing around it anyway...It might even be fun to play with that in the model, maybe have some agents with simpler brains that can outpace more complex agents, but necessarily have much more limited behaviour
a13X_BToday at 8:21 PM
you may want to separate learning part so your agent doesn't think for a whole second before it acts
AndrewMicallefToday at 8:22 PM
Maybe, as I said before I have quite a bit of groundwork to cover, and seems like I expended my dev time today, but long run I want a continuosly learning agent (I shouldn;t say wasted, because this conversation was incredibly valuable, thankyou)
even if it is slow,
a13X_BToday at 8:23 PM
or you can separate whole net into simpler tasks and have some sort of scheduler to assign those to threads
AndrewMicallefToday at 8:24 PM
Time to get back to the real world, Cheers @a13X_B :slight_smile:
(I will probably pester you again to elborate on that last bit, if I haven't worked something out)
a13X_BToday at 8:25 PM
sure thing, have fun with multithreading
```

Based on the chat I want to try 3 things...
1. implement a simple neural net as per Karpathy, nothing fancy
2. attempt to re implement the neural net code inside a threading pool as per a13X_B suggests
3. attempt to remodel the neural net as an image and implement in GLSL (HARD OPTION)
Once all three are complete, profile...
