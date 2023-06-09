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
///
/// This is based on code written by Slava Semeniuk on Stack Overflow:
/// https://stackoverflow.com/q/62745595/1558022
///
struct PHFetchResultCollection: RandomAccessCollection, Equatable {
    typealias Element = PHAsset
    typealias Index = Int

    let fetchResult: PHFetchResult<PHAsset>

    var startIndex: Int { 0 }
    var endIndex: Int { fetchResult.count }

    subscript(position: Int) -> PHAsset {
        fetchResult.object(at: position)
    }
}

struct PHFetchResultCollection_Previews: PreviewProvider {
    static var resultCollection: PHFetchResultCollection {
        let options = PHFetchOptions()
        options.fetchLimit = 3
        
        let fetchResult: PHFetchResult<PHAsset> = PHAsset.fetchAssets(with: options)
        
        return PHFetchResultCollection(fetchResult: fetchResult)
    }
    
    static var previews: some View {
        VStack {
            ForEach(self.resultCollection, id: \.localIdentifier) { asset in
                Text("\(asset.localIdentifier)")
            }
        }
    }
}
