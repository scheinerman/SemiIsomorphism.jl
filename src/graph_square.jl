

using SimpleGraphs

"""
    graph_square(G::SimpleGraph)
Create a new graph in which two vertices are adacent if there is a two-step path 
between them in `G`.
"""
function graph_square(G::SimpleGraph{T}) where T
    A = adjacency(G)
    AA = A^2 
    return SimpleGraph(AA)
end