function randf(...)
    arg = {...}
    arg.n = #arg

    if arg.n == 2 then
        return arg[1] + math.random()*(arg[2] - arg[1])
    else
        return arg[1] * math.random()
    end
end


-- normalvariate random N(mu, sigma)
function randn(mu, sigma)
    local deviateAvailable = false
    local storedDeviate -- deviate from previous calculation

    local var1, var2, rsquared

    if not deviateAvailable then
        while  (rsquared >= 1) or (rsquared == 0) do
            var1=2 * math.random() - 1
            var2=2 * math.random() - 1
            rsquared = var1*var1 + var2*var2
        end
        polar=math.sqrt(-2 * math.log(rsquared)/rsquared)
		storedDeviate=var1*polar
		deviateAvailable = true
		return var2*polar*sigma + mu
    else
        deviateAvailable = false
        return storedDeviate * sigma + mu
    end
end

function cappedvalue(v, min, max)

    min = min or 0
    max = max or 1

    return math.max(0, math.min(v, 1))

end

-- http://neuralnetworksanddeeplearning.com/chap1.html
-- equation 3
function softmax(x)
    return 1 / (1 + math.exp(-x))
end


function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

-- creates a table with a numerical index and item count
function Ntable(table)
    local ntable = {}

    local _count = tablelength(table)
    -- yields an array of keys in a set order
    local _keys = {}
    for _, k in pairs(table) do
        ntable[k] = 0 -- initialise to zero
        _keys[#_keys+1] = k
    end
    ntable._keys = _keys
    ntable._count = _count

    return ntable
end

-- https://www.mathopenref.com/coordpolygonarea2.html
function polygonArea(points)
    -- where X, Y is a list of points in the arangements x1,y1,x2,y2 ... xn,yn
    local area = 0 -- Accumulates area
    local prevpoint = #points
    local numpoints = #points

    for i=1, numpoints do
     area = area + (points[prevpoint].x+points[i].x) * (points[prevpoint].y-points[i].y)
     prevpoint = i  -- j is previous vertex to i
    end
      return area/2
end

function Edge(u, v)
    local edge = {u, v}
    table.sort(edge)
    return edge
end



--[[-----------------------------------------------------------------------------
-- https://rosettacode.org/wiki/Convex_hull#Lua
function print_point(p)
    io.write("("..p.x..", "..p.y..")")
    return nil
end

function print_points(pl)
    io.write("[")
    for i,p in pairs(pl) do
        if i>1 then
            io.write(", ")
        end
        print_point(p)
    end
    io.write("]")
    return nil
end

function ccw(a,b,c)
    return (b.x - a.x) * (c.y - a.y) > (b.y - a.y) * (c.x - a.x)
end

function pop_back(ta)
    table.remove(ta,#ta)
    return ta
end

function convexHull(pl)
    if #pl == 0 then
        return {}
    end
    table.sort(pl, function(left,right)
        return left.x < right.x
    end)

    local h = {}

    -- lower hull
    for i,pt in pairs(pl) do
        while #h >= 2 and not ccw(h[#h-1], h[#h], pt) do
            table.remove(h,#h)
        end
        table.insert(h,pt)
    end

    -- upper hull
    local t = #h + 1
    for i=#pl, 1, -1 do
        local pt = pl[i]
        while #h >= t and not ccw(h[#h-1], h[#h], pt) do
            table.remove(h,#h)
        end
        table.insert(h,pt)
    end

    table.remove(h,#h)
    return h
end

-- main
local points = {
    {x=16,y= 3},{x=12,y=17},{x= 0,y= 6},{x=-4,y=-6},{x=16,y= 6},
    {x=16,y=-7},{x=16,y=-3},{x=17,y=-4},{x= 5,y=19},{x=19,y=-8},
    {x= 3,y=16},{x=12,y=13},{x= 3,y=-4},{x=17,y= 5},{x=-3,y=15},
    {x=-3,y=-9},{x= 0,y=11},{x=-9,y=-3},{x=-4,y=-2},{x=12,y=10}
}
local hull = convexHull(points)

io.write("Convex Hull: ")
print_points(hull)
print()
]]
