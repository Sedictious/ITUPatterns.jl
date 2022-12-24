include("./AntennaPattern.jl")

struct APERR_002V01 <: AntennaPattern
    gain::Float64
    coefA::Integer
    d_to_l::Float64
    g1::Float64
    φm::Float64
    φr::Float64

    """
        APERR_002V01(coefA, gain, η)

    # Arguments
    - `coefA::Integer`: Coefficient determining the antenna pattern - see description for more info. Must be either 29 or 32
    - `gain::Float64`: Gain of the antenna [dB]
    - `η::Float64`: Antenna efficiency, must be between 0 and 1. BR software normally only considers an efficiency of 0.7
    """
    function APERR_002V01(gain::Float64, coefA::Integer=29, η::Float64=0.7)
        if (coefA != 29) && (coefA != 32)
            @error "coefA wrong value. Must be 29 or 32."
        end

        if (η != 0.7)
            @warn "The BR software sets the antenna efficiency to 0.7 for technical examination"
        end

        if (η > 1 || η < 0)
            @error "Antenna efficiency must be between 0 and 1"
        end

        d_to_l = sqrt(10^(gain/10)/(η*π^2))
        φb = 10^((coefA + 10)/25)
        g1 = 15log10(d_to_l) - 30 + coefA 
        
        if gain < g1
            @error "gain is less than g1. Square root of negative value."
        end

        φm = 20/d_to_l * sqrt(gain - g1)

        if d_to_l >= 100
            φr = 15.85 * (d_to_l^-0.6)
        else
            φr = 100/d_to_l
        end
        
        if φb < φr
            @error "φb is less than φr"
        end

        new(gain, coefA, d_to_l, g1, φm, φr)
    end
end

function description(_::APERR_002V01)
    return "Appendix 30B reference Earth station pattern with the improved side-lobe for coefficient A = 29."
end

function information(_::APERR_002V01)
    return """
    Appendix 30B Earth station antenna reference pattern applicable for D/lambda > 100. It is used for the determination of
    coordination requirements and interference assessment in FSS Plan.
    Pattern contains an optional improved near side-lobe (coefA=29) which may be used if so desired by administrations,
    particularly in the cases where an aggregate C/I ratio of 26 dB cannot be obtained.
    Pattern is extended for D/lambda < 100 as in Appendix 8.
    Original Plan was based on the antennas having diameter 7 m for the 6/4 GHz band and 3 m for the 13/10-11 GHz band
    and the antenna efficiency of 0.7.
    WRC-03 replaced this Appendix 30B reference antenna pattern for coefA=32 by pattern APEREC015V01 (RR-2003). This
    pattern (APERR_002V01) is still used as improved side-lobe Appendix 30B reference antenna pattern with coefA=29 for
    D/lambda > 100.
    BR software sets antenna efficiency to 0.7 for technical examination.
    """
end

function copolar_gain(pattern::APERR_002V01, φ::Float64)
    if φ < 0 || φ > 2π
        @error "φ must be between 0 and 2π"
    end

    if φ > π
        φ = 2π  - φ
    end

    φ = φ * 180/π

    if pattern.d_to_l >= 100
        if 0 <= φ < pattern.φm
            return pattern.gain - 2.5 * 10^-3 * (pattern.d_to_l * φ)^2
        elseif pattern.φm <= φ < pattern.φr
            return pattern.g1 
        elseif pattern.φr <= φ < 48
            return pattern.coefA - 25*log10(φ)
        else
            return -10
        end
    else
        if 0 <= φ < pattern.φm
            return pattern.gain - 2.5*10^-3 * (pattern.d_to_l * φ)^2
        elseif pattern.φm <= φ < pattern.φr
            return pattern.g1 
        elseif pattern.φr <= φ < 48
            return pattern.coefA + 20 - 10log10(pattern.d_to_l) - 25*log10(φ)
        else
            return 10 - 10log10(pattern.d_to_l)
        end
    end
end

