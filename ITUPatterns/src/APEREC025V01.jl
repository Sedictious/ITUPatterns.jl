
struct APEREC025V01 <: AntennaPattern
    gain::Float64
    η::Float64
    d_to_l::Float64
    g1::Float64
    φ1::Float64
    φm::Float64
    φmin::Float64
    φb::Float64
    φr::Float64

    """
        APEREC025V01(gain, η)

    # Arguments
    - `gain::Float64`: Gain of the antenna [dB]. 
    - `η::Float64`: Antenna efficiency, must be between 0 and 1. BR software normally only considers an efficiency of 0.7
    """
    function APEREC025V01(gain::Float64, η::Float64=0.7)
        d_to_l = sqrt(10^(gain/10)/(η * π^2))
        φr = 15.85 * (d_to_l)^(-0.6) 
        g1 = 32 - 25 * log10(φr)
        φ1 = 0.9 * 114 * (d_to_l)^(-1.09)
        φm = 20/d_to_l * sqrt(gain - g1)
        φmin = d_to_l >= 50 ? max(1, 100 / d_to_l) : max(2, 114 * d_to_l^(-1.09))
        φb = 10^(42/25)
 
        new(gain, η, d_to_l, g1, φ1, φm, φmin, φb, φr)
    end
end

function description(_::APEREC025V01)
    return "Recommendation ITU-R S.465-6 TRANSMITTING reference Earth
    station antenna pattern for earth stations in FSS in the frequency
    range from 2 to 31 GHz coordinated after 1993."
end

function information(_::APEREC025V01)
    return "For use in coordination and interference assessment.
    Note 5 of the recommendation is not applied.
    Pattern is extended in the main-lobe range as described in Rep. ITU-R S.2196.
    BR software sets antenna efficiency to 0.7 for technical examination."
end

function copolar_gain(pattern::APEREC025V01, φ::Float64)
    if φ < 0 || φ > 2π
        @error "φ must be between 0 and 2π"
    end

    if φ > π
        φ = 2π  - φ
    end

    φ = φ * 180/π

    if pattern.d_to_l <= 54.5
        if 0 <= φ < pattern.φ1
            return pattern.gain - 2.5 * 1e-3 * (pattern.d_to_l * φ)^2
        elseif pattern.φ1 <= φ < pattern.φmin
            return max(pattern.gain - 2.5e-3 * (pattern.d_to_l * φ)^2, 32 - 25 * log10(φ))
        else
            return max(32 - 25 * log10(φ), -10)
        end
    else
        if 0 <= φ < pattern.φm
            return pattern.gain - 2.5 * 1e-3 * (pattern.d_to_l * φ)^2
        elseif pattern.φm <= φ < pattern.φr
            return pattern.g1
        else
            return max(32 - 25 * log10(φ), -10)
        end
    end
end

