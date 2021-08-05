# GraphTheory()



module SemiIsomorphism

using SimpleGraphs, SimpleGraphAlgorithms, ChooseOptimizer, SimpleTools
using Combinatorics, Permutations, JuMP, Gurobi, LinearAlgebra, ProgressMeter
# using SimpleGraphRepresentations, SimpleTools

include("RPG.jl")

###############################################################################

export semi_iso, is_semi_iso, semi_auto, auto, semi_mates, semi_auto_1

"""
    semi_iso(G,H)

Find  permutation matrices `P` and `Q` such that `AP==QB`
where `A` and `B` are the 
adjacency matrices of `G` and `H` respectively.
"""
function semi_iso(G::SimpleGraph, H::SimpleGraph)
    A = adjacency(G)
    B = adjacency(H)
    return semi_iso(A, B)
end


function semi_iso(A::Matrix, B::Matrix)
    n, c = size(A)
    nn, cc = size(B)
    @assert n == c && nn == cc "Matrices must be square"
    @assert n == nn "Matrices must have the same size"

    m = Model(get_solver())

    @variable(m, P[1:n, 1:n], Bin)
    @variable(m, Q[1:n, 1:n], Bin)

    for i = 1:n
        for k = 1:n
            @constraint(
                m,
                sum(A[i, j] * P[j, k] for j = 1:n) == sum(Q[i, j] * B[j, k] for j = 1:n)
            )
        end
        @constraint(m, sum(P[i, j] for j = 1:n) == 1)
        @constraint(m, sum(P[j, i] for j = 1:n) == 1)

        @constraint(m, sum(Q[i, j] for j = 1:n) == 1)
        @constraint(m, sum(Q[j, i] for j = 1:n) == 1)
    end

    optimize!(m)
    status = Int(termination_status(m))

    if status != 1
        error("These graphs are not semi-isomorphic")
    end

    return Int.(value.(P)), Int.(value.(Q))
end

"""
    is_semi_iso(G,H)

returns `true` is the graphs are semi-isomorphic.
"""
function is_semi_iso(G::SimpleGraph, H::SimpleGraph)::Bool
    try
        semi_iso(G, H)
    catch
        return false
    end
    return true
end

"""
    semi_iso_1(G,H)

One sided semi-isomorphism.
"""
function semi_iso_1(A::Matrix, B::Matrix)
    n, c = size(A)
    nn, cc = size(B)
    @assert n == c && nn == cc "Matrices must be square"
    @assert n == nn "Matrices must have the same size"

    m = Model(get_solver())

    @variable(m, P[1:n, 1:n], Bin)

    for i = 1:n
        for k = 1:n
            @constraint(m, sum(A[i, j] * P[j, k] for j = 1:n) == B[i, k])
        end
        @constraint(m, sum(P[i, j] for j = 1:n) == 1)
        @constraint(m, sum(P[j, i] for j = 1:n) == 1)
    end

    optimize!(m)
    status = Int(termination_status(m))

    if status != 1
        error("These graphs are not simply semi-isomorphic")
    end

    return Int.(value.(P))
end

function semi_iso_1(G::SimpleGraph, H::SimpleGraph)
    A = adjacency(G)
    B = adjacency(H)
    return semi_iso_1(A, B)
end

function semi_auto_1(A::Matrix)
    n, c = size(A)
    @assert n == c "Matrix must be square"

    [Permutation(p) for p in permutations(1:n) if A[p, :] == A]
end

"""
    semi_auto_1(G)

Return all permutations s.t. `AP==A` where `A` is the 
adjacency matrix of `G` and `P` is a permutation matrix.
"""
semi_auto_1(G::SimpleGraph) = semi_auto_1(adjacency(G))


function semi_auto(A::Matrix)
    n, c = size(A)
    @assert n == c "Matrix must be square"

    [
        (Permutation(p), Permutation(q)) for p in permutations(1:n) for
        q in permutations(1:n) if A[p, q] == A
    ]
end


"""
    is_adjacency(A::Matrix)
Check if the 0-1 matrix `A` is the adjacency matrix of a simple graph.
"""
function is_adjacency(A::Matrix)::Bool
    A == A' && tr(A) == 0
end


"""
    semi_auto(G)

List out the elements of the semi-automorphism group of G. These are pairs of permutations
such that `P' A Q == A`.
"""
semi_auto(G::SimpleGraph) = semi_auto(adjacency(G))


function auto(A::Matrix)
    n, c = size(A)
    @assert n == c "Matrix must be square"

    [Permutation(p) for p in permutations(1:n) if A[p, p] == A]
end

"""
    auto(G)

List out all the automorphisms of `G`.
"""
auto(G::SimpleGraph) = auto(adjacency(G))

"""
    semi_mates(G::SimpleGraph)

Find other graphs that are semi-isomorphic to `G`. Optional named arguments:
* stopper (`false`): Stop at first match different from `G`
* uhash_check (`true`): Skip presumably isomorphic graphs found
"""
function semi_mates(G::SimpleGraph; stopper::Bool = false, uhash_check::Bool = true)
    A = adjacency(G)
    n = NV(G)

    list = SimpleGraph{Int}[]
    hashes = UInt[]

    push!(list, relabel(G))

    @info "Generating allowable permutations ... "
    allow = make_allow(A)


    push!(hashes, uhash(G))
    good_perms = RPG(n, allow)

    @info "There are $(length(good_perms)) permutations to consider"

    PM = Progress(length(good_perms))

    for p in RPG(n, allow)
        next!(PM)
        B = A[:, p]
        if B != B'
            continue
        end
        H = SimpleGraph(B)
        uH = uhash(H)

        if (!uhash_check || uH ∉ hashes) && H ∉ list
            push!(list, H)
            push!(hashes, uH)
            if stopper
                println("Quick stop")
                return H
            end
        end

    end
    return list

end


function example_maker(A0::Matrix, emb::Bool = false)
    A = dcat(A0, A0)
    B = [0A0 A0; A0 0A0]

    G = SimpleGraph(A)
    H = SimpleGraph(B)

    if emb
        embed(G, :combined)
        embed(H, :combined)
    end
    return G, H
end


function example_maker(G::SimpleGraph, emb::Bool = false)
    A = adjacency(G)
    return example_maker(A, emb)
end

include("frac_iso.jl")
include("one_side_group.jl")

end # module
