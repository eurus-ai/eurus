import XCTest
@testable import Swiftensor

class TensorStackTests: XCTestCase {
    
    func testConcatenate() {
        do {
            // axis 0
            let a = Tensor(shape: [2, 2], elements: [1, 2, 3, 4])
            let b = Tensor(shape: [3, 2], elements: [1, 2, 3, 4, 5, 6])
            
            XCTAssertEqual(Tensor.concatenate([a, b], along: 0),
                           Tensor(shape: [5, 2], elements: [1, 2, 3, 4, 1, 2, 3, 4, 5, 6]))
            XCTAssertEqual(Tensor.concatenate([a, b], along: -2),
                           Tensor(shape: [5, 2], elements: [1, 2, 3, 4, 1, 2, 3, 4, 5, 6]))
        }
        do {
            // axis 1
            let a = Tensor(shape: [2, 2], elements: [1, 2, 3, 4])
            let b = Tensor(shape: [2, 3], elements: [1, 2, 3, 4, 5, 6])
            
            XCTAssertEqual(Tensor.concatenate([a, b], along: 1),
                           Tensor(shape: [2, 5], elements: [1, 2, 1, 2, 3, 3, 4, 4, 5, 6]))
            XCTAssertEqual(Tensor.concatenate([a, b], along: -1),
                           Tensor(shape: [2, 5], elements: [1, 2, 1, 2, 3, 3, 4, 4, 5, 6]))
        }
        
        do {
            let a = Tensor<Int>.range(from: 0, to: 2*3*4, stride: 1).reshaped([2, 3, 4])
            
            XCTAssertEqual(Tensor.concatenate([a, a, a], along: 0),
                           Tensor(shape: [6, 3, 4],
                                   elements: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12,
                                              13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23,
                                              0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12,
                                              13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23,
                                              0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12,
                                              13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23]))
            XCTAssertEqual(Tensor.concatenate([a, a, a], along: 1),
                           Tensor(shape: [2, 9, 4],
                                   elements: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
                                              0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
                                              0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
                                              12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23,
                                              12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23,
                                              12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23]))
            
            XCTAssertEqual(Tensor.concatenate([a, a, a], along: 2),
                           Tensor(shape: [2, 3, 12],
                                   elements: [0, 1, 2, 3, 0, 1, 2, 3, 0, 1, 2, 3,
                                              4, 5, 6, 7, 4, 5, 6, 7, 4, 5, 6, 7,
                                              8, 9, 10, 11, 8, 9, 10, 11, 8, 9, 10, 11,
                                              12, 13, 14, 15, 12, 13, 14, 15, 12, 13, 14, 15,
                                              16, 17, 18, 19, 16, 17, 18, 19, 16, 17, 18, 19,
                                              20, 21, 22, 23, 20, 21, 22, 23, 20, 21, 22, 23]))
        }
    }
    
    func testStack() {
        do {
            let a = Tensor<Int>.range(from: 0, to: 12, stride: 1).reshaped([3, 4])
            
            XCTAssertEqual(Tensor.stack([a, a], axis: 0),
                           Tensor(shape: [2, 3, 4],
                                   elements: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
                                              0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]))
            XCTAssertEqual(Tensor.stack([a, a], axis: -3),
                           Tensor(shape: [2, 3, 4],
                                   elements: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
                                              0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]))
            
            XCTAssertEqual(Tensor.stack([a, a], axis: 1),
                           Tensor(shape: [3, 2, 4],
                                   elements: [0, 1, 2, 3, 0, 1, 2, 3,
                                              4, 5, 6, 7, 4, 5, 6, 7,
                                              8, 9, 10, 11, 8, 9, 10, 11]))
            XCTAssertEqual(Tensor.stack([a, a], axis: -2),
                           Tensor(shape: [3, 2, 4],
                                   elements: [0, 1, 2, 3, 0, 1, 2, 3,
                                              4, 5, 6, 7, 4, 5, 6, 7,
                                              8, 9, 10, 11, 8, 9, 10, 11]))
            
            XCTAssertEqual(Tensor.stack([a, a], axis: 2),
                           Tensor(shape: [3, 4, 2],
                                   elements: [0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5,
                                              6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11]))
            XCTAssertEqual(Tensor.stack([a, a], axis: -1),
                           Tensor(shape: [3, 4, 2],
                                   elements: [0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5,
                                              6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11]))
            
        }
    }
    
    static var allTests: [(String, (TensorStackTests) -> () throws -> Void)] {
        return [
            ("testConcatenate", testConcatenate),
            ("testStack", testStack)
        ]
    }
}
