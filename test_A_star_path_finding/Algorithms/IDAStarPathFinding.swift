//
//  IDAStarPathFinding.swift
//  test_A_star_path_finding
//
//  Created by zhao on 2022/8/27.
//

import Foundation

/**
 IDA* shorted path finding algorithm
 */
class IDAStarPathFinding<Graph: IGraph> {
    
    typealias Node = Graph.Node
    typealias WeightType = Graph.WeightType
    
    let node0: Node
    let target: Node
    let graph: Graph
    
    init(node0: Node, target: Node, graph: Graph) {
        self.node0 = node0
        self.target = target
        self.graph = graph
    }
    
    var path: [Node] = []
    var pathS: Set<Node> = []
    
    func findPath_ID_AStar() -> [Node]? {
        guard var f_bound = graph.H(node0, target) else { return nil }
        path = [node0]
        pathS.insert(node0)
        
        print("IDA* path finding...")
        repeat {
            print("\tTry f_bound=\(f_bound) ")
            guard let (found, f_bound1) = _search(n: node0, g_n: 0, f_bound: f_bound) else { return nil }
            if found {
                let g_target = f_bound1!
                print("\tFound! \n\tpath.count=\(path.count)\n\tG[target]=\(g_target)")
                return path
            }
            
            guard let f_bound1 = f_bound1 else { //f_bound1==nil -> Infinity
                print("\tNo path found!") //exit
                return nil
            }

            f_bound = f_bound1 //!found && f_bound1!=nil
            
        } while true
    }

    func _search(n: Node, g_n: WeightType, f_bound: WeightType)
    -> (found: Bool, min_bound: Graph.WeightType?)? {
        
        guard let h_y = graph.H(n, target) else { return nil } //not possible to find path from n to target for H(n)==nil
        let f_n = g_n + h_y
        if f_n > f_bound {
            return (false, f_n)
        }
        
        if n == target {
            return (true, g_n)
        }
        
        
        //sort result array of graph.adjacentNodes(with: n) ascending by f_x
        let A = graph.adjacentNodes(with: n).filter {
            graph.H($0, target) != nil
        }
        
        let A_sorted = A.sorted {
            let w_nx = graph.W(n, $0)!
            let w_ny = graph.W(n, $1)!
            let f_x = g_n + w_nx  + graph.H($0, target)!
            let f_y = g_n + w_ny + graph.H($1, target)!
            return f_x < f_y
        }
        
        var min_bound: Graph.WeightType? = nil
        for x in  A_sorted {
            if pathS.contains(x) { continue } //prevent cycling

            path.append(x)
            pathS.insert(x)

            let g_x = g_n + graph.W(n, x)! //for x is of graph.adjacentNodes(with: n)
    //        let f_x = g_x + graph.H(x, target)
            if let (found, min_bound1) = _search(n: x, g_n: g_x, f_bound: f_bound){
                if found {
                    return (true, min_bound1!)
                } else if let min_bound1 = min_bound1 {
                    if min_bound == nil || min_bound1 < min_bound! {
                        min_bound = min_bound1
                    }
                }
            }
            
            path.removeLast()
            pathS.remove(x)
        }
        
        return (false, min_bound)
    }
    
}
