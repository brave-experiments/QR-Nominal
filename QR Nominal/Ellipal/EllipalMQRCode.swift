// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

class EllipalMQRCode: Codable, Hashable {
    static func == (lhs: EllipalMQRCode, rhs: EllipalMQRCode) -> Bool {
        return lhs.index == rhs.index && lhs.total == rhs.total
    }
    
    init(version: String, index: Int, total: Int, action: String, components: [String]) {
        self.version = version
        self.index = index
        self.total = total
        self.action = action
        self.components = components
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.total)
        hasher.combine(self.index)
    }
    
    let version: String
    let total: Int
    let index: Int
    let action: String
    let components: [String]
}

struct EllipalMQRCodeCollection: Sequence, IteratorProtocol {
    
    var initialQR: EllipalMQRCode?
    private var internalArray: [EllipalMQRCode] = []
    private var currentIteration: Int = 0
    var completionBlock: ((Bool, Int, Int) -> ())?
    
    init() {
    }
    
    mutating func insert(qr: EllipalMQRCode) throws {
        if let validationError: EllipalMQRCodeInsertionError = validateInsertion(qr: qr) {
            throw validationError
        }
        if internalArray.contains(qr) { return }
        internalArray.append(qr)
        internalArray = internalArray.insertionSort({$0.index < $1.index})
        
        let collectionComplete = internalArray.count == internalArray.first?.total ?? -1
        completionBlock?(collectionComplete, internalArray.count, qr.total)
    }
    
    private mutating func validateInsertion(qr: EllipalMQRCode) -> EllipalMQRCodeInsertionError? {
        guard let initialQR = initialQR else {
            self.initialQR = qr
            return nil
        }
        if initialQR.total != qr.total { return EllipalMQRCodeInsertionError.total(lhs: initialQR.total, rhs: qr.total)}
        return nil
    }
    
    mutating func next() -> EllipalMQRCode? {
        defer {
            currentIteration += 1
        }
        guard !internalArray.isEmpty && internalArray.count > currentIteration else {
            return nil
        }
        return internalArray[currentIteration]
    }
}

enum EllipalMQRCodeInsertionError: LocalizedError {
    case total(lhs: Int, rhs: Int)
    
    var localizedDescription: String {
        switch self {
        case .total(let lhs, let rhs): return "Two Codes with different Total: \(lhs) vs \(rhs)"
        }
    }
}
