include("./AntennaPattern.jl")

struct APERR_012V01 <: AntennaPattern
    gain::Float64
    d_to_l::Float64
    g1::Float64
    φm::Float64
    φr::Float64

    """
        APERR_012V01(gain)

    # Arguments
    - `gain::Float64`: Gain of the antenna [dB]
    """
    function APERR_012V01(gain::Float64)

        d_to_l = 10^((gain - 7.7)/20)
        if d_to_l < 35
            @error "d/lambda is less than 35."
        elseif 35 <= d_to_l < 100
            g1 = -21 + 25log10(d_to_l)
            φr = 100/d_to_l
        elseif 100 <= d_to_l
            g1 = -1 + 15log10(d_to_l)
            φr = 15.85 * d_to_l^-0.6
        end

        φm = 20/d_to_l * sqrt(gain - g1)


        new(gain, d_to_l, g1, φm, φr)
    end
end

function description(_::APERR_012V01)
    return "Appendix 7 Earth station antenna pattern for the determination of
    the coordination area around an earth station in frequency bands
    between 100 MHz and 105 GHz."
end

function information(_::APERR_012V01)
    return """
    Orinally specified in Recommendation ITU-R SM.1448-0. Also specified in Recommendation ITU-R IS.847-1 (but without low
    limit on D/lambda). Pattern is applicable only for D/lambda > 35.
    """
end

function copolar_gain(pattern::APERR_012V01, φ::Float64)
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
    elseif pattern.φr <= φ < 36
        return 29 - 25*log10(φ)
    else
        return -10
    end
end

