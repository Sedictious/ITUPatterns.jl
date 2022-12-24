include("./AntennaPattern.jl")

struct APSREC412V01 <: AntennaPattern
    gain::Float64
    η::Float64
    d_to_l::Float64
    φm::Float64

    """
        APSREC412V01(gain, η)

    # Arguments
    - `gain::Float64`: Gain of the antenna [dB]
    - `η::Float64`: Antenna efficiency, must be between 0 and 1. BR software normally only considers an efficiency of 0.6
    """
    function APSREC412V01(gain::Float64, η::Float64 = 0.6)

        if (η != 0.6)
            @warn "The BR software sets the antenna efficiency to 0.6 for technical examination"
        end

        d_to_l = sqrt(10^(gain/10)/(η * π^2))
        φm = 22/d_to_l * sqrt(5.5 + 5 * log10(d_to_l * η^2))

        new(gain, η, d_to_l, φm)
    end
end

function description(_::APSREC412V01)
    return "Recommendation ITU-R RS.1813-1 space station antenna pattern
    for satellites operating in EESS (passive) between 1.4 and 100 GHz.
    Recommends 1."
end

function information(_::APSREC412V01)
    return ""
end

function copolar_gain(pattern::APSREC412V01, φ::Float64)
    if φ < 0 || φ > 2π
        @error "φ must be between 0 and 2π"
    end

    if φ > π
        φ = 2π  - φ
    end

    φ = φ * 180/π
    
    if 0 < φ < pattern.φm
        return pattern.gain - 7.91 * 10^-6 * φ - 2 * 10^-3 * φ^2 + 3.35*10^-8 * φ^3 +
        4.08*10^-8 * φ^4
    else
        return -16
    end
end

