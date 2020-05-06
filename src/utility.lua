function randf(...)
    if arg.n == 2 then
        return arg[1] + math.random()*(arg[2] - arg[1])
    else
        return arg[1] * math.random()
    end
end
