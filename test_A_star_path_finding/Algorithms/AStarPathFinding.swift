//
//  AStarPathFinding.swift
//  test_A_star_path_finding
//
//  Created by zhao on 2022/8/21.
//

import Foundation
import UIKit

private struct KeyedNode<Graph: IGraph> : Equatable&Comparable{
    typealias Node = Graph.NodePointi
    typealias WeightType = Graph.WeightType

    let node: Node
    let weight: WeightType
    
    init(_ node: Node, _ weight: WeightType) {
        self.node = node
        self.weight = weight
    }
    
    static func==(lhs: KeyedNode, rhs: KeyedNode) -> Bool {
        return lhs.node == rhs.node
    }
    
    static func <(lhs: KeyedNode, rhs: KeyedNode) -> Bool {
        return lhs.weight < rhs.weight
    }
}

/**
 A* shorted path finding algorithm
 */
func findPathAStar<Graph: IGraph>(from node0: Graph.NodePointi,
                                  to target: Graph.NodePointi,
                                  with graph: Graph) -> [Graph.NodePointi]? where Graph.WeightType: Hashable {
    
    typealias KeyedNode_ = KeyedNode<Graph>
    typealias Node = Graph.NodePointi
    typealias WeightType = Graph.WeightType
        
    var dist: [Node: WeightType] = [node0: 0]
    var parents: [Node: Node] = [:]
    
    var CLOSED: Set<Node> = [] //visited
                                            
    //Hashtable is used to membership test.
    var OPEN_S: Set<Node> = [node0] //in process quque
    
    //Priority Queue is used for selecting next `current` node with best (minimum) f[n] cost
    var OPEN_PQ = PriorityQueue<KeyedNode_>(ascending: true) //Priority is f[n]=g[n] + H(n, target)
    OPEN_PQ.push(data: KeyedNode(node0, 0))
    
    var i_ = 0
    let t0 = CFAbsoluteTimeGetCurrent()
    while  !OPEN_S.isEmpty {
        
        //find next node with minimum f[n]=g[n] + h[n] from OPEN
        guard let keyedNode = OPEN_PQ.pop() else { fatalError() }
        let n = keyedNode.node
        let f_n = keyedNode.weight
        
        OPEN_S.remove(n)
        CLOSED.insert(n)
        
        //check if target node reached
        if n == target {
            print("Path to target node found!")
            var pathNodes: [Node] = []
            pathNodes.append(target)
            var p = target
            while case let next? = parents[p] {
                pathNodes.append(next)
                p = next
            }
//                print("\tpath=\(pathNodes)")
            return Array(pathNodes.reversed())
        }

        //propagate `n` node to its neighbors
        for y in graph.adjacentNodes(with: n) {
            let g_y = dist[n]! + graph.W(n, y)!
            if OPEN_S.contains(y) {
                if g_y < dist[y]! {
                    let f_y = g_y + graph.H(y, target)
                    
                    //instead of PriorityQueue::decrease_key() which have O(N)+O(logN) time complexity,
                    // insert the modified node again, resulting the node processed twice but finally better performance achieved.
                    OPEN_PQ.push(data: KeyedNode_(y, f_y))

                    dist[y] = g_y
                    parents[y] = n
                }
            } else if !CLOSED.contains(y) {
                let f_y = g_y + graph.H(y, target)
                OPEN_PQ.push(data: KeyedNode(y, f_y))
                OPEN_S.insert(y)
                
                dist[y] = g_y
                parents[y] = n
                
            }
            
        }
        
        if i_ % 5000 == 0 {
            print("[\(i_)]: OPEN_PQ.count=\(OPEN_PQ.count) OPEN_S.count=\(OPEN_S.count) CLOSED.count=\(CLOSED.count), time=\(CFAbsoluteTimeGetCurrent() - t0)")
            print("\tselected current n=\(n), f_n=\(f_n)")
        }
        i_ += 1
    }
    
    print("No path to target node found!")
    return nil
}

