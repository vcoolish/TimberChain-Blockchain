import Foundation
import Vapor

let DIFFICULTY = "000"

class Transaction :Codable {
    
    var status :Int
    var amount :Double
    var uuid: String
    var location: String
    
    init(status :Int, amount :Double, uuid :String, location :String) {
        self.status = status
        self.amount = amount
        self.uuid = uuid
        self.location = location
    }
    
    init?(request :Request) {
        
        guard let status = request.data["status"]?.int,
            let amount = request.data["amount"]?.double,
            let uuid = request.data["uuid"]?.string,
            let location = request.data["location"]?.string
            else {
                return nil
        }
    
        self.status = status
        self.amount = amount
        self.uuid = uuid
        self.location = location
    }
}


//class RecordSmartContract : Codable {
//
//    func apply(transaction :Transaction, allBlocks :[Block]) {
//
//        allBlocks.forEach { block in
//
//            block.transactions.forEach { trans in
//
//                if trans.uuid == transaction.uuid {
//                    transaction.amount -= trans.amount
//                }
//
//                if transaction.noOfVoilations > 5 {
//                    transaction.isDrivingLicenseSuspended = true
//                }
//
//            }
//        }
//    }
//
//}

class Block : Codable {
    
    var index :Int = 0
    var dateCreated :String
    var previousHash :String!
    var hash :String!
    var nonce :Int
    var message :String = ""
    private (set) var transactions :[Transaction] = [Transaction]()
    
    var key :String {
        get {
            
            let transactionsData = try! JSONEncoder().encode(self.transactions)
            let transactionsJSONString = String(data: transactionsData, encoding: .utf8)
            
            return String(self.index) + self.dateCreated + self.previousHash + transactionsJSONString! + String(self.nonce)
        }
    }
    
    func addTransaction(transaction :Transaction) {
        self.transactions.append(transaction)
    }
    
    init() {
        self.dateCreated = Date().toString()
        self.nonce = 0
        self.message = "Новый блок намайнен"
    }
    
    init(transaction :Transaction) {
        
        self.dateCreated = Date().toString()
        self.nonce = 0
        self.addTransaction(transaction: transaction)
        
    }
    
}

class BlockchainNode :Codable {
    
    var address :String
    
    init(address :String) {
        self.address = address
    }
    
    init?(request :Request) {
        
        guard let address = request.data["address"]?.string else {
            return nil
        }
        
        self.address = address
    }
    
}

class Status :Codable {
    
    var status :Int
    
    init(status :Int) {
        self.status = status
    }
    
    init?(request :Request) {
        
        guard let status = request.data["status"]?.int else {
            return nil
        }
        
        self.status = status
    }
    
}

class Blockchain : Codable {
    
    var blocks :[Block] = [Block]()
    var nodes :[BlockchainNode] = [BlockchainNode]()
    
    private enum CodingKeys :String, CodingKey {
        case blocks
    }
    
    init() {
        
    }
    
    init(_ genesisBlock :Block) {
        
        self.addBlock(genesisBlock)
    }
    
    func addNode(_ blockchainNode :BlockchainNode) {
        self.nodes.append(blockchainNode)
    }
    
    func addBlock(_ block :Block) {
        
        if self.blocks.isEmpty {
            block.previousHash = "0"
            
        } else {
            let previousBlock = getPreviousBlock()
            block.previousHash = previousBlock.hash
            block.index = self.blocks.count
        }
        
        block.hash = generateHash(for: block)
        self.blocks.append(block)
        block.message = "Блок добавлен"
    }
    
    private func getPreviousBlock() -> Block {
        return self.blocks[self.blocks.count - 1]
    }
    
    private func displayBlock(_ block :Block) {
        print("------ Блок \(block.index) ---------")
        print("Дата создания : \(block.dateCreated) ")
        //print("Data : \(block.data) ")
        print("Nonce : \(block.nonce) ")
        print("Предидущий хеш : \(block.previousHash!) ")
        print("Хеш : \(block.hash!) ")
    }
    
    private func generateHash(for block: Block) -> String {
        
        var hash = block.key.sha256()!
        
        while(!hash.hasPrefix(DIFFICULTY)) {
            block.nonce += 1
            hash = block.key.sha256()!
            print(hash)
        }
        
        return hash
    }
    
    func transactionsBy(status :Int) -> [Transaction] {
        
        var transactions = [Transaction]()
        
        self.blocks.forEach { block in
            
            for transaction in block.transactions {
                if transaction.status == status {
                    transactions.append(transaction)
                }
                if transaction.status > status{
                    transactions.removeLast()
                    break
                }
            }
        }
        return transactions
    }
}


