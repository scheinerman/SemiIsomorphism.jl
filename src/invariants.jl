using LinearAlgebraX, LinearAlgebra

import LinearAlgebraX: permanent, detx
import LinearAlgebra: det, svd

permanent(G::SimpleGraph) = permanent(adjacency(G))
det(G::SimpleGraph) = det(adjacency(G))
detx(G::SimpleGraph) = detx(adjacency(G))



export det, detx, permanent

maxeig(A::Matrix) = maximum(eigvals(A))


"""
    maxeig(G::SimpleGraph)

Return the maximum eigenvalue of `G`'s adjacency matrix.
"""
maxeig(G::SimpleGraph) = maxeig(adjacency(G))

export maxeig

svd(G::SimpleGraph) = svdvals(adjacency(G))
export svd
