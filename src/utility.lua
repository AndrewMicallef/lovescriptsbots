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
