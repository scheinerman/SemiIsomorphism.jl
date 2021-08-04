export frac_iso, frac_iso012, split012

"""
    frac_iso(G,H)

Find a doubly stochastic matrix `S` so that `AS=SB` where `A` and `B`
are the adjacency matrices of `G` and `H` respectively.
"""
function frac_iso(G::SimpleGraph, H::SimpleGraph)
    A = adjacency(G)
    B = adjacency(H)
    return frac_iso(A, B)
end

function frac_iso(A::Matrix, B::Matrix)
    n, c = size(A)
    nn, cc = size(B)
    @assert n == c && nn == cc "Matrices must be square"
    @assert n == n "Matrices must have the same size"

    m = Model(get_solver())

    @variable(m, S[1:n, 1:n])

    for i = 1:n
        for k = 1:n
            @constraint(
                m,
                sum(A[i, j] * S[j, k] for j = 1:n) == sum(S[i, j] * B[j, k] for j = 1:n)
            )
        end
        @constraint(m, sum(S[i, j] for j = 1:n) == 1)
        @constraint(m, sum(S[j, i] for j = 1:n) == 1)
    end

    for i = 1:n
        for j = 1:n
            @constraint(m, S[i, j] >= 0)
        end
    end

    optimize!(m)
    status = Int(termination_status(m))

    if status != 1
        error("The graphs are not fractionally isomorphic")
    end

    return value.(S)

end



"""
    frac_iso012(G,H) 

Check if the graphs `G` and `H` are fractionally isomorphic via a matrix S 
whose entries are all 0, 1/2, or 1. But actually return 2S, so it's an integer 
matrix with entries in {0,1,2}.
"""
function frac_iso012(G::SimpleGraph, H::SimpleGraph)
    A = adjacency(G)
    B = adjacency(H)
    return frac_iso012(A, B)
end

function frac_iso012(A::Matrix, B::Matrix)
    n, c = size(A)
    nn, cc = size(B)
    @assert n == c && nn == cc "Matrices must be square"
    @assert n == n "Matrices must have the same size"

    m = Model(get_solver())

    @variable(m, S[1:n, 1:n], Int)

    for i = 1:n
        for k = 1:n
            @constraint(
                m,
                sum(A[i, j] * S[j, k] for j = 1:n) == sum(S[i, j] * B[j, k] for j = 1:n)
            )
        end
        @constraint(m, sum(S[i, j] for j = 1:n) == 2)
        @constraint(m, sum(S[j, i] for j = 1:n) == 2)
    end

    for i = 1:n
        for j = 1:n
            @constraint(m, S[i, j] >= 0)
        end
    end

    optimize!(m)
    status = Int(termination_status(m))

    if status != 1
        error("The graphs are not 012-fractionally isomorphic")
    end

    return Int.(round.(value.(S)))
end



"""
    split012(S::Matrix{Int})

Given a square matrix `S`, write `S` as the sum of two permutation 
matrices (if possible). Returns the two permutation matrices.
"""
function split012(S::Matrix{Int})
    n, c = size(S)
    @assert n == c "Matrix must be square"

    m = Model(get_solver())

    @variable(m, P[1:n, 1:n], Bin)
    @variable(m, Q[1:n, 1:n], Bin)

    # make sure P and Q are permutation matrices
    for i = 1:n
        @constraint(m, sum(P[i, j] for j = 1:n) == 1)
        @constraint(m, sum(P[j, i] for j = 1:n) == 1)

        @constraint(m, sum(Q[i, j] for j = 1:n) == 1)
        @constraint(m, sum(Q[j, i] for j = 1:n) == 1)
    end

    # make sure S = P+Q 
    for i = 1:n
        for j = 1:n
            @constraint(m, P[i, j] + Q[i, j] == S[i, j])
        end
    end

    optimize!(m)
    status = Int(termination_status(m))

    if status != 1
        error("Matrix is not the sum of two permutation matrices")
    end


    PP = Int.(value.(P))
    QQ = Int.(value.(Q))
    return PP, QQ

end
