# Restricted Permutation Generator

using Combinatorics, ShowSet



"""
    RPG(n::Int, allow::Dict{Int,Set{Int}})

Create a list of all length-`n` repetition-free lists `p` in which `p[k]`
must be an element of `allow[k]`.
"""
function RPG(
    n::Int,
    allow::Dict{Int,Set{Int}},
    forbid::BitSet = BitSet(),
)::Vector{Vector{Int}}
    @assert n > 0 "`n` must be positive, got $n"

    result = Vector{Vector{Int}}()

    if n == 1
        for k ∈ allow[1]
            if k ∉ forbid
                p = [k]
                push!(result, p)
            end
        end
        return result
    end

    for last ∈ allow[n]
        if last ∉ forbid
            push!(forbid, last)

            sub_result = RPG(n - 1, allow, forbid)

            for p in sub_result
                push!(p, last)
                push!(result, p)
            end
            pop!(forbid, last)
        end
    end
    return result

end




"""
    make_allow(A::Matrix)

Given a matrix, create an "allow" dictionary where the 
allowed values for key `k` are the indices of the zeros 
in row `k`.
"""
function make_allow(A::Matrix)
    r, c = size(A)
    allow = Dict{Int,Set{Int}}()

    for i = 1:r
        row = A[i, :]
        allow[i] = Set(findall(t -> t == 0, row))
    end
    return allow

end
