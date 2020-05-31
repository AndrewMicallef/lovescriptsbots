function countitems(table)
    local count = 0

    if not table.__dirty and table.__count then
        return table.__count
    end

    for _, v in pairs(table) do
        count = count + 1
    end

    if table.__count then
        table.__count = count
    end

    return count
end
