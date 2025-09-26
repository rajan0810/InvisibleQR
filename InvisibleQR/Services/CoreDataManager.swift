import CoreData
import Foundation

class CoreDataManager: ObservableObject {
    static let shared = CoreDataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "InvisibleQR")
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Core Data error: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Save error: \(error)")
            }
        }
    }
    
    func hideMessage(_ content: String, fingerprint: String, locationHint: String? = nil) {
        let message = NSEntityDescription.entity(forEntityName: "HiddenMessage", in: context)!
        let newMessage = NSManagedObject(entity: message, insertInto: context)
        
        newMessage.setValue(UUID(), forKey: "id")
        newMessage.setValue(fingerprint, forKey: "fingerprint")
        newMessage.setValue(CryptoService.encrypt(content), forKey: "encryptedContent")
        newMessage.setValue(Date(), forKey: "timestamp")
        newMessage.setValue(locationHint, forKey: "locationHint")
        newMessage.setValue(false, forKey: "isRevealed")
        
        save()
        print("Message hidden with fingerprint: \(fingerprint.prefix(8))...")
    }
    
    func findMessage(by fingerprint: String) -> NSManagedObject? {
        let request = NSFetchRequest<NSManagedObject>(entityName: "HiddenMessage")
        request.predicate = NSPredicate(format: "fingerprint == %@ AND isRevealed == false", fingerprint)
        request.fetchLimit = 1
        
        do {
            let messages = try context.fetch(request)
            if let message = messages.first {
                print("Found message for fingerprint: \(fingerprint.prefix(8))...")
                return message
            }
        } catch {
            print("Fetch error: \(error)")
        }
        
        return nil
    }
    
    func getAllHiddenMessages() -> [NSManagedObject] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "HiddenMessage")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \NSManagedObject.timestamp, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Fetch all error: \(error)")
            return []
        }
    }
}
