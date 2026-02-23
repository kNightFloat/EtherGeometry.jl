#=
  @ author: ChenyuBao <chenyu.bao@outlook.com>
  @ date: 2026-02-23 18:30:38
  @ license: MIT
  @ language: Julia
  @ declaration: EtherGeometry.jl includes utils for geometry entities.
  @ description: /
 =#

export Rectangle, Ring, Circle

struct Rectangle{T} <: BasicEtherGeometry{2}
    x1_::SVector{2,T}
    x2_::SVector{2,T}
end

@inline function Rectangle(x1, x2)
    @assert length(x1) == 2 && length(x2) == 2 "Only 2D rectangle is supported."
    @assert x1[1] < x2[1] && x1[2] < x2[2] "Invalid rectangle coordinates."
    T = promote_type(eltype(x1), eltype(x2))
    return Rectangle{T}(SVector{2,T}(x1...), SVector{2,T}(x2...))
end

@inline function inside(g::Rectangle, x::StaticVector{2})
    return all(g.x1_ .<= x .<= g.x2_)
end

@inline function num(g::Rectangle, dr::Real)::Int
    return prod(round.(Int, (g.x2_ - g.x1_) ./ dr))
end

@inline function discrete!(g::Rectangle, dr::Real, points::AbstractMatrix)::Nothing
    n = num(g, dr)
    nx, ny = ceil.(Int, (g.x2_ - g.x1_) ./ dr)
    dx = (g.x2_[1] - g.x1_[1]) / nx
    dy = (g.x2_[2] - g.x1_[2]) / ny
    vol = dx * dy
    @assert size(points, 1) >= n "The points matrix must have enough rows to store the discrete pointss."
    for idx = 1:n
        ix = mod1(idx, nx)
        iy = cld(idx, nx)
        x = g.x1_[1] + (ix - 0.5f0) * dx
        y = g.x1_[2] + (iy - 0.5f0) * dy
        points[idx, 1:2] .= (x, y)
        points[idx, 3] = vol
    end
    return nothing
end

struct Ring{T} <: BasicEtherGeometry{2}
    center_::SVector{2,T}
    inner_radius_::T
    outer_radius_::T
end

@inline function Ring(center, inner_radius, outer_radius)
    @assert length(center) == 2 "Only 2D ring is supported."
    @assert inner_radius > 0 && outer_radius > inner_radius "Invalid ring parameters."
    T = promote_type(eltype(center), eltype(inner_radius), eltype(outer_radius))
    return Ring{T}(SVector{2,T}(center...), T(inner_radius), T(outer_radius))
end

@inline function inside(g::Ring, x::StaticVector{2})
    r = StaticArrays.norm(x .- g.center_)
    return g.inner_radius_ <= r <= g.outer_radius_
end

@inline function num(g::Ring, dr::Real)::Int
    radius_span = g.outer_radius_ - g.inner_radius_
    n_layers = round(Int, radius_span / dr)
    n::Int = 0
    for i = 1:n_layers
        r = g.inner_radius_ + (i - 0.5f0) * dr
        n += round(Int, 2 * pi * r / dr)
    end
    return n
end

@inline function discrete!(g::Ring, dr::Real, points::AbstractMatrix)::Nothing
    n = num(g, dr)
    radius_span = g.outer_radius_ - g.inner_radius_
    n_layers = round(Int, radius_span / dr)
    idx = 1
    for i = 1:n_layers
        r = g.inner_radius_ + (i - 0.5f0) * dr
        circumference = 2 * pi * r
        n_points = round(Int, circumference / dr)
        for j = 1:n_points
            theta = (j - 0.5f0) * (2 * pi / n_points)
            x = g.center_[1] + r * cos(theta)
            y = g.center_[2] + r * sin(theta)
            points[idx, 1:2] .= (x, y)
            points[idx, 3] = (circumference / n_points) * dr
            idx += 1
        end
    end
    return nothing
end

struct Circle{T} <: BasicEtherGeometry{2}
    center_::SVector{2,T}
    radius_::T
end

@inline function Circle(center, radius)
    @assert length(center) == 2 "Only 2D circle is supported."
    @assert radius > 0 "Invalid circle parameters."
    T = promote_type(eltype(center), eltype(radius))
    return Circle{T}(SVector{2,T}(center...), T(radius))
end

@inline function inside(g::Circle, x::StaticVector{2})
    r = StaticArrays.norm(x .- g.center_)
    return r <= g.radius_
end

@inline function num(g::Circle, dr::Real)::Int
    n_layers = round(Int, g.radius_ / dr)
    n::Int = 0
    for i = 1:n_layers
        r = (i - 0.5f0) * dr
        n += round(Int, 2 * pi * r / dr)
    end
    return n
end

@inline function discrete!(g::Circle, dr::Real, points::AbstractMatrix)::Nothing
    n = num(g, dr)
    n_layers = round(Int, g.radius_ / dr)
    idx = 1
    for i = 1:n_layers
        r = (i - 0.5f0) * dr
        circumference = 2 * pi * r
        n_points = round(Int, circumference / dr)
        for j = 1:n_points
            theta = (j - 0.5f0) * (2 * pi / n_points)
            x = g.center_[1] + r * cos(theta)
            y = g.center_[2] + r * sin(theta)
            points[idx, 1:2] .= (x, y)
            points[idx, 3] = (circumference / n_points) * dr
            idx += 1
        end
    end
    return nothing
end
