include("./AntennaPattern.jl")

struct APEREC013V01 <: AntennaPattern
    gain::Float64
    η::Float64
    d_to_l::Float64
    g1::Float64
    φr::Float64
    φb::Float64
    φm::Float64

    """
        APEREC013V01(gain, η)

    # Arguments
    - `gain::Float64`: Gain of the antenna [dB]
    - `η::Float64`: Antenna efficiency, must be between 0 and 1. BR software normally only considers an efficiency of 0.7
    """
    function APEREC013V01(gain::Float64, η::Float64=0.7)

        if (η != 0.7)
            @warn "The BR software sets the antenna efficiency to 0.7 for technical examination"
        end

        if (η > 1 || η < 0)
            @error "Antenna efficiency must be between 0 and 1"
        end

        d_to_l = sqrt(10^(gain/10)/(η*π^2))
        φb = 10^(42/25)
        
        if d_to_l > 100
            g1 = 32
            φr = 1
        elseif d_to_l <= 100
            g1 = -18 + 25log10(d_to_l)
            φr = 100/d_to_l
        end
        
        if gain < g1
            @error "gain is less than g1. Square root of negative value."
        end

        if φb < φr
            @error "φb is less than φr"
        end

        φm = 20/d_to_l * sqrt(gain - g1)

        new(gain, η, d_to_l, g1, φr, φb, φm)
    end
end

function description(_::APEREC013V01)
    return "Recommendation ITU-R S.465-5 reference Earth station antenna
    pattern for earth stations coordinated after 1993 in the frequency
    range from 2 to about 30 GHz."
end

function information(_::APEREC013V01)
    return """
    Earth station antenna pattern for use in coordination and interference assessment.
    Pattern is extended in the main-lobe range similar to Appendix 8 and Appendix 7 to produce continuous curves.
    BR software sets antenna efficiency to 0.7 for technical examination.
    """
end

function copolar_gain(pattern::APEREC013V01, φ::Float64)
    if φ < 0 || φ > 2π
        @error "φ must be between 0 and 2π"
    end

    if φ > π
        φ = 2π  - φ
    end

    φ = φ * 180/π

    if 0 <= φ < pattern.φm
        return pattern.gain - 2.5 * 10^-3 * (pattern.d_to_l * φ)^2
    elseif pattern.φm <= φ < pattern.φr
        return pattern.g1 
    elseif pattern.φr <= φ < pattern.φb
        return 32 - 25*log10(φ)
    else
        return -10
    end
end

