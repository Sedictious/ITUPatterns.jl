include("./AntennaPattern.jl")

struct APEREC015V01 <: AntennaPattern
    gain::Float64
    d_to_l::Float64
    g1::Float64
    φm::Float64
    φr::Float64
    φb::Float64

    """
        APEREC015V01(gain, η)

    # Arguments
    - `gain::Float64`: Gain of the antenna [dB]
    - `η::Float64`: Antenna efficiency, must be between 0 and 1. BR software normally only considers an efficiency of 0.7
    """
    function APEREC015V01(gain::Float64, η::Float64=0.7)

        if (η != 0.7)
            @warn "The BR software sets the antenna efficiency to 0.7 for technical examination"
        end

        if (η > 1 || η < 0)
            @error "Antenna efficiency must be between 0 and 1"
        end

        d_to_l = sqrt(10^(gain/10)/(η*π^2))
        φb = 10^(42/25)

        if d_to_l < 50
            g1 = 2 + 15log10(d_to_l)
        elseif 50 <= d_to_l < 100
            g1 = -21 + 25log10(d_to_l)
        else
            g1 = -1 + 15log10(d_to_l)
        end
         
        if gain < g1
            @error "gain is less than g1. Square root of negative value."
        end

        φm = 20/d_to_l * sqrt(gain - g1)
       
        if d_to_l >= 100
            φr = 15.85 * d_to_l^-0.6
        else
            φr = 100 / d_to_l
        end

        if φb < φr
            @error "φb is less than φr"
        end

        gain::Float64
        d_to_l::Float64
        g1::Float64
        φm::Float64
        φr::Float64
        φb::Float64
    
        new(gain, d_to_l, g1, φm, φr, φb)
    end
end

function description(_::APEREC015V01)
    return "Appendix 30B reference Earth station antenna pattern.
    Recommendation ITU-R S.580-6 reference Earth station antenna
    pattern."
end

function information(_::APEREC015V01)
    return """
    Appendix 30B Earth station antenna pattern since WRC-03 applicable for D/lambda > 50.
    Pattern is extended for D/lambda < 50 as in Appendix 8.
    Pattern is extended for angles greater than 20 degrees as in Recommendation ITU-R S.465-5.
    Pattern is extended in the main-lobe range as in Appendix 7 to produce continuous curves.
    BR software sets antenna efficiency to 0.7 for technical examination
    """
end

function copolar_gain(pattern::APEREC015V01, φ::Float64)
    if φ < 0 || φ > 2π
        @error "φ must be between 0 and 2π"
    end

    if φ > π
        φ = 2π  - φ
    end

    φ = φ * 180/π

    if pattern.d_to_l >= 50
        if 0 <= φ < pattern.φm
            return pattern.gain - 2.5 * 10^-3 * (pattern.d_to_l * φ)^2
        elseif pattern.φm <= φ < pattern.φr
            return pattern.g1 
        elseif pattern.φr <= φ < 19.95
            return 29 - 25*log10(φ)
        elseif 19.95 <= φ < pattern.φb
            return min(-3.5, 32 - 25log10(φ))
        else
            return -10
        end
    else
        if 0 <= φ < pattern.φm
            return pattern.gain - 2.5*10^-3 * (pattern.d_to_l * φ)^2
        elseif pattern.φm <= φ < pattern.φr
            return pattern.g1 
        elseif pattern.φr <= φ < pattern.φb
            return 52 - 10log10(pattern.d_to_l) - 25*log10(φ)
        else
            return 10 - 10log10(pattern.d_to_l)
        end
    end
end

