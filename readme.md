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
   variable. Current area can be got via `PolygonBody:getArea()` (**A1**).

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

   
