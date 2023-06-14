import OrderedCollections

/// This implements a very basic LRU (least-recently used) cache.
///
/// The cache has a maximum size, and objects get evicted when the cache grows
/// too large.  This is primarily used to cache images, and avoid the memory
/// footprint of the application growing forever.
struct LRUCache<Key: Hashable, Value> {
    private var contents: Dictionary<Key, Value>
    private var keyHistory: OrderedSet<Key>
    
    var maxSize: Int
    
    init(withMaxSize maxSize: Int) {
        self.maxSize = maxSize
        
        self.contents = Dictionary()
        self.keyHistory = OrderedSet()
    }
    
    subscript(key: Key) -> Value? {
        get {
            contents[key]
        }
        
        set {
            contents[key] = newValue
            
            // Move the key to the beginning of the key history
            keyHistory.remove(key)
            keyHistory.insert(key, at: 0)
            
            assert(contents.count == keyHistory.count)
            
            while contents.count > self.maxSize {
                let lastKey = keyHistory.last!
                
                contents.removeValue(forKey: lastKey)
                keyHistory.remove(lastKey)
            }
        }
    }
}
