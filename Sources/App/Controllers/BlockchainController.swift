import Foundation
import Vapor

class BlockchainController {
    
    private (set) var drop :Droplet
    private (set) var blockchainService :BlockchainService!
    
    init(drop :Droplet) {
        
        self.drop = drop
        self.blockchainService = BlockchainService() 
        
        setupRoutes()
    }
    
    private func setupRoutes() {
        
        self.drop.get("nodes") { request in
            
            return try JSONEncoder().encode(self.blockchainService.getNodes())
        }
    
        
        self.drop.get("nodes/resolve") { request in
            
            return try Response.async { portal in
                
                self.blockchainService.resolve { blockchain in
                    let blockchain = try! JSONEncoder().encode(blockchain)
                    portal.close(with: blockchain.makeResponse())
                }
            }
           
        }
        
        self.drop.post("nodes/register") { request in
            
            guard let blockchainNode = BlockchainNode(request :request) else {
                return try JSONEncoder().encode(["message":"Error registering node"])
            }
            
            self.blockchainService.registerNode(blockchainNode)
            return try JSONEncoder().encode(blockchainNode)
        }
        
        self.drop.get("mine") { request in
            
            let block = Block()
            self.blockchainService.addBlock(block)
            return try JSONEncoder().encode(block)
            
        }
        
        self.drop.post("transaction") { request in
            
            if let transaction = Transaction(request: request) {
                let block = self.blockchainService.getLastBlock()
                block.addTransaction(transaction: transaction)
                
                //let block = Block(transaction: transaction)
                //self.blockchainService.addBlock(block)
                return try JSONEncoder().encode(block)
            }
            return try JSONEncoder().encode(["message":"Something bad happend!"])
        }
        
        self.drop.post("timber-records") { request in
            
            if let status = Status(request: request) {
                let blockchain = self.blockchainService.getBlockchain()
                let transactions = blockchain?.transactionsBy(status: status.status)
                return try JSONEncoder().encode(transactions)
            }
            return try JSONEncoder().encode(["message":"Something bad happend!"])
            
        }
        
        self.drop.get("/timber-records/:status") { request in
            
            guard let status = request.parameters["status"]?.int else {
                return try JSONEncoder().encode(["message":"Timber parameter not found!"])
            }
            
            let blockchain = self.blockchainService.getBlockchain()
            let transactions = blockchain?.transactionsBy(status: status)
            return Response(
                status: .ok,
                headers: ["Content-Type": "application/json"],
                body: try JSONEncoder().encode(transactions)
            )
        }
        
        self.drop.get("blockchain") { request in
            
            if let blockchain = self.blockchainService.getBlockchain() {
                return try JSONEncoder().encode(blockchain)
            }
            
            return try! JSONEncoder().encode(["message":"Blockchain is not initialized. Please mine a block"])
        }
    }
}
