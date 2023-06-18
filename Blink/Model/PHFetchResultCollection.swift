import Photos
import SwiftUI

/// Implement a RandomAccessCollection for a PHFetchResult.
///
/// This wrapper allows us to use a PHFetchResult in a SwiftUI ForEach loop,
/// for example:
///
/// ```swift
/// let fetchResult = PHAsset.fetchAssets(…)
/// let collection = PHFetchResultCollection(fetchResult: fetchResult)
///
/// var body: some View  {
///     ForEach(collection, id: \.localIdentifier) {
///         ...
///     }
/// }
/// ```
///
/// This collection vends the IndexedPHAsset struct, which tells us both
/// what asset we're on and where we are -- this is necessary for performance
/// reasons.  See the comment above the ForEach in PHAssetHStack.
///
/// This is based on code written by Slava Semeniuk on Stack Overflow:
/// https://stackoverflow.com/q/62745595/1558022

struct IndexedPHAsset {
    var position: Int
    var asset: PHAsset
}

struct PHFetchResultCollection: RandomAccessCollection, Equatable {
    typealias Element = IndexedPHAsset
    typealias Index = Int

    let fetchResult: PHFetchResult<PHAsset>

    init(_ fetchResult: PHFetchResult<PHAsset>) {
        self.fetchResult = fetchResult
    }
    
    var startIndex: Int { 0 }
    var endIndex: Int { fetchResult.count }

    subscript(position: Int) -> IndexedPHAsset {
        IndexedPHAsset(
            position: position,
            asset: fetchResult.object(at: position)
        )
    }
}

struct PHFetchResultCollection_Previews: PreviewProvider {
    static var resultCollection: PHFetchResultCollection {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.fetchLimit = 3
        
        let fetchResult: PHFetchResult<PHAsset> = PHAsset.fetchAssets(with: options)
        
        return PHFetchResultCollection(fetchResult)
    }
    
    static var previews: some View {
        VStack {
            Text("These dates should be in descending order:")
            
            ForEach(self.resultCollection, id: \.asset.localIdentifier) { indexedAsset in
                Text("\(indexedAsset.asset.creationDate?.ISO8601Format() ?? "(unknown)")")
            }
        }
    }
}
