include("./AntennaPattern.jl")

struct APEUAE229V01 <: AntennaPattern
    gain::Float64

    function APEUAE229V01(gain::Float64)
        if gain < 12
            @error "Gain is less than 12"
        end

        new(gain)
    end
end

function description(_::APEUAE229V01)
    return "Earth station antenna pattern submitted by UAE for 12 dB earth
    station."
end

function information(_::APEUAE229V01)
    return ""
end

function copolar_gain(pattern::APEUAE229V01, φ::Float64)
    if φ < 0 || φ > 2π
        @error "φ must be between 0 and 2π"
    end

    if φ > π
        φ = 2π  - φ
    end

    φ = φ * 180/π
    
    if 0 <= φ < 23
        return pattern.gain - 12 * (φ/28)^2
    elseif 23 <= φ < 50
        return 38 - 25 * log10(φ)
    else
        return -5
    end
    
end

