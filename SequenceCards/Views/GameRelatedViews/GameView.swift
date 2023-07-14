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
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var game: CleverJacksGame
    let timer = Timer.publish(every: 6, on: .current, in: .common).autoconnect()
    @State var counter = 20
    var body: some View {
        
        ZStack(alignment: .bottom ) {
            
            VStack {
                HStack {
                    Button("Back") {
                        withAnimation {
                            game.quitGame()
                        }
                    }
                    .hoverEffect(.lift)
                    Spacer()
                    Button {
                        game.isLoading = true
                        Task {
                            await game.refresh()
                        }
                    } label: {
                        Text(Image(systemName: "arrow.clockwise"))
                    }
                    
                    if game.isLoading {
                        ProgressView()
                    }
                    Spacer()
                    Button("Forfeit", role: .destructive) {
                        Task {
                            await game.forfeitMatch()
                        }
                    }
                    .hoverEffect(.lift)
                }
                .padding(.horizontal)
                Divider()
                HStack  {
                    Spacer()
                    HStack {
                        game.myAvatar
                            .resizable()
                            .frame(width: 25.0, height: 25)
                            .clipShape(Circle())
                            .wiggling(toWiggle: game.myTurn)
                        if game.board?.numberOfPlayers == 2 {
                            Text(game.myName == "" ? "SomeName" : game.myName)
                                .lineLimit(2)
                                .font(.caption)
                        }
                        Text(String(game.myNoOfSequences))
                    }
                    .padding(4.5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(game.myCoin?.color ?? .blue, lineWidth: 2)
                    )
                    .opacity(game.myTurn ? 1 : 0.5)
                    Spacer()
                    HStack {
                        game.opponentAvatar
                            .resizable()
                            .frame(width: 25, height: 25)
                            .clipShape(Circle())
                            .wiggling(toWiggle: game.whichPlayersTurn == game.opponent?.player )
                        if game.board?.numberOfPlayers == 2 {
                            Text(game.opponentName)
                                .lineLimit(2)
                                .font(.caption)
                        }
                        Text(String(game.opponentNoOfSequences))
                    }
                    .padding(4.5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(game.opponentCoin?.color ?? .green, lineWidth: 2)
                    )
                    .opacity(game.whichPlayersTurn == game.opponent?.player ? 1 : 0.5)
                    Spacer()
                    if game.board?.numberOfPlayers ?? 0 > 2 {
                        HStack {
                            game.opponent2Avatar
                                .resizable()
                                .frame(width: 25, height: 25)
                                .clipShape(Circle())
                                .wiggling(toWiggle: game.whichPlayersTurn == game.opponent2?.player )
                            Text(String(game.opponent2NoOfSequences))
                        }
                        .padding(4.5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(game.opponent2Coin?.color ?? .red, lineWidth: 2)
                        )
                        .opacity(game.whichPlayersTurn == game.opponent2?.player ? 1 : 0.5)
                        Spacer()
                    }
                }
                Divider()
                GeometryReader {
                    proxy in
                    if proxy.size.width > proxy.size.height {
                        HStack {
                            Spacer()
                            BoardView(game: game, size : CGSize(width: proxy.size.height/12.5, height: proxy.size.width/20))
                            Spacer()
                            VStack{
                                ResponseView(game:game, proxy:proxy)
                                    .opacity(game.inSelectionCard != nil ? 1 : 0.6)
                            }
                            Spacer()
                            PlayerCardsView(game: game, size : CGSize(width: proxy.size.height/12.5, height: proxy.size.width/20), horizontalView: true)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    else{
                        VStack {
                            BoardView(game: game, size : CGSize(width: proxy.size.width/12.5, height: proxy.size.height/14))
                            Spacer()
                            HStack {
                                ResponseView(game: game, proxy: proxy)
                                    .opacity(game.inSelectionCard != nil ? 1 : 0.6)
                            }
                            Spacer()
                            PlayerCardsView(game: game, size : CGSize(width: proxy.size.width/12.5, height: proxy.size.height/14))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            .confettiCannon(counter: $game.myNoOfSequences, colors: [.red, .black], confettiSize: 20)
            .opacity(game.youWon || game.youLost ? 0.5 : 1)
            
            if game.youWon || game.youLost {
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(style: StrokeStyle(lineWidth: 0.1))
                        .background(colorScheme == .dark ? .black.opacity(0.9) : .white.opacity(0.9))
                    VStack {
                        Spacer()
                        if game.youWon {
                            Text("Congrats! You Won")
                                .font(.title)
                                .frame(height: 50)
                                .layoutPriority(2)
                        }
                        else {
                            Text("Oops! You Lost")
                                .font(.title)
                                .frame(height: 50)
                                .layoutPriority(2)
                        }

                       
                        Spacer()
                        Divider()
                        HStack {
Spacer()
                            Button("Leave", role: .cancel) {
                                withAnimation {
                                    game.quitGame()
                                }
                            }
                            .buttonStyle(.bordered)
                           Spacer()

                            Button("Done", role: .cancel) {
                                withAnimation {
                                game.quitGame()
                                }
                            }
                            .buttonStyle(.bordered)
                            Spacer()


                        }

                        
                    }
                }
                .layoutPriority(1)
                .frame(width: nil, height: 100, alignment: .bottom)
                .transition(.move(edge: .bottom))
            }
            
            
        }
        
        
        
        .padding()
        .onReceive(timer) { _ in
            game.isLoading = true
            if scenePhase == .active {
                Task {
                    await game.refresh()
                }
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                game.isLoading = true
                Task {
                    await game.refresh()
                }
            }
        }
        
        
        
        //        .alert("Game Over", isPresented: $game.youWon, actions: {
        //            Button("OK", role: .cancel) {
        //                game.resetGame()
        //            }
        //        }, message: {
        //            Text("Hurray! You win.")
        //        })
        //        .alert("Game Over", isPresented: $game.youLost, actions: {
        //            Button("OK", role: .cancel) {
        //                game.resetGame()
        //            }
        //        }, message: {
        //            Text("Oh No! You lose.")
        //        })
    }
}




struct GameViewPreviews: PreviewProvider {
    static var previews: some View {
        GameView(game: CleverJacksGame())
    }
}

//
//  View+ConfettiCannon.swift
//
//
//  Created by Abdullah Alhaider on 24/03/2022.



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
