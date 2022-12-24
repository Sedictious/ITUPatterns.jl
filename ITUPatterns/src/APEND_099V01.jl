include("./AntennaPattern.jl")

struct APEND_099V01 <: AntennaPattern
    gain::Float64
end

function description(_::APEND_099V01)
    return "Non-directional earth station antenna pattern."
end

function information(_::APEND_099V01)
    return "Non-directional earth station antenna pattern equal to the maximum antenna gain for all off-axis angles."
end

function copolar_gain(pattern::APEND_099V01, _::Float64)
    return pattern.gain
end

