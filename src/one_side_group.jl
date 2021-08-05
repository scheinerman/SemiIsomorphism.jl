"""
    one_side_group(G::SimpleGraph)

Let `A` be the adjacency matrix of `G`.
Return the `Set` of `Permutation`s `p` such that `A[p,:]` is an adjacency matrix.
"""
function one_side_group(G::SimpleGraph)::Set{Permutation}
    result = Set{Permutation}()
    n = NV(G)
    A = adjacency(G)
    allow = make_allow(A)
    perms = RPG(n, allow)
    @info "There are $(length(perms)) permutations to consider"
    PM = Progress(length(perms))

    for p in perms 
        next!(PM)
        B = A[p,:]
        if is_adjacency(B)
            push!(result,Permutation(p))
        end
    end

    return result
end

export one_side_group