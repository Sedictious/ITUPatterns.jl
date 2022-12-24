include("./AntennaPattern.jl")

struct APEREC022V01 <: AntennaPattern
    gain::Float64
    d_to_l::Float64
    g1::Float64
    φb::Float64
    φm::Float64
    φr::Float64
    φ0::Float64
    φ1::Float64
    φ2::Float64
    s::Float64


    """
        APEREC022V01(gain, η)

    # Arguments
    - `gain::Float64`: Gain of the antenna [dB]
    - `η::Float64`: Antenna efficiency, must be between 0 and 1. BR software normally only considers an efficiency of 0.7
    """
    function APEREC022V01(gain::Float64, η::Float64=0.7)

        if (η != 0.7)
            @warn "The BR software sets the antenna efficiency to 0.7 for technical examination"
        end

        if (η > 1 || η < 0)
            @error "Antenna efficiency must be between 0 and 1"
        end

        d_to_l = sqrt(10^(gain/10)/(η*π^2))

        if (d_to_l < 32)
            @error "D/lambda is less than 32"
        end

        φb = 10^(34/25)
        φr = 95 / d_to_l
        g1 = 29 - 25 * log10(φr)
        
        if gain < g1
            @error "Gain is less than g1. Square root of negative value."
        end

        φm = 20 / d_to_l * sqrt(gain - g1)

        φ0 = 2 / d_to_l * sqrt(3 / 0.0025)
        φ1 = φ0 / 2 * sqrt(10.1875)
        φ2 = 10^(26/25)
        s = 21 - 25 * log10(φ1) - (gain - 17)

        if s >= 0
            @error "S must be less than 0"
        end

        new(gain, d_to_l, g1, φb, φm, φr, φ0, φ1, φ2, s)
    end
end

function description(_::APEREC022V01)
    return "Recommendation ITU-R BO.1900 reference receiving earth station
    antenna pattern for BSS in the band 21.4-22 GHz in Regions 1 and
    3."
end

function information(_::APEREC022V01)
    return """
    Pattern is apllied only for D/lambda > 32.
    BR software sets antenna efficiency to 0.7 for technical examination
    """
end

function copolar_gain(pattern::APEREC022V01, φ::Float64)
    if φ < 0 || φ > 2π
        @error "φ must be between 0 and 2π"
    end

    if φ > π
        φ = 2π  - φ
    end

    φ = φ * 180/π

    if 0 <= φ < pattern.φm
        return pattern.gain - 2.5 * 1e-3 * (pattern.d_to_l * φ)^2
    elseif pattern.φm <= φ < pattern.φr
        return pattern.g1
    elseif pattern.φr <= φ < pattern.φb
        return 29 - 25 * log10(φ)
    elseif pattern.φb <= φ < 70
        return -5
    else
        return 0
    end
end

function crosspolar_gain(pattern::APEREC022V01, φ::Float64)
    if φ < 0 || φ > 2π
        @error "φ must be between 0 and 2π"
    end

    if φ > π
        φ = 2π  - φ
    end

    φ = φ * 180/π

    if 0 <= φ < pattern.φ0
        gx = pattern.gain - 17
    elseif pattern.φ0 <= φ < pattern.φ1
        gx = pattern.gain - 17 + pattern.s * abs((φ - pattern.φ0)/(pattern.φ1 - pattern.φ0))
    elseif pattern.φ1 <= φ < pattern.φ2
        gx = 21 - 25 * log10(φ)
    elseif pattern.φ2 <= φ < 70
        gx = -5
    else
        return 0
    end

    return gx
end