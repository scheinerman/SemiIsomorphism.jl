include("semi_iso.jl")
using LinearAlgebraX


"""
    cycle_pair(n::Int)

Find the semi-isomorphism between 2C_n and C_{2n}.
"""
function cycle_pair(n::Int)
    A = adjacency(Cycle(n))
    A = dcat(A,A)
    d = make_allow(A)
    perms = RPG(2n,d)

    np = length(perms)
    @info "There are $np row permutations to consider"
    PM = Progress(np)

    good_p = Permutation(2n).data
    for p in perms 
        B = A[:,p]
        if is_adjacency(B)
            H = SimpleGraph(B)
            if is_connected(H)
                good_p = p
                break
            end
        end
    end
    if good_p == Permutation(2n).data
        println("No semi-isormorphism found")
        return 
    end
    println("Adjacency matrix for 2C_$n")
    display(A)
    println()
    println("Row permutation to make a $(2n) cycle: $(Permutation(good_p))")
    println()
    println("Resulting matrix")
    B = A[:,good_p]
    display(B)
    my_spy(B)
end

function ez_cycle_pair(n::Int)
    A = adjacency(Cycle(n))
    Z = zeros(Int,n,n)
    B = [Z A; A Z]
    G = SimpleGraph(B)
    embed(G,:combined)
    return G 
end



