//
//  LogoAndNameView.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 7/14/23.
//

import SwiftUI

struct LogoAndNameView: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        HStack {
            Image(colorScheme == .dark ? "SequenceLogo Dark" : "SequenceLogo")
                .resizable()
                .frame(width: 80, height: 80)
            Text("Clever Jacks")
                .fontDesign(.serif)
                .font(.largeTitle)
                .fontWeight(.bold)
        }
    }
}

struct LogoAndNameViewPreviews: PreviewProvider {
    static var previews: some View {
        LogoAndNameView()
    }
}
