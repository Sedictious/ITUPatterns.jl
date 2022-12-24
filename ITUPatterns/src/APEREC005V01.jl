include("./AntennaPattern.jl")

struct APEREC005V01 <: AntennaPattern
    gain::Float64
    d_to_l::Float64
    g1::Float64
    φm::Float64
    φr::Float64
    φb::Float64

    """
        APEREC005V01(gain)

    # Arguments
    - `gain::Float64`: Gain of the antenna [dB]. Must belong to the range [19.7, 24.8]
    """
    function APEREC005V01(gain::Float64)
        if 19.7 > gain || gain > 24.8
            @warn "gain is out of limits [19.7:24.8]. See ranges for Diameter and Frequency in REC-694."
        end

        d_to_l = 10^((ustrip(gain) - 7.7)/20)
        g1 = 2 + 15log10(d_to_l)
        φm = 20/d_to_l * sqrt(gain - g1)
        φr = 100/d_to_l
        φb = 120 * (1/d_to_l)^0.4
        if φb < φr
            @warn "φb is less than φr."
            φr = φb
        end

        if φr < φm
            @warn "φr is less than φm."
            φr = φm
        end

        new(gain, d_to_l, g1, φm, φr, φb)
    end
end

function description(pattern::APEREC005V01)
    return "Recommendation ITU-R M.694-0 reference Earth station antenna 
    pattern for ship earth station antennas having circular paraboloidal 
    with diameters between 0.8 m and 1.3 m and with an
    operating frequency range of about 1500 to 1650 MHz."
end

function information(pattern::APEREC005V01)
    return "Used for coordination studies and the assessment of interference between ship earth stations and terrestrial stations, and
    between ship earth stations and the space stations of different satellite systems sharing the same frequency bands."
end

function copolar_gain(pattern::APEREC005V01, φ::Float64)
    if φ < 0 || φ > 2π
        @error "φ must be between 0 and 2π"
    end

    if φ > π
        φ = 2π  - φ
    end

    φ = φ * 180/π

    if 0 <= φ < pattern.φm
        return pattern.gain - 2.5*10^-3 * (pattern.d_to_l * φ)^2
    elseif pattern.φm <= φ < pattern.φr
        return pattern.g1 
    elseif pattern.φr <= φ < pattern.φb
        return 52 - 10log10(pattern.d_to_l) - 25*log10(φ)
    else
        return 0
    end
end
