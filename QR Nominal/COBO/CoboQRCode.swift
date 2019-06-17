// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

class CoboQRCode: QRCode {
    static func == (lhs: CoboQRCode, rhs: CoboQRCode) -> Bool {
        return lhs.checkSum == rhs.checkSum && lhs.compress == rhs.compress && lhs.index == rhs.index && lhs.total == rhs.total
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.total)
        hasher.combine(self.index)
        hasher.combine(self.checkSum)
        hasher.combine(self.compress)
    }
    
    var total: Int
    var index: Int
    var checkSum: String
    var value: String
    var compress: Bool
}

struct CoboQRCodeCollection: QRCodeCollection {
    typealias QRType = CoboQRCode
    
    var initialQR: CoboQRCode?
    private var internalArray: [CoboQRCode] = []
    private var currentInteration: Int = 0
    var completionBlock: ((Bool, Int, Int) -> ())?
    
    init() {
    }
    
    mutating func insert(qr: CoboQRCode) throws {
        if let validationError: CoboQRCodeInsertionError = validateInsertion(qr: qr) {
            throw validationError
        }
        if internalArray.contains(qr) { return }
        internalArray.append(qr)
        internalArray = internalArray.insertionSort({$0.index < $1.index})
        
        let collectionComplete = internalArray.count == internalArray.first?.total ?? -1
        completionBlock?(collectionComplete, internalArray.count, qr.total)
    }
    
    private mutating func validateInsertion(qr: CoboQRCode) -> CoboQRCodeInsertionError? {
        guard let initialQR = initialQR else {
            self.initialQR = qr
            return nil
        }
        if initialQR.total != qr.total { return CoboQRCodeInsertionError.total(lhs: initialQR.total, rhs: qr.total)}
        if initialQR.checkSum != qr.checkSum { return CoboQRCodeInsertionError.checkSum(lhs: initialQR.checkSum, rhs: qr.checkSum) }
        if initialQR.compress != qr.compress { return CoboQRCodeInsertionError.compress(lhs: initialQR.compress, rhs: qr.compress) }
        return nil
    }
    
    mutating func next() -> CoboQRCode? {
        defer {
            currentInteration += 1
        }
        guard !internalArray.isEmpty && internalArray.count > currentInteration else {
            return nil
        }
        return internalArray[currentInteration]
    }
}

enum CoboQRCodeInsertionError: LocalizedError {
    case total(lhs: Int, rhs: Int)
    case checkSum(lhs: String, rhs: String)
    case compress(lhs: Bool, rhs: Bool)
    
    var localizedDescription: String {
        switch self {
        case .total(let lhs, let rhs): return "Two Codes with different Total: \(lhs) vs \(rhs)"
        case .checkSum(let lhs, let rhs): return "Two Codes with different CheckSum: \(lhs) vs \(rhs)"
        case .compress(let lhs, let rhs): return "Two Codes with different Compress: \(lhs) vs \(rhs)"
        }
    }
}
