using SimpleGraphs
function graph_square(G::SimpleGraph{T}) where T
    H = SimpleGraph{T}()
    for v in G.V 
        add(H,v)
    end

    for v in G.V 
        for w in G.V 
            if dist(G,v,w) == 2 
                add!(H,v,w)
            end
        end
    end
    return H
end