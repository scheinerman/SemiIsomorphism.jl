export make_graph

"""
    make_graph(A::Matrix, verbose::Bool=false)

Use the matrix `A` to build a graph. Ideally, `A` is an adjacency matrix.
But if not we (1) zero out the diagonal, (2) make it symmetric, and (3)
make it zero-one.

Optional second argument `verbose=true` reports what's happening. 
"""
function make_graph(A::Matrix, verbose::Bool = false)::SimpleGraph
    n, c = size(A)
    if n != c
        error("Matrix must be square; can't fix that.")
    end

    A = copy(A)

    verbose && println("Making sure the matrix is symmetric")
    B = transpose(A)
    if A != B
        A += B
    end

    verbose && println("Making sure the diagonal is all zeros")
    for j = 1:n
        @inbounds A[j, j] = 0
    end

    verbose && println("Making sure the entries are zeros and ones")
    A = Int.(A .!= 0)

    verbose && println("Creating the graph")
    return SimpleGraph(A)

end