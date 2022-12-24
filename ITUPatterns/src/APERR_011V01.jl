include("./AntennaPattern.jl")

struct APERR_011V01 <: AntennaPattern
    gain::Float64
    diameter::Float64

    """
        APERR_011V01(gain)

    # Arguments
    - `gain::Float64`: Gain of the antenna [dB]. Must belong to the range [19.7, 24.8]
    - `diameter::Float64`: Diameter of antenna [m]
    """
    function APERR_011V01(gain::Float64, diameter::Float64)
        if diameter < 2.5
            @error "Diameter is less than 2.5 m. Limit for Diameter in RR: D > 2.5 m."
        end
    
        new(gain, diameter)
    end
end

function description(_::APERR_011V01)
    return "Appendix 30A reference transmitting earth station antenna pattern
    for Region 2."
end

function information(_::APERR_011V01)
    return "The pattern was used for planning purposes of the feeder-link frequency band 17.3-17.8 GHz in the Appendix 30A Plan of
    the Radio Regulations.
    The feeder-link Plan was based on an antenna diameter of 5 m. The minimum antenna diameter permitted in the Plan is
    2.5 m. The Plan is based on antenna efficiency of 0.65. The corresponding on-axis gain for an antenna having a 5 m
    diameter is 57.4 dBi at 17.55 GHz.
    The co-polar pattern is extended for angles less than 0.1 degrees as equal to on-axis gain.
    The pattern requires input parameter antenna diameter."
end

function copolar_gain(pattern::APERR_011V01, φ::Float64)
    if φ < 0 || φ > 2π
        @error "φ must be between 0 and 2π"
    end

    if φ > π
        φ = 2π  - φ
    end

    φ = φ * 180/π

    if 0 <= φ < 0.1
        return pattern.gain
    elseif 0.1 <= φ < 0.32
        return min(36 - 20log10(φ), pattern.gain)
    elseif 0.32 <= φ < 0.54
        return min(51.3 - 53.2 * φ^2, pattern.gain)
    else
        return min(max(29 - 25log10(φ), -10), pattern.gain)
    end
end

function crosspolar_gain(pattern::APERR_010V01, φ::Float64)
    if φ < 0 || φ > 2π
        @error "φ must be between 0 and 2π"
    end

    if φ > π
        φ = 2π  - φ
    end

    φ = φ * 180/π

    if 0 <= φ < 0.6/pattern.diameter
        gx = pattern.gain - 30
    else
        gx = max(9 - 20log10(φ), -10)
    end
    
    if gx > pattern.gain - 30
        return pattern.gain - 30
    end

    return gx
end