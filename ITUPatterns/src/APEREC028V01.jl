include("./AntennaPattern.jl")

struct APEREC028V01 <: AntennaPattern
    gain::Float64

    """
        APEREC028V01(gain)

    # Arguments
    - `gain::Float64`: Gain of the antenna [dB]. Must be over 4
    """
    function APEREC028V01(gain::Float64)
        
        if gain < 4
            @error "Gain is less than 4 dB"
        end
        
        new(gain)
    end
end

function description(_::APEREC028V01)
    return "Recommendation ITU-R M.1091, annex 1 reference radiation
    pattern for transportable or vehicle-mounted earth station
    antennas with a gain of 12 to 18 dB and with a frequency between
    1 to 3 GHz for use in the land mobile-satellite service"
end

function information(_::APEREC028V01)
    return "Recommendation ITU-R M.1091, annex 1 reference radiation 
    pattern for transportable or vehicle-mounted earth station antennas 
    with a gain of 12 to 18 dB and with a frequency between 1 to 3 GHz 
    for use in the land mobile-satellite service."
end

function copolar_gain(pattern::APEREC028V01, φ::Float64)
    if φ < 0 || φ > 2π
        @error "φ must be between 0 and 2π"
    end

    if φ > π
        φ = 2π  - φ
    end

    φ = φ * 180/π

    if 0 <= φ < 40
        return pattern.gain
    elseif 40 <= φ < 90
        return 44 - 25 * log10(φ)
    else
        return -5    
    end
end