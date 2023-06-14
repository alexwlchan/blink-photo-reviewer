// This provides random access to a list of LocalIdentifiers, which allows
// the list to be used in a ForEach view.
//
// The entries provided to the body of the ForEach include both the index
// within the list and the local identifier itself.
struct RandomAccessLocalIdentifiers: RandomAccessCollection {
    typealias Element = (Int, String)
    typealias Index = Int

    let assetIdentifiers: [String]

    init(_ assetIdentifiers: [String]) {
        self.assetIdentifiers = assetIdentifiers
    }
    
    var startIndex: Int { 0 }
    var endIndex: Int { assetIdentifiers.count }

    subscript(position: Int) -> (Int, String) {
        (position, assetIdentifiers[position])
    }
}
