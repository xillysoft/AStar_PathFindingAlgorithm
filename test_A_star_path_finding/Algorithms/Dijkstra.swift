//
//  Dijkstra.swift
//  test_cube_two_two
//
//  Created by zhao on 2022/8/19.
//

import Foundation

/**
 Dijkstra shortes path finding algorithm
 */
@discardableResult
func findPathDijkstra<Graph: IGraph>(from node0: Graph.Node, to target: Graph.Node, with graph: Graph) -> [Graph.Node]? {
    typealias Node = Graph.Node
    typealias WeightType = Graph.WeightType
    
            
    var dist: [Node: WeightType] = [node0: WeightType.zero]
    var parents: [Node: Node] = [:]
    
    var OPEN: Set<Node> = []
    for x in graph.adjacentNodes(with: node0) {
        OPEN.insert(x)
        dist[x] = graph.W(node0, x)!
        parents[x] = node0
    }
    var CLOSED: Set<Node> = [node0]

    var i_ = 0
    let t0 = CFAbsoluteTimeGetCurrent()
    while !OPEN.isEmpty {
        
        //choose new current from openNodes
        var n: Node! = nil
        var f_n: WeightType!
        for x in OPEN {
            let f_x = dist[x]! //f_x = dist[x]! + h_x = dist[x]! + H[x, target]; H[a, b]==0 in Dijkstra
            // where dist[u] != nil
            if n == nil || f_x < f_n{
                n = x
                f_n = f_x
            }
        }
        
        guard let current = n else {
            print("No path found!")
            return nil
        }

//        print("\tprocess current=\(current)\n\t\tdist=\(dist)")
        //remove current from unvisited nodes
        OPEN.remove(current)
        CLOSED.insert(current)

        if current == target {
            print("Path found!")
            var path: [Node] = [target]
            var n = target
            while case let next? = parents[n] {
                path.append(next)
                n = next
            }
            return Array<Node>(path.reversed())
        }
        
        //propagate `current` to its adjacent nodes
        for y in graph.adjacentNodes(with: current) {
                let g_y = dist[current]! + graph.W(current, y)!
                if OPEN.contains(y) {
                    if g_y < dist[y]! {
                        dist[y] = g_y
                        parents[y] = current
                    }
                } else if !CLOSED.contains(y) {
                    OPEN.insert(y)
                    dist[y] = g_y
                    parents[y] = current
                }
        }
        
        if i_ % 2000 == 0 {
            print("[\(i_)]: openNodes.count=\(OPEN.count), closedNodes.count=\(CLOSED.count), time=\(CFAbsoluteTimeGetCurrent() - t0)")
        }
        i_ += 1
    }
    
    print("No path found!")
    return nil
}
