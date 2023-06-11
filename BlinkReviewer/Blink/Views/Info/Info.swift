import SwiftUI
import Photos

/// Show some info about the asset.
struct Info: View {
    var asset: PHAsset
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "calendar")
                Text("\(asset.creationDate?.ISO8601Format() ?? "(unknown)")")
            }
                .font(.title)
                .padding(10)
                .foregroundColor(.white)
                .background(.black.opacity(0.7))
                .cornerRadius(7.0)
                .shadow(radius: 2.0)
                .textSelection(.enabled)
            
            HStack {
                Image(systemName: "doc")
                Text(asset.originalFilename())
            }
                .font(.title)
                .padding(10)
                .foregroundColor(.white)
                .background(.black.opacity(0.7))
                .cornerRadius(7.0)
                .shadow(radius: 2.0)
                .textSelection(.enabled)
            
        }
            
    }
}
