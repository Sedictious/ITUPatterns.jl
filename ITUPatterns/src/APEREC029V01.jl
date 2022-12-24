include("./AntennaPattern.jl")

struct APEREC029V01 <: AntennaPattern
    gain::Float64
    φ1::Float64
    φ2::Float64

    """
        APEREC029V01(gain, beamwidth)

    # Arguments
    - `gain::Float64`: Gain of the antenna [dB]
    - `beamwidth:Float64`: Beamwidth [deg]
    """
    function APEREC029V01(gain::Float64, beamwidth::Float64)

        φ1 = beamwidth * 17/3
        φ2 = 10^((49 - gain)/25)
        println(φ2)
        if φ2 < φ1
            @error "φ2 is less than φ1"
        end

        if 48 < φ2
            @error "φ2 must be more than 48"
        end

        new(gain, φ1, φ2)
    end
end

function description(_::APEREC029V01)
    return "Recommendation ITU-R SA.509-3, section 1.1 Space research earth
    station and radio astronomy reference antenna radiation pattern
    for use in interference calculations, including coordination
    procedures, for frequencies less than 30 GHz."
end

function information(_::APEREC029V01)
    return """
    Recommendation ITU-R SA.509-3, section 1.1: Space research earth station and radio astronomy reference antenna
    radiation pattern for use in interference calculations, including coordination procedures, for frequencies less than 30 GHz.
    The pattern requires input parameter beamwidth.    """
end

function copolar_gain(pattern::APEREC029V01, φ::Float64)
    if φ < 0 || φ > 2π
        @error "φ must be between 0 and 2π"
    end

    if φ > π
        φ = 2π  - φ
    end

    φ = φ * 180/π

    if 0 <= φ < pattern.φ1
        return pattern.gain
    elseif pattern.φ1 <= φ < pattern.φ2
        return pattern.g1 - 17
    elseif pattern.φ2 <= φ < 48
        return 32 - 25*log10(φ)
    elseif 80 <= φ < 120
        return -5
    else
        return -10
    end
end

