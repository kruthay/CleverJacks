//
//  AdaptiveStack.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 7/15/23.
//

import SwiftUI

struct AdaptiveStack<Content: View>: View {
    let isItAVStack : Bool
    let content: () -> Content
    init(isItAVStack : Bool, @ViewBuilder content: @escaping () -> Content) {
        self.isItAVStack = isItAVStack
        self.content = content
        }
    var body: some View {
        Group {
            if isItAVStack {
                VStack(content: content)
            } else {
                HStack(content: content)
            }
        }
    }
}
