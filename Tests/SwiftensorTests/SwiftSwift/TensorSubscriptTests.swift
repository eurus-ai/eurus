import XCTest
@testable import Swiftensor

class TensorSubscriptTests: XCTestCase {
    
    func testSubscriptGetElement() {
        let x = Tensor<Int>(shape: [3, 2], elements: [1, 2, 3, 4, 5, 6])
        
        // normal access
        XCTAssertEqual(x[0, 0], 1)
        XCTAssertEqual(x[0, 1], 2)
        XCTAssertEqual(x[1, 0], 3)
        XCTAssertEqual(x[1, 1], 4)
        XCTAssertEqual(x[2, 0], 5)
        XCTAssertEqual(x[2, 1], 6)
        
        // minus index access
        XCTAssertEqual(x[-3, -2], 1)
        XCTAssertEqual(x[-3, -1], 2)
        XCTAssertEqual(x[-2, -2], 3)
        XCTAssertEqual(x[-2, -1], 4)
        XCTAssertEqual(x[-1, -2], 5)
        XCTAssertEqual(x[-1, -1], 6)
    }
    
    func testSubscriptSetElement() {
        var x = Tensor<Int>(shape: [3, 2], elements: [1, 2, 3, 4, 5, 6])
        
        x[0, 0] = -1
        XCTAssertEqual(x, Tensor<Int>(shape: [3, 2], elements: [-1, 2, 3, 4, 5, 6]))
        
        x[-1, -1] = -2
        XCTAssertEqual(x, Tensor<Int>(shape: [3, 2], elements: [-1, 2, 3, 4, 5, -2]))
    }
    
    func testSubscriptGetSubarray() {
        let x = Tensor<Int>(shape: [3, 2], elements: [1, 2, 3, 4, 5, 6])
        
        // get subarray
        XCTAssertEqual(x[[0, 1], [0, 1]], Tensor(shape: [2, 2], elements: [1, 2, 3, 4]))
        XCTAssertEqual(x[0..<2, 0..<2], Tensor(shape: [2, 2], elements: [1, 2, 3, 4]))
        
        // auto fulfill
        XCTAssertEqual(x[[0]], Tensor(shape: [1, 2], elements: [1, 2]))
        XCTAssertEqual(x[[-3]], Tensor(shape: [1, 2], elements: [1, 2]))
        XCTAssertEqual(x[0..<1], Tensor(shape: [1, 2], elements: [1, 2]))
        XCTAssertEqual(x[(-3)..<(-2)], Tensor(shape: [1, 2], elements: [1, 2]))
        
        // nil means numpy's `:`
        XCTAssertEqual(x[nil, [0]], Tensor(shape: [3, 1], elements: [1, 3, 5]))
    }
    
    func testSubscriptSetSubarray() {
        var x = Tensor<Int>(shape: [3, 2], elements: [1, 2, 3, 4, 5, 6])
        x[[-3]] = Tensor(shape: [1, 2], elements: [0, 0])
        XCTAssertEqual(x, Tensor<Int>(shape: [3, 2], elements: [0, 0, 3, 4, 5, 6]))
        x[nil, [0]] = Tensor(shape: [3, 1], elements: [0, 0, 0])
        XCTAssertEqual(x, Tensor(shape: [3, 2], elements: [0, 0, 0, 4, 0, 6]))
    }
    
    static var allTests: [(String, (TensorSubscriptTests) -> () throws -> Void)] {
        return [
            ("testSubscriptGetElement", testSubscriptGetElement),
            ("testSubscriptSetElement", testSubscriptSetElement),
            ("testSubscriptGetSubarray", testSubscriptGetSubarray),
            ("testSubscriptSetSubarray", testSubscriptSetSubarray)
        ]
    }
}
