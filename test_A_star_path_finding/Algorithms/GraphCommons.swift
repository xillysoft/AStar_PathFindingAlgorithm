//
//  GraphCommons.swift
//  test_cube_two_two
//
//  Created by zhao on 2022/8/21.
//

import Foundation

protocol IGraph {
    associatedtype NodePointi: Hashable
    associatedtype WeightType: Numeric&Comparable
//    typealias WeightType = Float
    
    func adjacentNodes(with node: NodePointi) -> Set<NodePointi>
    func W(_ a: NodePointi, _ b: NodePointi) -> WeightType?

    /**
     Heuristic distance from node a to target
     */
    func H(_ a: NodePointi, _ target: NodePointi) -> WeightType
}

extension IGraph {
    func H(_ a: NodePointi, _ target: NodePointi) -> WeightType {
        return WeightType.zero
    }
}
