include("./AntennaPattern.jl")

struct APSEST640V01 <: AntennaPattern
    gain::Float64
end

function description(_::APSEST640V01)
    return "Space station antenna pattern submitted by EST for network
    ESTCUBE-2 for patch antenna for 2.4 GHz downlink. Gmax = 8 dB."
end

function information(_::APSEST640V01)
    return ""
end

function copolar_gain(pattern::APSEST640V01, φ::Float64)
    if φ < 0 || φ > 2π
        @error "φ must be between 0 and 2π"
    end

    if φ > π
        φ = 2π  - φ
    end

    φ = φ * 180/π
    
    if 0 < φ < 150
        return pattern.gain - 7.91 * 10^-6 * φ - 2 * 10^-3 * φ^2 + 3.35*10^-8 * φ^3 +
        4.08*10^-8 * φ^4
    else
        return -16
    end
end

