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

# Notes on internal pressure...

1. I think pressure is proportional to the change in area. Initial area is
   referred to as `internal_vol` (**A0**), which will later become a dynamic
   variable. Current area can be got via `Membrane:getArea()` (**A1**).

2. The total pressure should sum to 0 when `A1 == A0`

3. Pressure should also be proportional to the ratio of circumferance to area.
   When `A1 == A0` and the ratio of circumferance to area is equal to radius,
   as in a circle (see equations below).

   $circumferance = 2\pi{}r$
   $area = 2\pi{}r^2$
   $\frac{circumferance}{area}  = r$

4. For the moment let's just ignore the fact that circumferance is dynamic. The
   membrane is made of connected springs, so the circumferance is going to grow
   and shrink. For the moment I'm just going to assume that this change is
   marginal, and can be safely ignored.

On reflection it seams that I could model pressure as a force exerted by each
vertex on every other connected vertex. I might trace a ray from each vertex to
all the others, and if the ray can see the other vertex, then I can add a force
inversely proportional to it's length to the contacted vertex.

Ray tracing is probably overkill, at this point I get reasonable results without
taking occlusion into account.

Next step is to ensure the membrane functions as a barrier. To do this I will
use edge shapes between connected verticies to construct the cell wall. The
edges should be masked to ignore the connected verticies, to account for the
fact that the edge length is variable.

So a13X_B#6771 on discord suggested stringing the edges together via rectangles
Each edge would be a relativly small rectange, strung together with two other
partially overlapping rectangles. These would not collide with immediate
connections, but be available to collide with all others.
