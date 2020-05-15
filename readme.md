# Love:ScriptBots

This project is a hobbiests fork of Andrej Karpathy's [ScriptBots], rewritten
in the [love2D] engine.

--------------------------------------------------------------------------------

# RoadMap

* [x] Basic Agent Dynamics
* [x] Basic Metabolism
* [ ] Reproduction
* [ ] Evolution
* [ ] Learning

* [ ] Dynamic Polygon Bodies
* [ ] Geometric Logic

[ScriptBots]:(https://github.com/Ramblurr/scriptbots)
[love2d]:(https://love2d.org/)

--------------------------------------------------------------------------------

# current status



2020.05.14 `working on endocytosis`

In order to get a simulation of endocytosis I think it would be nice to model
a membrane stretching between verticies on my `PolygonBody` object. The membrane
will have a certain elasticity, which is to say below a certain length it will
act like a spring. However if it is extended to beyond it's max length it should
snap, or break.

The membrane will be rendered as a bezier curve, so to start with I will make a
super class of the `love.math.BezierCurve`. I need to add some features to the
curve that love gives me. Specifically I need to implement a way of getting the
length of the curve.
Getting the length of a Bezier curve is non-trivial. But in game worlds we can
cheat! As always check stack exhcange and find a solution to the problem of
[arc-length parameterization] and associated [gist].

[arc-length parameterization]:(https://gamedev.stackexchange.com/a/5427/139632)
[gist]:(https://gist.github.com/BonsaiDen/670236)


okay let's be real, bsplines are fun, but their physics is difficult...back to
polygons!
