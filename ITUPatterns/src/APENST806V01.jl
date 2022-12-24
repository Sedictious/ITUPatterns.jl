include("./AntennaPattern.jl")

struct APENST806V01 <: AntennaPattern
    gain::Float64
    d_to_l::Float64
    g1::Float64
    φr::Float64
    φb::Float64
    φm::Float64
    coefA::Float64

    """
        APENST806V01(gain, η)

    # Arguments
    - `gain::Float64`: Gain of the antenna [dB]
    - `coefA::Float64`: Coefficient for determining the sidelobes of the pattern which are given by CoefA - 25log(φ)
    - `η::Float64`: Antenna efficiency, must be between 0 and 1. BR software normally only considers an efficiency of 0.7
    """
    function APENST806V01(gain::Float64, coefA::Float64, η::Float64=0.7)

        if (η != 0.7)
            @warn "The BR software sets the antenna efficiency to 0.7 for technical examination"
        end

        if (η > 1 || η < 0)
            @error "Antenna efficiency must be between 0 and 1"
        end

        if (coefA > 47 || coefA < 18)
            @error "CoefA is out of limits"
        end

        d_to_l = sqrt(10^(gain/10)/(η*π^2))
        φb = 10^((coefA + 10)/25)
        
        if d_to_l > 100
            g1 = coefA
            φr = 1
        elseif d_to_l <= 100
            g1 = coefA - 50 + 25log10(d_to_l)
            φr = 100/d_to_l
        end
        
        if gain < g1
            @error "gain is less than g1. Square root of negative value."
        end

        if φb < φr
            @error "φb is less than φr"
        end

        φm = 20/d_to_l * sqrt(gain - g1)

        if φr < φm
            @error "φr is less than φm"
        end

        new(gain, d_to_l, g1, φr, φb, φm, coefA)
    end
end

function description(_::APENST806V01)
    return "Non-standard generic earth station antenna pattern similar to that
    in Recommendation ITU-R S.465-5, where the side-lobe radiation is
    represented by the expression CoefA - 25 log(phi)."
end

function information(_::APENST806V01)
    return """
    Pattern is extended in the main-lobe range similar to Appendix 8.
    BR software sets antenna efficiency to 0.7 for technical examination.
    """
end

function copolar_gain(pattern::APENST806V01, φ::Float64)
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
    else
        return max(pattern.coefA - 25log10(φ), -10)
    end
end

