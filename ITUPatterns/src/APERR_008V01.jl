include("./AntennaPattern.jl")

struct APERR_008V01 <: AntennaPattern
    gain::Float64
    beamwidth::Float64

    """
        APERR_008V01(gain, bandwidth)

    # Arguments
    - `gain::Float64`: Gain of the antenna [dB]
    - `beamwidth::Float64`: Half-Power Beam Width [deg]
    """
    function APERR_008V01(gain::Float64, beamwidth::Float64)
        if (beamwidth < 0.1) || (beamwidth > 10)
            @warn "Beamwidth is out of limits [0.1:10.0]."
        end

        new(gain, beamwidth)
    end
end

function description(_::APERR_008V01)
    return "Appendix 30 reference receiving earth station antenna pattern for
    Region 2 for individual reception."
end

function information(_::APERR_008V01)
    return """
    This pattern is used for planning the BSS in Region 2.
    The minimum antenna diameter wass such that the half-power beamwidth is 1.7 degrees.
    The pattern requires input parameter beamwidth.
    """
end

function copolar_gain(pattern::APERR_008V01, φ::Float64)
    if φ < 0 || φ > 2π
        @error "φ must be between 0 and 2π"
    end

    if φ > π
        φ = 2π  - φ
    end

    φ = φ * 180/π
    if 0 <= φ < 0.25*pattern.beamwidth
            return pattern.gain
    elseif 0.25*pattern.beamwidth <= φ < 1.13*pattern.beamwidth
        return pattern.gain - 12(φ/pattern.beamwidth)^2 
    elseif 1.13*pattern.beamwidth <= φ < 14.7*pattern.beamwidth
        return pattern.gain - 14 - 25*log10(φ/pattern.beamwidth)
    elseif 14.7*pattern.beamwidth <= φ < 35*pattern.beamwidth
        return pattern.gain - 43.2
    elseif 35*pattern.beamwidth <= φ < 45.1*pattern.beamwidth
        return pattern.gain - 85.2 - 27.2*log10(φ/pattern.beamwidth)
    elseif 45.1*pattern.beamwidth <= φ < 70*pattern.beamwidth
        return pattern.gain - 40.2
    elseif 70*pattern.beamwidth <= φ < 80*pattern.beamwidth
        return pattern.gain + 55.2 - 51.7*log10(φ/pattern.beamwidth)
    else
        return pattern.gain-43.2
    end
end

function crosspolar_gain(pattern::APERR_008V01, φ::Float64)
    if φ < 0 || φ > 2π
        @error "φ must be between 0 and 2π"
    end

    if φ > π
        φ = 2π  - φ
    end

    φ = φ * 180/π

    g = copolar_gain(pattern, φ)

    if 0 <= φ < 0.25*pattern.beamwidth
        gx = pattern.gain - 25
    elseif 0.25*pattern.beamwidth <= φ < 0.44*pattern.beamwidth
        gx = pattern.gain - 30 - 40log10(abs(φ/pattern.beamwidth - 1))
    elseif 0.44*pattern.beamwidth <= φ < 1.28*pattern.beamwidth
        gx = pattern.gain - 20
    elseif 1.28*pattern.beamwidth <= φ < 3.22*pattern.beamwidth
        return min(pattern.gain - 17.3 - 25*log10(φ/pattern.beamwidth), pattern.gain)
    else
        gx = pattern.gain - 30
    end

    if gx > g
        return g
    else
        return gx
    end
end
