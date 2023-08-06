//
//  TutorialArrowView.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 7/23/23.
//

import SwiftUI

struct TutorialArrowView: View {
    var show = false
    @State var size: CGFloat = 1.8
    var arrow : ArrowImages = .down
    var yAxis = false
    var repeatingAnimation: Animation {
        Animation
            .easeInOut(duration: 2) //.easeIn, .easyOut, .linear, etc...
            .repeatForever()
    }
    var body: some View {
        arrow.image
            .opacity(show ? 0.4 : 0)
            .scaleEffect(show ? size : 1)
            .offset(x: show && !yAxis ? -20 : 0, y: show && yAxis ? 20 : 100)
            .opacity(show ? 1 : 0)
            .animation(self.repeatingAnimation, value: show)
            .rotation3DEffect(
                .degrees(0), axis: (x: 0.0, y: 1.0, z: 100.0)
            )

    }
}

enum ArrowImages {
    
    case up, down, left, right
    
    var image : Image {
        switch(self) {
        case .up : Image(systemName: "arrow.up")
        case .down : Image(systemName: "arrow.down")
        case .left : Image(systemName: "arrow.left")
        case .right : Image(systemName: "arrow.right")
        }
    }
}

#Preview {
    TutorialArrowView(show: true)
}
