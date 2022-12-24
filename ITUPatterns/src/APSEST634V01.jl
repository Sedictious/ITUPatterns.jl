include("./AntennaPattern.jl")

struct APSEST634V01 <: AntennaPattern
    gain::Float64

    function APSEST634V01(gain::Float64)
        if gain < 36.3
            @error "Gain is less than 36.3"
        end
        
        new(gain)
    end
end

function description(_::APSEST634V01)
    return "Space station antenna pattern submitted by USA for USASAT-NGSO-
    9A network for TUA2 and RUA2 beams"
end

function information(_::APSEST634V01)
    return ""
end

function copolar_gain(pattern::APSEST634V01, φ::Float64)
    if φ < 0 || φ > 2π
        @error "φ must be between 0 and 2π"
    end

    if φ > π
        φ = 2π  - φ
    end

    φ = φ * 180/π
    
    if 0 < φ <= 2.44
        return gain - 3 * (φ/1.22)^2
    elseif 2.44 < φ <= 20
        return 34 - 25 * log10(φ) 
    else
        return 1.5
    end
end