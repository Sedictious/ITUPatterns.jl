include("./AntennaPattern.jl")

struct APERR_001V01 <: AntennaPattern
    gain::Float64
    #diameter::Quantity{Float64,𝐓^-1,Unitful.FreeUnits{(Hz,),𝐓^-1,nothing}}
    #frequency::Quantity{Float64,𝐓^-1,Unitful.FreeUnits{(Hz,),𝐓^-1,nothing}}
    d_to_l::Float64
    g1::Float64
    φm::Float64
    φr::Float64

    """
    APERR_001V01(gain)

    # Arguments
    - `gain::Float64`: Gain of the antenna [dB]. Must be at least 9.3 dB
    """
    function APERR_001V01(gain::Float64)
        if gain < 9.3
            @warn "gain has to be greater than 9.3 dB"
        end

        d_to_l = 10^((gain - 7.7)/20)
        g1 = 2 + 15log10(d_to_l)
        φm = 20/d_to_l * sqrt(gain - g1)
        if d_to_l >= 100
            φr = 15.85 * (d_to_l^-0.6)
        else
            φr = 100/d_to_l
        end

        if 48 < φr
            @warn "φb is less than φr."
            φr = 48.0
        end

        new(gain, d_to_l, g1, φm, φr)
    end
end

function description(_::APERR_001V01)
    return "Appendix 8 Earth station antenna pattern for GSO networks. Only
    for maximum antenna gain greater than 9.3 dB."
end

function information(_::APERR_001V01)
    return "The pattern is used for the determination of coordination requirements between GSO networks sharing the same
    frequency band for non-planed services."
end

function copolar_gain(pattern::APERR_001V01, φ::Float64)
    if φ < 0 || φ > 2π
        @error "φ must be between 0 and 2π"
    end

    if φ > π
        φ = 2π  - φ
    end

    φ = φ * 180/π

    if pattern.d_to_l >= 100
        if 0 <= φ < pattern.φm
            return pattern.gain - 2.5*10^-3 * (pattern.d_to_l * φ)^2
        elseif pattern.φm <= φ < pattern.φr
            return pattern.g1 
        elseif pattern.φr <= φ < 48
            return 32 - 25*log10(φ)
        else
            return -10
        end
    else
        if 0 <= φ < pattern.φm
            return pattern.gain - 2.5*10^-3 * (pattern.d_to_l * φ)^2
        elseif pattern.φm <= φ < pattern.φr
            return pattern.g1 
        elseif pattern.φr <= φ < 48
            return 52 - 10log10(pattern.d_to_l) - 25*log10(φ)
        else
            return 10 - 10log10(pattern.d_to_l)
        end
    end
end

