#=
  @ author: ChenyuBao <chenyu.bao@outlook.com>
  @ date: 2026-02-23 14:55:04
  @ license: MIT
  @ language: Julia
  @ declaration: EtherGeometry.jl includes utils for geometry entities.
  @ description: /
 =#

module EtherGeometry

using StaticArrays

export AbstractEtherGeometry, inside, dim, discrete, discrete!, num

abstract type AbstractEtherGeometry{N} end

@inline dim(::AbstractEtherGeometry{N}) where {N} = N
@inline inside(::AbstractEtherGeometry, x) = true
@inline num(::AbstractEtherGeometry, dr::Real)::Int = 1
@inline discrete!(::AbstractEtherGeometry, dr::Real, points::AbstractMatrix) = nothing

@inline function discrete(g::AbstractEtherGeometry{N}, dr::Real) where {N}
    T = typeof(dr)
    points = zeros(T, num(g, dr), N + 1)
    discrete!(g, dr, points)
    return points
end

abstract type BasicEtherGeometry{N} <: AbstractEtherGeometry{N} end
include("Basic2D.jl")
include("Basic3D.jl")

end # module EtherGeometry
