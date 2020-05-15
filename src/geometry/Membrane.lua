Membrane = Class{}

--[[
loosley based off: https://gist.github.com/BonsaiDen/670236
]]

function Membrane:init(def)
    self.curve = love.math.newBezierCurve(def.control_points)

    self.N = def.N or 50 -- resolution for arc-length paramaterization
    self.arcLengths = {0}

    local agglen --length aggregator
    local ox, oy = unpack(self.control_points)
    for i=1, self.N do
        local x, y = self.curve:evaluate(i / self.N)
        local dx, dy = self.x0 - x, self.y0 - y
        agglen = agglen + math.sqrt(dx^2 + dy^2)
        table.insert(self.arcLengths, agglen)
        ox, oy = x, y
    end

    -- length of this curve is the aggregate length of all arcs
    self.length = agglen

end

--[[
function Bezier(a, b, c, d) {
    this.a = a;
    this.b = b;
    this.c = c;
    this.d = d;

    this.len = 100;
    this.arcLengths = new Array(this.len + 1);
    this.arcLengths[0] = 0;

    var ox = this.x(0), oy = this.y(0), clen = 0;
    for(var i = 1; i <= this.len; i += 1) {
        var x = this.x(i * 0.01), y = this.y(i * 0.01);
        var dx = ox - x, dy = oy - y;
        clen += Math.sqrt(dx * dx + dy * dy);
        this.arcLengths[i] = clen;
        ox = x, oy = y;
    }
    this.length = clen;
}

Bezier.prototype = {
    map: function(u) {
        var targetLength = u * this.arcLengths[this.len];
        var low = 0, high = this.len, index = 0;
        while (low < high) {
            index = low + (((high - low) / 2) | 0);
            if (this.arcLengths[index] < targetLength) {
                low = index + 1;

            } else {
                high = index;
            }
        }
        if (this.arcLengths[index] > targetLength) {
            index--;
        }

        var lengthBefore = this.arcLengths[index];
        if (lengthBefore === targetLength) {
            return index / this.len;

        } else {
            return (index + (targetLength - lengthBefore) / (this.arcLengths[index + 1] - lengthBefore)) / this.len;
        }
    },

    mx: function (u) {
        return this.x(this.map(u));
    },

    my: function (u) {
        return this.y(this.map(u));
    },

    x: function (t) {
        return ((1 - t) * (1 - t) * (1 - t)) * this.a.x
               + 3 * ((1 - t) * (1 - t)) * t * this.b.x
               + 3 * (1 - t) * (t * t) * this.c.x
               + (t * t * t) * this.d.x;
    },

    y: function (t) {
        return ((1 - t) * (1 - t) * (1 - t)) * this.a.y
               + 3 * ((1 - t) * (1 - t)) * t * this.b.y
               + 3 * (1 - t) * (t * t) * this.c.y
               + (t * t * t) * this.d.y;
    }
};
]]
