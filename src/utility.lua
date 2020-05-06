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


function softmax(v)
    -- TODO implement softmax
end
