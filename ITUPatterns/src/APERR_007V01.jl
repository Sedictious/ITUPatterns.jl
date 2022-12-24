include("./AntennaPattern.jl")

struct APERR_007V01 <: AntennaPattern
    gain::Float64
    d_to_l::Float64
    φm::Float64
    φb::Float64
    g1::Float64
    φr::Float64
    s::Float64
    φ0::Float64
    φ1::Float64
    φ2::Float64

    """
        APERR_007V01(gain)

    # Arguments
    - `gain::Float64`: Gain of the antenna [dB]
    - `antenna_diameter::Float64`: Diameter of antenna [m]
    """
    function APERR_007V01(gain::Float64, antenna_diameter::Float64)
        λ = 0.02477624
        φr = 95 * λ/antenna_diameter
        g1 = 29 - 25log10(φr)
        if gain < g1
            @error "gain is less than g1. Square root of negative value."
        end
        φm = 20*λ/antenna_diameter * sqrt(gain - g1)

        if φr < φm
            @error "φr is less than φm"
        end

        φb = 10^(34/25)

        φ0 = 2λ/antenna_diameter * sqrt(3/0.0025)
        φ1 = φ0/2*sqrt(10.1875)
        φ2 = 10^(26/25)
        s = 38 - 25log10(φ1) - gain

        if 0 < s
            @error "0 is less than S"
        end

        if φ2 < φ1
            @error "φ2 is less than φ1"
        end

        new(gain, antenna_diameter/λ, φm, φb, g1, φr, s, φ0, φ1, φ2)
    end
end

function description(_::APERR_007V01)
    return "Appendix 30 reference receiving earth station antenna pattern for
    Regions 1 and 3 (WRC-97). Frequency is fixed to 12.1 GHz."
end

function information(_::APERR_007V01)
    return """
    Used at WRC-97 for revising the Regions 1 and 3 BSS Plan.
    The Plan was based on a 60 cm antenna given in Recommendation ITU-R BO.1213. Antenna maximum gain was 35.5 dBi
    and the reference frequency was 12.1 GHz. The minimum antenna diameter was such that the half-power beamwidth was
    2.86 degrees.
    The pattern requires input parameter antenna diameter.
    """
end

function copolar_gain(pattern::APERR_007V01, φ::Float64)
    if φ < 0 || φ > 2π
        @error "φ must be between 0 and 2π"
    end

    if φ > π
        φ = 2π  - φ
    end

    φ = φ * 180/π
    
    if 0 <= φ < pattern.φm
            return pattern.gain - 2.5*10^3*(pattern.d_to_l*φ)^2
    elseif pattern.φm <= φ < pattern.φr
        return pattern.g1 
    elseif pattern.φr <= φ < pattern.φb
        return 29 - 25*log10(φ)
    elseif pattern.φb <= φ < 70
        return -5
    else
        return 0
    end
end

function crosspolar_gain(pattern::APERR_007V01, φ::Float64)
    if φ < 0 || φ > 2π
        @error "φ must be between 0 and 2π"
    end

    if φ > π
        φ = 2π  - φ
    end

    φ = φ * 180/π
    φ0 = pattern.φ0
    φ1 = pattern.φ1
    φ2 = pattern.φ2

    if 0 <= φ < 0.25*φ0
        return pattern.gain - 25
    elseif 0.25*φ0 <= φ < 0.44*φ0
        return pattern.gain - 25 - 8*(φ-0.25φ0)/(0.19φ0)
    elseif 0.44*φ0 <= φ < φ0
        return pattern.gain - 17
    elseif φ0 <= φ < φ1
        println(s*abs((φ - φ0)/(φ1 - φ0)))
        return pattern.gain - 17 + pattern.s*abs((φ - φ0)/(φ1 - φ0))
    elseif φ1 <= φ < φ2
        return -5
    else
        return 0
    end
end
