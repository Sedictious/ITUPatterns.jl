include("./AntennaPattern.jl")

struct APEREC023V01 <: AntennaPattern
    gain::Float64
    d_to_l_eq::Float64
    d_to_l_theta::Float64
    k::Float64
    φr::Float64
    φ1::Float64
    φmin::Float64
    g1::Float64
    φm::Float64
    φb::Float64
    η::Float64


    """
        APEREC023V01(gain, dgso, η)

    # Arguments
    - `gain::Float64`: Gain of the antenna [dB]
    - `dgso::Float64`: Antenna diameter of the geostationary satellite [m]
    - `λ::Float64`: Wavelength [m]
    - `η::Float64`: Antenna efficiency, must be between 0 and 1. BR software normally only considers an efficiency of 0.7
    """
    function APEREC023V01(gain::Float64, gso::Float64, η::Float64=0.7)

        if (η != 0.7)
            @warn "The BR software sets the antenna efficiency to 0.7 for technical examination"
        end

        if (η > 1 || η < 0)
            @error "Antenna efficiency must be between 0 and 1"
        end

    end
end

function description(_::APEREC023V01)
    return "Recommendation ITU-R S.1855 alternative reference radiation
    pattern for TRANSMITTING GSO earth station antennas for use in
    coordination and/or interference assessment in the frequency
    range from 2 to 31 GHz."
end

function information(_::APEREC023V01)
    return """
    Note 7 of the recommendation is not applied.
    The pattern requires input parameter dgso.
    BR software sets antenna efficiency to 0.7 for technical examination.
    """
end

