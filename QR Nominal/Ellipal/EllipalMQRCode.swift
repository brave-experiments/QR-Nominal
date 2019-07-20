// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

class EllipalMQRCode: Hashable {
    static func == (lhs: EllipalMQRCode, rhs: EllipalMQRCode) -> Bool {
        return lhs.action == rhs.action && lhs.index == rhs.index && lhs.total == rhs.total
    }

    init(version: String, index: Int, total: Int, action: String, components: [String]) throws {
        self.version = version
        self.index = index
        self.total = total
        self.action = action
        self.components = components

        let thisAction = ActionType(rawValue: action) ?? ActionType.unknown
        var entries: [String]
        var dictionary: [String: Any] = ["version": version, "action": action]
        switch thisAction {
        case .sync:
            if (components.count < 4 || components.count > 5) {
                throw EllipalMQRCodeInsertionError.paramLength(actual: components.count, expected: 4)
            }
            entries = ["accountName", "cryptoType", "address", "pubKey", "legacyAddress"]
            break
            
        case .sync2:
            if (components.count != 5) {
                throw EllipalMQRCodeInsertionError.paramLength(actual: components.count, expected: 5)
            }
            entries = ["walletRelease", "deviceId", "accountName",  "accountData", "indexBTCAddress"]
            break
            
        case .tosign:
            if (components.count != 5) {
                throw EllipalMQRCodeInsertionError.paramLength(actual: components.count, expected: 5)
            }
            entries = ["chainType", "address", "tx", "tokenSymbol", "decimal"]
            break
            
        case .signed:
            if (components.count != 3) {
                throw EllipalMQRCodeInsertionError.paramLength(actual: components.count, expected: 3)
            }
            entries = ["chainType", "address", "hexDataSigned"]
            break
            
        case .eosnamesync:
            if (components.count != 3) {
                throw EllipalMQRCodeInsertionError.paramLength(actual: components.count, expected: 3)
            }
            entries = ["accountOwner", "ownerKey", "activeKey"]
            break
            
        default:
            throw EllipalMQRCodeInsertionError.actionType(actionType: action)
        }
        
        for (index, entry) in entries.enumerated() {
            dictionary[entry] = components[index]
        }
        
        switch thisAction {
        case .sync2:
            let cryptoDataList = components[3].components(separatedBy: "]")
                .map({$0.components(separatedBy: "[")})
            dictionary["accountData"] = cryptoDataList
            break
            
        case .signed:
            dictionary["tx"] = components[2].replacingOccurrences(of: "_", with: "/")
            break
            
        default:
            break
        }
        self.dictionary = dictionary
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.total)
        hasher.combine(self.index)
        hasher.combine(self.action)
    }
    
    let version: String
    let total: Int
    let index: Int
    let action: String
    let components: [String]

    var dictionary: [String: Any]
}

enum ActionType: String {
    case sync = "sync"
    case sync2 = "sync2"
    case tosign = "tosign"
    case signed = "signed"
    case eosnamesync = "eosnamesync"
    case unknown = ""
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
        if initialQR.action != qr.action { return EllipalMQRCodeInsertionError.action(lhs: initialQR.action, rhs: qr.action)}

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
    case action(lhs: String, rhs: String)
    case actionType(actionType: String)
    case paramLength(actual: Int, expected: Int)
    
    var localizedDescription: String {
        switch self {
        case .total(let lhs, let rhs):
            return "Two Codes with different Total: \(lhs) vs \(rhs)"

        case .action(let lhs, let rhs):
            return "Two Codes with different Action: \(lhs) vs \(rhs)"

        case .actionType(let actionType):
            return "Invalid Action: \(actionType)"

        case .paramLength(let actual, let expected):
            return "Invalid parameter count: \(actual) vs \(expected)"
        }
    }
}
