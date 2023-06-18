//
//  ReviewState.swift
//  BlinkReviewer
//
//  Created by Alex Chan on 08/06/2023.
//

import Foundation
import SwiftUI

enum ReviewState {
    case Approved
    case Rejected
    case NeedsAction
    
    func color() -> Color {
        switch(self) {
            case .Approved:
                return .green
            
            case .Rejected:
                return .red
            
            case .NeedsAction:
                return .blue
        }
    }
    
    func icon() -> Image {
        switch(self) {
            case .Approved:
                return Image(systemName: "checkmark.circle.fill")
            case .Rejected:
                return Image(systemName: "trash.circle.fill")
            case .NeedsAction:
                return Image(systemName: "info.circle.fill")
        }
    }
}

