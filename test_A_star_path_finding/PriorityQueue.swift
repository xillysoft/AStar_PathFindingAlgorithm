//
//  BinaryHeap.swift
//  test_A_star_path_finding
//
//  Created by zhao on 2022/8/22.
//

import Foundation

//Binary Heap structure used to implement Priority Queue
struct PriorityQueue<KeyedData> where KeyedData: Comparable&Equatable {
    
    var heap_arr: [KeyedData] = []
    
    let ascending: Bool
    let _ordered: (KeyedData, KeyedData) -> Bool //closure to test if two elements are in correct ordere
    
    /**
     Ascending: Min-Heap; Descending: Max-Heap
     */
    init(ascending: Bool) {
        self.ascending = ascending
        _ordered = ascending ? {$0 <= $1} : {$0 >= $1}
    }
    
    init(array: [KeyedData], ascending: Bool) {
        self.init(ascending: ascending)
        for a in array {
            push(data: a)
        }
    }
    
    var isEmpty: Bool {
        return heap_arr.isEmpty
    }
    
    var count: Int {
        return heap_arr.count
    }
     
    //replace a element with new one
    mutating func replace_data(at index: Int, with new_data: KeyedData) {
        heap_arr[index] = new_data
        _heapifyUp(index: index)
        _heapifyDown(index: index)
    }
    
    @discardableResult
    mutating func replace_data(of old_data: KeyedData, with new_data: KeyedData) -> Bool {
        guard let index = heap_arr.firstIndex(of: old_data) else { return false} //not found
        replace_data(at: index, with: new_data)
        return true
    }
    
    var peek_min: KeyedData? {
        return heap_arr.first
    }
    
    //insert an element
    mutating func push(data: KeyedData) {
        let index = heap_arr.count //index to append new element to last position
        heap_arr.append(data)
        _heapifyUp(index: index)
    }
    
    //pop minimum/maximum element at the root of the tree
    mutating func pop() -> KeyedData? {
        if heap_arr.isEmpty { return nil }
        if heap_arr.count < 2 { return heap_arr.removeFirst() }
        let root = heap_arr[0]
        heap_arr[0] = heap_arr[heap_arr.count - 1]
        heap_arr.removeLast()
        
        _heapifyDown(index: 0)
        
        return root
    }
    
    //Insert then pop
    //Inserting an element then pop root from the heap can be done more efficiently
    // than simply calling the insert and pop functions
    mutating func push_pop(data: KeyedData) -> KeyedData? {
        if heap_arr.isEmpty {
            heap_arr.append(data)
            return nil
        }
        let root = heap_arr[0]
        heap_arr[0] = data
        _heapifyDown(index: 0)
        return root
    }
    
    mutating func remove(of data: KeyedData) -> Bool {
        guard let index = heap_arr.firstIndex(of: data) else { return false }
        remove(at: index)
        return true
    }
    
    mutating func remove(at index: Int) {
        if heap_arr.count < 2 { return }
        let elem_replaced = heap_arr.removeLast()
        heap_arr[index] = elem_replaced //Swap this element at `index` with the last element
        _heapifyUp(index: index)
        _heapifyDown(index: index)
    }
    
    //make element at `index` is in correct order
    mutating func _heapifyUp(index: Int) {
        var i = index
        while i > 0 {
            let i_parent = Int((i - 1) / 2)
            // check if [i_parent] ≥ [i] (for Min-Heap)
            if _ordered(heap_arr[i_parent], heap_arr[i]) { //in correct order
                break
            }
            
            //swap( [i], [i_parent] )
            (heap_arr[i_parent], heap_arr[i]) = (heap_arr[i], heap_arr[i_parent])
            //after swap, array[index] is now at array[i_parent]
            i = i_parent
        }
    }
    
    //make element at `index` is in correct order
    mutating func _heapifyDown(index: Int) {
        var i = index
        while i < heap_arr.count {
            let i_lchild = i * 2 + 1
            let i_rchild = i * 2 + 2
            
            var satisfied = true
            //check if [index] ≤ [l_child] && [index] ≤ [r_child] (for Min-Heap)
            if i_lchild < heap_arr.count {
                if !_ordered(heap_arr[i], heap_arr[i_lchild]) { satisfied = false }
            }
            if satisfied && i_rchild < heap_arr.count {
                if !_ordered(heap_arr[i], heap_arr[i_rchild]) { satisfied = false }
            }
            if satisfied {
                break
            }
            
            //case [i] > [i_lchild] or [i] > [i_rchild]
            let i_min_child: Int
            if i_rchild >= heap_arr.count {
                i_min_child = i_lchild
            } else {
                i_min_child = _ordered(heap_arr[i_lchild], heap_arr[i_rchild]) ? i_lchild : i_rchild
            }
            //swap( [i], [i_min_child] )
            (heap_arr[i], heap_arr[i_min_child]) = (heap_arr[i_min_child], heap_arr[i])
            i = i_min_child
        }
    }
}
