include("./AntennaPattern.jl")

struct APEUSA236V01 <: AntennaPattern
    gain::Float64
end

function description(_::APEUSA236V01)
    return "Earth station antenna pattern submitted by USA for the GOES
    networks DCP PLATFORM. Maximum antenna gain is fixed to 14.8
    dB."
end

function information(_::APEUSA236V01)
    return ""
end

function copolar_gain(pattern::APEUSA236V01, φ::Float64)
    if φ < 0 || φ > 2π
        @error "φ must be between 0 and 2π"
    end

    if φ > π
        φ = 2π  - φ
    end

    φ = φ * 180/π
    
    if 0 <= φ < 32
        return pattern.gain
    elseif 32 <= φ < 50
        return pattern.gain * (1 - ((φ - 8)/16.468)^2)
    elseif 19 <= φ < 30
        return 7.2
    elseif 30 <= φ < 76
        return 44.887 - 25.514 * log10(φ)
    else
        return -3.1
    end
end

