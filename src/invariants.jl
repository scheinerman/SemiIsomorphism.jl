using LinearAlgebraX, LinearAlgebra

import LinearAlgebraX: permanent, detx
import LinearAlgebra: det

permanent(G::SimpleGraph) = permanent(adjacency(G))
det(G::SimpleGraph) = det(adjacency(G))
detx(G::SimpleGraph) = detx(adjacency(G))



export det, detx, permanent