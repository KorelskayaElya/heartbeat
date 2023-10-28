//
//  ContentView.swift
//  heartbeat
//
//  Created by Эля Корельская on 07.08.2023.
//

import SwiftUI
import AVFoundation

struct Heart: Identifiable {
    var id = UUID()
    var offset: CGSize
    var color: Color
    var rotation: Double = 0
    var scale: CGFloat = 1
    var speed: CGFloat
}

struct ContentView: View {
    @State private var audioPlayer: AVAudioPlayer?
    @State private var heartCount = 0
    @State private var smallHearts: [Heart] = []
    @State private var showResetButton = false
    @State private var isFirstHeartTap = true
    @State private var bigHeartIsVisible = true

    var body: some View {
        VStack {
            Text("Счетчик любви")
                .font(.title)
                .padding(.top, 20)
                .foregroundColor(.black)
                .padding(.bottom, 5)

            if bigHeartIsVisible {
                ZStack {
                    ForEach(smallHearts) { heart in
                        Image(systemName: "heart.fill")
                            .foregroundColor(heart.color)
                            .rotationEffect(.degrees(heart.rotation))
                            .scaleEffect(heart.scale)
                            .offset(heart.offset)
                    }
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .font(.system(size: heartCount > 0 ? CGFloat(120 + heartCount) : 120))
                        .onTapGesture {
                            if isFirstHeartTap {
                                showResetButton = true
                                isFirstHeartTap = false
                            }
                            heartCount += 1

                            if heartCount >= 300 {
                                bigHeartIsVisible = false
                                startSmallHeartsAnimation()
                            }
                            
                            if audioPlayer == nil {
                                setupAudioPlayer()
                            } else {
                                toggleAudioPlayer()
                            }
                        }
                }
                .padding(.top, 20)
                .frame(maxHeight: .infinity)
            }

            Spacer()

            HStack {
                Spacer()
                Text("\(heartCount)")
                    .font(.title)
                    .foregroundColor(.black)
                    .padding(.trailing, 20)
                    .background(
                        Capsule()
                            .foregroundColor(.white)
                            .padding(.trailing, 10)
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 2)
                    )
            }

            if showResetButton {
                Button(action: {
                    resetCounter()
                }) {
                    Text("Сбросить")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(10)
                }
                .padding(.bottom, 20)
            }
        }
    }

    private func setupAudioPlayer() {
        if let soundURL = Bundle.main.url(forResource: "heartbeat-01a", withExtension: "mp3") {
            print("Sound URL:", soundURL)  // Add this line
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.numberOfLoops = -1  // Loop indefinitely
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
            } catch {
                print("Error loading audio file: \(error)")
            }
        }
    }
    
    private func toggleAudioPlayer() {
        if let player = audioPlayer {
            if player.isPlaying {
                player.pause()
            } else {
                player.play()
            }
        }
    }

    private func resetCounter() {
        heartCount = 0
        smallHearts.removeAll()
        showResetButton = false
        isFirstHeartTap = true
        bigHeartIsVisible = true
    }

    private func startSmallHeartsAnimation() {
        DispatchQueue.global(qos: .userInteractive).async {
            for _ in 0..<5000 {
                DispatchQueue.main.async {
                    let newHeart = Heart(offset: CGSize(width: CGFloat.random(in: -200...200), height: CGFloat.random(in: -200...200)),
                                         color: Color.random(),
                                         rotation: Double.random(in: 0...360),
                                         scale: CGFloat.random(in: 0.5...1),
                                         speed: CGFloat.random(in: 1.5...3))
                    smallHearts.append(newHeart)
                }
                Thread.sleep(forTimeInterval: 0.02)
            }
            DispatchQueue.main.async {
                stopSmallHeartsAnimation()
            }
        }
    }

    private func stopSmallHeartsAnimation() {
        smallHearts.removeAll()
        bigHeartIsVisible = true
    }
}

extension Color {
    static func random() -> Color {
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}

