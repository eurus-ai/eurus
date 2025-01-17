#if os(Linux)
    import Glibc
    import SwiftShims
#else
    import Darwin
#endif

func apply<T, R>(_ arg: [T], _ handler: (T) -> R) -> [R] {
    var inPointer = UnsafePointer(arg)
    let outPointer = UnsafeMutablePointer<R>.allocate(capacity: arg.count)
    defer { outPointer.deallocate() }
    
    var p = outPointer
    for _ in 0..<arg.count {
        p.pointee = handler(inPointer.pointee)
        p += 1
        inPointer += 1
    }
    
    return [R](UnsafeBufferPointer(start: outPointer, count: arg.count))
}

func combine<T, U, R>(_ lhs: [T], _ rhs: [U], _ handler: (T, U) -> R) -> [R] {
    precondition(lhs.count == rhs.count, "Two arrays have incompatible size.")
    
    var lhsPointer = UnsafePointer(lhs)
    var rhsPointer = UnsafePointer(rhs)
    let outPointer = UnsafeMutablePointer<R>.allocate(capacity: lhs.count)
    defer { outPointer.deallocate() }
    
    var p = outPointer
    for _ in 0..<rhs.count {
        p.pointee = handler(lhsPointer.pointee, rhsPointer.pointee)
        p += 1
        lhsPointer += 1
        rhsPointer += 1
    }
    
    return [R](UnsafeBufferPointer(start: outPointer, count: lhs.count))
}

func apply<T, R>(_ arg: Tensor<T>, _ handler: (T) -> R) -> Tensor<R> {
    return Tensor(shape: arg.shape, elements: apply(arg.data, handler))
}

func combine<T, U, R>(_ lhs: Tensor<T>, _ rhs: Tensor<U>, _ handler: (T, U) -> R) -> Tensor<R> {
    precondition(lhs.shape==rhs.shape, "Two Tensors have incompatible shape.")
    return Tensor(shape: lhs.shape, elements: combine(lhs.data, rhs.data, handler))
}

// index calculation
func calculateIndex(_ shape: [Int], _ index: [Int]) -> Int {
    /* calculate index in elelemnts from index in Tensor
     *
     * example:
     * - arguments:
     *   + array.shape = [3, 4, 5]
     *   + index = [1, 2, 3]
     * - return:
     *   + ((3)*4+2)*5+3 = 73
     */
    
    precondition(index.count == shape.count, "Invalid index.")
    
    // minus index
    var index = index
    for i in 0..<index.count {
        precondition(-shape[i] <= index[i] && index[i] < shape[i], "Invalid index.")
        if index[i] < 0 {
            index[i] += shape[i]
        }
    }
    
    // calculate
    let elementIndex = zip(index, Array(shape.dropFirst()) + [1]).reduce(0) { acc, x in
        return (acc + x.0) * x.1
    }
    
    return elementIndex
}

func calculateIndices(_ indicesInAxes: [[Int]]) -> [[Int]] {
    /* calculate indices in Tensor from indices in axes
     *
     * example:
     * - arguments:
     *   + array.shape = [3, 4, 5]
     *   + indices = [[1, 2], [2, 3], [3]]
     * - return:
     *   + [[1, 2, 3], [1, 3, 3], [2, 2, 3], [2, 3, 3]]
     */
    
    guard indicesInAxes.count > 0 else {
        return [[]]
    }
    let head = indicesInAxes[0]
    let tail = Array(indicesInAxes.dropFirst())
    let appended =  head.flatMap { h -> [[Int]] in
        calculateIndices(tail).map { list in [h] + list }
    }
    return appended
}

func formatIndicesInAxes(_ shape: [Int], _ indicesInAxes: [[Int]?]) -> [[Int]] {
    /* Format subarray's indices
     * - fulfill shortage
     * - nil turns into full indices
     *
     * example:
     * - arguments:
     *   + array.shape = [3, 4, 5]
     *   + indices = [[1, 2], [2, 3]]
     * - return:
     *   + [[1, 2], [2, 3], [0, 1, 2, 3, 4]]
     */
    var padIndices = indicesInAxes
    if padIndices.count < shape.count {
        padIndices = indicesInAxes + [[Int]?](repeating: nil, count: shape.count - padIndices.count)
    }
    
    let indices = padIndices.enumerated().map { i, indexArray in
        indexArray ?? Array(0..<shape[i])
    }
    return indices
}

extension Array {
    func removed(at index: Int) -> Array {
        var array = self
        array.remove(at: index)
        return array
    }
    
    func replaced(with newElement: Element, at index: Int) -> Array {
        var array = self
        array[index] = newElement
        return array
    }
}

func shapeForBroadcast(_ lhs: [Int], _ rhs: [Int]) -> [Int]? {
    let dim = Swift.max(lhs.count, rhs.count)
    let pLhs = Array(repeating: 1, count: dim - lhs.count) + lhs
    let pRhs = Array(repeating: 1, count: dim - rhs.count) + rhs
    let shape = zip(pLhs, pRhs).map({ (tuple: (pLh: Int, pRh: Int))->Int in
        var result = 0 // 0 as invalid
        if tuple.pLh == tuple.pRh {
            result = tuple.pLh
        }else if tuple.pLh == 1 && tuple.pRh > tuple.pLh {
            result = tuple.pRh
        }else if tuple.pRh == 1 && tuple.pLh > tuple.pRh {
            result =  tuple.pLh
        }
        return result
    })
    if shape.contains(0) {
        return nil
    }else {
        return shape
    }
    
}
