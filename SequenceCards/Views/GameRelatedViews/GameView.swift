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

    @ObservedObject var game: CleverJacksGame
    @State var justBroughtOn  : Bool = false
    let timer = Timer.publish(every: 20, on: .current, in: .common).autoconnect()
    var body: some View {
        
        ZStack {
            VStack {
                TopMenuView(game: game)
        
                Divider()
                PlayerView(game: game)
                Divider()
                GeometryReader {
                    proxy in
                        AdaptiveStack(isItAVStack: proxy.size.width < proxy.size.height) {
                            Spacer()
                            BoardView(game: game,
                                      size : CGSize(width: min(proxy.size.width/12.5,proxy.size.height/14) , height: max(proxy.size.height/14, proxy.size.width/20)))
                            Spacer()
                            Spacer()
//                            if game.youWon == game.youLost {
                            ResponseView(game:game,
                                         proxy:proxy, isItAVStack:proxy.size.width > proxy.size.height )
                            
                                    
                            Spacer()
                            Spacer()
                                PlayerCardsView(game: game,
                                                size : CGSize(width: min(proxy.size.width/12.5,proxy.size.height/14) , height: max(proxy.size.height/14, proxy.size.width/20)),
                                                isItAVStack: proxy.size.width > proxy.size.height )
                                
//                            }
//                            else {
//                                GameOverAlert(game: game, size: proxy.size)
//                                    .transition(.scale)
//                            }
                            Spacer()
                            
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }


        }

        .confettiCannon(counter: $game.sequencesChanged, num: justBroughtOn ? 0 : 100, repetitions: game.myNoOfSequences, repetitionInterval: 0.7)
        .sheet(isPresented: $game.showMessages) {
            ChatView(game: game)
        }
        .padding()
        .onReceive(timer) { _ in
            game.isLoading = true
            justBroughtOn = false
                Task {
                    await game.refresh()
                }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                justBroughtOn = true
                game.isLoading = true
                Task {
                    await game.refresh()
                }
            }
            if newPhase == .background {
                justBroughtOn = false
            }
        }
        .alert( isPresented: $game.youWon) {
            Alert(
                title: Text("Congrats! You Won"),
                message: Text("Game Over").fontDesign(.serif),
                primaryButton: .default(Text("Home")) {
                    Task {
                        game.resetGame()
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .alert(isPresented: $game.youLost) {
            Alert(
                title: Text("Oops! You Lost"),
                message: Text("Game Over").fontDesign(.serif),
                primaryButton: .default(Text("Home")) {
                    Task {
                        game.resetGame()
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
}




struct GameViewPreviews: PreviewProvider {
    static var previews: some View {
        GameView(game: CleverJacksGame())
        GameView(game:CleverJacksGame())
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
