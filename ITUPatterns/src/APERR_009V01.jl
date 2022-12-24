include("./AntennaPattern.jl")

struct APERR_009V01 <: AntennaPattern
    gain::Float64

    """
        APERR_009V01(gain)

    # Arguments
    - `gain::Float64`: Gain of the antenna [dB]. Must belong to the range [19.7, 24.8]
    """
    function APERR_009V01(gain::Float64)
        new(gain)
    end
end

function description(_::APERR_009V01)
    return "Appendix 30A reference transmitting earth station antenna pattern
    for Regions 1 and 3 (WARC Orb-88)."
end

function information(_::APERR_009V01)
    return "Used in the original 1988 feeder-link Plan (WARC Orb-88) and for the assignments notified and brought into use before 27
    October 1997.
    The feeder-link Plan was based on an antenna diameter of 5 m for the band 17.3-18.1 GHz and 6 m for the band 14.5-14.8
    GHz. The on-axis gain was taken as 57 dBi."
end

function copolar_gain(pattern::APERR_009V01, φ::Float64)
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
        return pattern.gain - 21 - 20log10(φ)
    elseif 0.32 <= φ < 0.44
        return pattern.gain - 5.7 - 53.2 * φ^2
    elseif 0.44 <= φ < 48
        return pattern.gain - 25 - 25log10(φ)
    else
        return pattern.gain - 67
    end
end

function crosspolar_gain(pattern::APERR_009V01, φ::Float64)
    if φ < 0 || φ > 2π
        @error "φ must be between 0 and 2π"
    end

    if φ > π
        φ = 2π  - φ
    end

    φ = φ * 180/π

    g = copolar_gain(pattern, φ)
    gx = self.gain - 30

    if gx > g 
        return g
    end

    return gx
end