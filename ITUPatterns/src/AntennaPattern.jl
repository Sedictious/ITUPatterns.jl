abstract type AntennaPattern end

@enum AntennaPatternPolarization begin
    COPOLAR = 0 # Reference antenna is considered to have similar polarization
    CROSSPOLAR = 1 # Reference antenna has different polarization
end

@recipe function plot_aperr_001v02(pattern::T, φ0::Float64,  φn::Float64, polarization::AntennaPatternPolarization, number_of_points=100) where {T<:AntennaPattern}
    proj := :polar
    legend := false
    linewidth := 2

    θ = range(φ0, stop = φn, length = number_of_points)
    θ = map(x -> mod(x, 2π), θ)
    println(θ)
    r = radiation_pattern(pattern, polarization, φ0, φn, number_of_points)
    ylims := (min(2minimum(r), 0),maximum(r))

    θ, r  
end

function gain(pattern::T, φ::Float64, polarization::AntennaPatternPolarization = COPOLAR::AntennaPatternPolarization) where {T<:AntennaPattern}
    if polarization == COPOLAR::AntennaPatternPolarization
        copolar_gain(pattern, φ)
    else
        crosspolar_gain(pattern, φ)
    end
end

function radiation_pattern(pattern::T, polarization::AntennaPatternPolarization = COPOLAR::AntennaPatternPolarization, φ0::Float64 = 0.0,  φn::Float64 = 2π, number_of_points = 100) where {T<:AntennaPattern}    
    angles = LinRange(φ0, φn, number_of_points)
    angles = map(x -> mod(x, 2π), angles)
    return gain.([pattern], angles, [polarization])

end


function copolar_gain(pattern::AntennaPattern, φ::Float64)
    @error "Co-polar gain not defined"
end

function crosspolar_gain(pattern::AntennaPattern, φ::Float64)
    @error "Cross-polar gain not defined"
end