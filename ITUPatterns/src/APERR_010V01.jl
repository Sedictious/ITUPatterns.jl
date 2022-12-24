include("./AntennaPattern.jl")

struct APERR_010V01 <: AntennaPattern
    gain::Float64

    """
        APERR_010V01(gain)

    # Arguments
    - `gain::Float64`: Gain of the antenna [dB]. Must belong to the range [19.7, 24.8]
    """
    function APERR_010V01(gain::Float64)
        new(gain)
    end
end

function description(_::APERR_010V01)
    return "Appendix 30A reference transmitting earth station antenna pattern
    for Regions 1 and 3 (WRC-97)."
end

function information(_::APERR_010V01)
    return "The pattern was used for planning purposes at WRC-97 in the revision of the Appendix 30A Plan of the Radio Regulations at
    14 GHz and 17 GHz in Regions 1 and 3 and specified in Recommendation ITU-R BO.1295-0.
    The feeder-link Plan was based on an antenna diameter of 5 m for the band 17.3-18.1 GHz and 6 m for the band 14.5-14.8
    GHz. The on-axis gain was taken as 57 dBi."
end

function copolar_gain(pattern::APERR_010V01, φ::Float64)
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
    elseif 0.32 <= φ < 0.54
        return pattern.gain - 5.7 - 53.2 * φ^2
    elseif 0.54 <= φ < 36.31
        return pattern.gain - 28 - 25log10(φ)
    else
        return pattern.gain - 67
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

    g = copolar_gain(pattern, φ)
    gx = self.gain - 30

    if gx > g 
        return g
    end

    return gx
end