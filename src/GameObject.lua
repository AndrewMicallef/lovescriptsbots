GameObject = Class{}

GameObject.__type = 'GameObject'

function GameObject:type()
    return self.__type
end

function GameObject:typeOf(name)
    return self:type() == name
end

function GameObject:release()
    self = nil
    return true
end
