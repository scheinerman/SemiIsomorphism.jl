def permutations(possibleValuesByIndex):
    return permutationsHelper(0, possibleValuesByIndex, [])

def permutationsHelper(index, possibleValuesByIndex, visited):
    if index == len(possibleValuesByIndex):
        return [visited]
    
    possibleValues = set(possibleValuesByIndex[index]) - set(visited)

    results = []
    for nextValue in possibleValues:
        nextVisited = list(visited)
        nextVisited.append(nextValue)
        results.extend(permutationsHelper(index + 1, possibleValuesByIndex, nextVisited))
    return results

r = permutations([
    [1, 2, 3],
    [2, 1],
    [3, 2]
]);

print(r)
