using SimpleGraphs, ProgressMeter, SemiIsomorphism

struct Trees
    n::Int
end

function Base.iterate(T::Trees, state = 0)
    N = T.n
    NN = Int128(N)^(N - 2)
    if state == NN
        return nothing
    end

    code = Int.(digits(state, base = N, pad = N - 2) .+ 1)
    G = prufer_restore(code)
    name(G, "Tree")
    return (G, state + 1)
end

Base.length(T::Trees) = Int128(T.n)^(T.n - 2)

"""
    distinct_trees(n)
Returns a list of all trees on `n` vertices that are pairwise non-isomorphic.

**WARNINGS**
+ This can be used up to `n = 9`. Beyond that it's very slows.
+ Filtering out isomorphic duplicates is done by a heuristic. Tested up to `n = 9` and it works.

See https://oeis.org/A000055
"""
function distinct_trees(n::Int)
    result = Set{SimpleGraph{Int}}()
    seen = Set{UInt64}()
    P = Progress(length(Trees(n)))
    for T ∈ Trees(n)
        next!(P)
        uh = uhash(T)
        if uh ∈ seen
            continue
        end
        push!(seen, uh)
        push!(result, T)
    end
    return collect(result)
end


function find_semi_iso_pair(list::Vector{SimpleGraph{T}}) where T
    nG = length(list)
    for j=1:nG-1
        for k=j+1:nG 
            if is_semi_iso(TT[j], TT[k])
                return TT[j], TT[k]
            end
        end
    end
    println("No pair found")
    nothing
end