export Cylinder

immutable Cylinder{N,D} <: Object{N}
    c::Point{N,Float64} # Cylinder center
    a::Vec{N,Float64}   # axis unit vector
    r::Float64          # radius
    h2::Float64         # height * 0.5
    data::D             # auxiliary data
end
Cylinder{D}(c, r::Real, a, h::Real=Inf, data::D=nothing) =
    Cylinder{length(c),D}(c, normalize(a), r, h * 0.5, data)

function Base.in(x::Point, s::Cylinder)
    d = x - s.c
    p = dot(d, s.a)
    abs(p) > s.h2 && return false
    return sumabs2(d - p*s.a) ≤ s.r^2
end

function normal(x::Point, s::Cylinder)
    d = x - s.c
    p = dot(d, s.a)
    p > s.h2 && return s.a
    p < -s.h2 && return -s.a
    return normalize(d - p*s.a)
end

const rotate2 = @fsa [0.0 1.0; -1.0 0.0] # 2x2 90° rotation matrix
function endcircles(s::Cylinder{2})
    b = rotate2 * s.a
    axes = [s.a[1] b[1]; s.a[2] b[2]]
    return(Ellipsoid(s.c + s.a*s.h2, Vec(0.0, s.r), axes),
           Ellipsoid(s.c - s.a*s.h2, Vec(0.0, s.r), axes))
end

function endcircles(s::Cylinder{3})
    u = abs(s.a[3]) < abs(s.a[1]) ? Vec(0,0,1) : Vec(1,0,0)
    b1 = cross(s.a, u)
    b2 = cross(b1, s.a)
    axes = [s.a[1] b1[1] b2[1]; s.a[2] b1[2] b2[2]; s.a[3] b1[3] b2[3]]
    return(Ellipsoid(s.c + s.a*s.h2, Vec(0.0, s.r, s.r), axes),
           Ellipsoid(s.c - s.a*s.h2, Vec(0.0, s.r, s.r), axes))
end

function bounds(s::Cylinder)
    e1, e2 = endcircles(s)
    l1, u1 = bounds(e1)
    l2, u2 = bounds(e2)
    return min(l1,l2), max(u1,u2)
end
