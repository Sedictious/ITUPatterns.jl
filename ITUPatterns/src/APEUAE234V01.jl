include("./AntennaPattern.jl")

struct APEUAE234V01 <: AntennaPattern
    gain::Float64

    function APEUAE234V01(gain::Float64)
        if gain < 7.2
            @error "Gain is less than 7.2"
        end
        
        new(gain)
    end
end

function description(_::APEUAE234V01)
    return "Earth station antenna pattern submitted by UAE for transmitting
    13 dB earth station."
end

function information(_::APEUAE234V01)
    return ""
end

function copolar_gain(pattern::APEUAE234V01, φ::Float64)
    if φ < 0 || φ > 2π
        @error "φ must be between 0 and 2π"
    end

    if φ > π
        φ = 2π  - φ
    end

    φ = φ * 180/π
    
    if 0 <= φ < 8
        return pattern.gain
    elseif 8 <= φ < 19
        return pattern.gain * (1 - ((φ - 8)/16.468)^2)
    elseif 19 <= φ < 30
        return 7.2
    elseif 30 <= φ < 76
        return 44.887 - 25.514 * log10(φ)
    else
        return -3.1
    end
end

