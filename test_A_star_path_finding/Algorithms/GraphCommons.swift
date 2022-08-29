//
//  GraphCommons.swift
//  test_cube_two_two
//
//  Created by zhao on 2022/8/21.
//

import Foundation

protocol IGraph {
    associatedtype Node: Hashable
    associatedtype WeightType: Numeric&Comparable
//    typealias WeightType = Float
    
    func adjacentNodes(with node: Node) -> Set<Node>
    func W(_ a: Node, _ b: Node) -> WeightType?

    /**
     Heuristic distance from node a to target
     */
    func H(_ a: Node, _ target: Node) -> WeightType?
}

/*
extension IGraph {
    func H(_ a: Node, _ target: Node) -> WeightType? {
        return WeightType.zero
    }
}
 */
