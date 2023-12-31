//
//  GameView.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 7/3/23.
//

import SwiftUI
import AVFoundation


struct GameView: View {
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var game: CleverJacksGame
    @State var justBroughtOn  : Bool = false
    let timer = Timer.publish(every: 12, tolerance: 0.5, on: .current, in: .common).autoconnect()
    var body: some View {
        

        GeometryReader {
            proxy in
            VStack {
                TopMenuView()
                Divider()
                AdaptiveStack(isItAVStack: proxy.size.width < proxy.size.height) {
                    
                    PlayerView(isItAVStack: proxy.size.width < proxy.size.height)
                    Divider()
                    Spacer()
                    BoardView(size : proxy.size.width < proxy.size.height ?
                              ( proxy.size.width <= proxy.size.height*0.3 ? proxy.size.width/8 : proxy.size.height/16.5 )
                              : proxy.size.height/12.5)
                    Group {
                        Spacer()
                        Spacer()
                        ResponseView(
                            size : proxy.size.width < proxy.size.height ?
                            ( proxy.size.width <= proxy.size.height*0.3 ? proxy.size.width/11 : proxy.size.height/20 )
                            : proxy.size.height/15,
                            isItAVStack:proxy.size.width > proxy.size.height )
                        Spacer()
                        Spacer()
                        PlayerCardsView(
                            size : proxy.size.width < proxy.size.height ? ( proxy.size.width <= proxy.size.height*0.3 ? proxy.size.width/8 : proxy.size.height/16.5 )
                            : proxy.size.height/12,
                            isItAVStack: proxy.size.width > proxy.size.height )
                        Spacer()
                        Text("")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }

        
        .confettiCannon(counter: $game.sequencesChanged, num: justBroughtOn ? 0 : 100, repetitions: game.myNoOfSequences, repetitionInterval: 0.7)
        .sheet(isPresented: $game.showMessages) {
            ChatView()
        }
        .padding()
        .onReceive(timer) { _ in
            if game.auto {
                timer.upstream.connect().cancel()
            }
            else {
                game.isLoading = true
                justBroughtOn = false
                
                if game.refreshedTime > 1 {
                    game.resetGame()
                }
                else {
                    game.refresh()
                }
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                justBroughtOn = true
            }
            if newPhase == .background {
                timer.upstream.connect().cancel()
                game.resetGame()
            }
        }
        .alert(
            Text("Congrats! You Won"),
            isPresented: $game.youWon ) {
                Button("Home", role: .destructive) {
                    withAnimation {
                        game.resetGame()
                    }
                }
                Button("Cancel", role: .cancel) {
                    
                }
            } message: {  Text("Game Over").fontDesign(.serif) }
        
            .alert(
                Text("Oops! You Lost"),
                isPresented: $game.youLost ) {
                    Button("Home", role: .destructive) {
                        withAnimation {
                            game.resetGame()
                        }
                    }
                    Button("Cancel", role: .cancel) {
                        
                    }
                } message: {  Text("Game Over").fontDesign(.serif) }
     }
}




struct GameViewPreviews: PreviewProvider {
    static var previews: some View {
        GameView()
            .environmentObject(CleverJacksGame())
    }
}



public extension View {
    
    /// renders configurable confetti animaiton
    ///
    /// - Usage:
    ///
    /// ```
    ///    import SwiftUI
    ///
    ///    struct ContentView: View {
    ///
    ///        @State private var counter: Int = 0
    ///
    ///        var body: some View {
    ///            Button("Wow") {
    ///                counter += 1
    ///            }
    ///            .confettiCannon(counter: $counter)
    ///        }
    ///    }
    /// ```
    ///
    /// - Parameters:
    ///   - counter: on any change of this variable the animation is run
    ///   - num: amount of confettis
    ///   - colors: list of colors that is applied to the default shapes
    ///   - confettiSize: size that confettis and emojis are scaled to
    ///   - rainHeight: vertical distance that confettis pass
    ///   - fadesOut: reduce opacity towards the end of the animation
    ///   - opacity: maximum opacity that is reached during the animation
    ///   - openingAngle: boundary that defines the opening angle in degrees
    ///   - closingAngle: boundary that defines the closing angle in degrees
    ///   - radius: explosion radius
    ///   - repetitions: number of repetitions of the explosion
    ///   - repetitionInterval: duration between the repetitions
    ///
    @ViewBuilder func confettiCannon(
        counter: Binding<Int>,
        num: Int = 20,
        confettis: [ConfettiType] = ConfettiType.allCases,
        colors: [Color] = [.blue, .red, .green, .yellow, .pink, .purple, .orange],
        confettiSize: CGFloat = 10.0,
        rainHeight: CGFloat = 600.0,
        fadesOut: Bool = true,
        opacity: Double = 1.0,
        openingAngle: Angle = .degrees(60),
        closingAngle: Angle = .degrees(120),
        radius: CGFloat = 300,
        repetitions: Int = 0,
        repetitionInterval: Double = 1.0
    ) -> some View {
        ZStack {
            self
            ConfettiCannon(
                counter: counter,
                num: num,
                confettis: confettis,
                colors: colors,
                confettiSize: confettiSize,
                rainHeight: rainHeight,
                fadesOut: fadesOut,
                opacity: opacity,
                openingAngle: openingAngle,
                closingAngle: closingAngle,
                radius: radius,
                repetitions: repetitions,
                repetitionInterval: repetitionInterval
            )
        }
    }
}
