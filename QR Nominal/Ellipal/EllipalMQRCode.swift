// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import AnyCodable

class EllipalMQRCode: Codable, Hashable {
    static func == (lhs: EllipalMQRCode, rhs: EllipalMQRCode) -> Bool {
        return lhs.action == rhs.action && lhs.index == rhs.index && lhs.total == rhs.total
    }

    init(version: String, index: Int, total: Int, action: String, components: [String]) {
        self.version = version
        self.index = index
        self.total = total
        self.action = action
        self.components = components

        self.dictionary = [String: AnyCodable]()
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

    var dictionary: [String: AnyCodable]
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
        let thisAction = ActionType(rawValue: qr.action) ?? ActionType.unknown
        var entries: [Int: String]
        var dictionary: [String: AnyCodable] = ["version": AnyCodable(qr.version), "action": AnyCodable(qr.action)]
        switch thisAction {
        case .sync:
            if (qr.components.count < 5 || qr.components.count > 6) {
                return EllipalMQRCodeInsertionError.paramLength(actual:qr.components.count, expected: 5)
            }
            entries = [1: "accountName", 2: "cryptoType", 3: "address", 4: "pubKey", 5: "legacyAddress"]
            break

        case .sync2:
            if (qr.components.count != 6) {
                return EllipalMQRCodeInsertionError.paramLength(actual:qr.components.count, expected: 6)
            }
            entries = [1: "walletRelease", 2: "deviceId", 3: "accountName",  4: "accountData", 5: "indexBTCAddress"]
            break

        case .tosign:
            if (qr.components.count != 6) {
                return EllipalMQRCodeInsertionError.paramLength(actual:qr.components.count, expected: 6)
            }
            entries = [1: "chainType", 2: "address", 3: "tx", 4: "tokenSymbol", 5: "decimal"]
            break

        case .signed:
            if (qr.components.count != 4) {
                return EllipalMQRCodeInsertionError.paramLength(actual:qr.components.count, expected: 4)
            }
            entries = [1: "chainType", 2: "address", 3: "hexDataSigned"]
            break

        case .eosnamesync:
            if (qr.components.count != 4) {
                return EllipalMQRCodeInsertionError.paramLength(actual:qr.components.count, expected: 4)
            }
            entries = [1: "accountOwner", 2: "ownerKey", 3: "activeKey"]
            break

        default:
            return EllipalMQRCodeInsertionError.actionType(actionType: qr.action)
        }
        for (_, entry) in entries.enumerated() {
            dictionary[entry.value] = AnyCodable(qr.components[entry.key])
        }
        switch thisAction {
        case .sync2:
            let data = qr.components[4].components(separatedBy: "]")
            var params = [AnyCodable]()
            for (_, entry) in data.enumerated() {
                params.append(AnyCodable(entry.components(separatedBy: "[")))
            }
            dictionary["accountData"] = AnyCodable(params)
            break

        case .signed:
            dictionary["tx"] = AnyCodable(qr.components[3].replacingOccurrences(of: "_", with: "/"))
            break

        default:
            break
        }
        qr.dictionary = dictionary
        print(dictionary)

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
        case .total(let lhs, let rhs): return "Two Codes with different Total: \(lhs) vs \(rhs)"
        case .action(let lhs, let rhs): return "Two Codes with different Action: \(lhs) vs \(rhs)"
        case .actionType(let actionType): return "Invalid Action: \(actionType)"
        case .paramLength(let actual, let expected): return "Invalid parameter count: \(actual) vs \(expected)"
        }
    }
}
