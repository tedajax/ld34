function lerp(a, b, t)
    return a + (b - a) * t
end

function clamp(a, min, max)
    if a < min then
        return min
    elseif a > max then
        return max
    else
        return a
    end
end

function hsv_to_rgb(h, s, v)
    local h = math.fmod(h, 360)
    local s = clamp(s, 0, 1)
    local v = clamp(v, 0, 1)

    local c = v * s
    local x = c * (1 - math.abs(math.fmod((h / 60), 2) - 1))
    local m = v - c

    local rp, gp, bp = 0, 0, 0

    if h < 60 then
        rp = c
        gp = x
    elseif h < 120 then
        rp = x
        gp = c
    elseif h < 180 then
        gp = c
        bp = x
    elseif h < 240 then
        gp = x
        bp = c
    elseif h < 300 then
        rp = x
        bp = c
    elseif h < 360 then
        rp = c
        bp = x
    end

    local r = math.floor((rp + m) * 255)
    local g = math.floor((gp + m) * 255)
    local b = math.floor((bp + m) * 255)
    return r, g, b
end
