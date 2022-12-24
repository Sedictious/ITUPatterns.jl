include("./AntennaPattern.jl")

struct APEEST256V01 <: AntennaPattern
    gain::Float64
end

function description(_::APEEST256V01)
    return "Earth station antenna pattern submitted by EST for network
    ESTCUBE-2 for parabolic antenna in 2.4 GHz downlink. Gmax = 34
    dB."
end

function information(_::APEEST256V01)
    return ""
end

function copolar_gain(pattern::APEEST256V01, φ::Float64)
    if φ < 0 || φ > 2π
        @error "φ must be between 0 and 2π"
    end

    if φ > π
        φ = 2π  - φ
    end

    φ = φ * 180/π
    
    return pattern.gain - 2.989φ + 0.1143 * φ^2 - 2.005*10^-3 * φ^3 +
    1.733*10^-5 * φ^4 - 7.357*10^-8 * φ^5 + 1.234 * 10^-10 * φ^6
end

