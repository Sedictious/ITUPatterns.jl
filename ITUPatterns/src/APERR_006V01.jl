include("./AntennaPattern.jl")

struct APERR_006V01 <: AntennaPattern
    gain::Float64
    beamwidth::Float64

    """
        APERR_006V01(gain, bandwidth)

    # Arguments
    - `gain::Float64`: Gain of the antenna [dB]
    - `bandwidth::Float64`: Half-Power Beam Width [deg]
    """
    function APERR_006V01(gain::Float64, beamwidth::Float64)
        if (beamwidth < 0.1) || (beamwidth > 10)
            @warn "Beamwidth is out of limits [0.1:10.0]."
        end

        new(gain, beamwidth)
    end
end

function description(_::APERR_006V01)
    return "Appendix 30 reference receiving earth station antenna pattern for
    Regions 1 and 3 for individual reception (1977 BSS Plan)."
end

function information(_::APERR_006V01)
    return """
    Used in the original 1977 Conference BSS Plan and for the assignments notified and brought into use before 27 October
    1997.
    In the original 1977 BSS Plan the minimum antenna diameter was such that the half-power beamwidth was 2 degrees for
    individual reception.
    The pattern requires input parameter beamwidth.
    """
end


function copolar_gain(pattern::APERR_006V01, φ::Float64)
    if φ < 0 || φ > 2π
        @error "φ must be between 0 and 2π"
    end

    if φ > π
        φ = 2π  - φ
    end

    φ = φ * 180/π
    if 0 <= φ < 0.25*pattern.beamwidth
            return pattern.gain
    elseif 0.25*pattern.beamwidth <= φ < 0.707*pattern.beamwidth
        return pattern.gain - 12*(φ/pattern.beamwidth)^2 
    elseif 0.707*pattern.beamwidth <= φ < 1.26*pattern.beamwidth
        return pattern.gain - 9 - 20*log10(φ/pattern.beamwidth)
    elseif 1.26*pattern.beamwidth <= φ < 9.55*pattern.beamwidth
        return pattern.gain - 8.5 - 25*log10(φ/pattern.beamwidth)
    else
        return pattern.gain-33
    end
end

function crosspolar_gain(pattern::APERR_006V01, φ::Float64)
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
    elseif 0.44*pattern.beamwidth <= φ < 1.4*pattern.beamwidth
        gx = pattern.gain - 20
    elseif 1.4*pattern.beamwidth <= φ < 2*pattern.beamwidth
        gx = pattern.gain - 30 - 25*log10(φ/pattern.beamwidth)
    else
        gx = pattern.gain - 30
    end

    if gx > g
        return g
    else
        return gx
    end
end