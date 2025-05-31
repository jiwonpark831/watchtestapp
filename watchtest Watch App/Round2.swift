//
//  Round2.swift
//  watchtest Watch App
//
//  Created by jiwon on 5/31/25.
//

import AVFoundation
import CoreMotion
import SwiftUI
import WatchKit

struct Round2: View {

    @StateObject private var speechCoordinator = SpeechCoordinator()

    let round2 = [
        "회사 사장 되기 vs 1000만 유튜버 되기", "평생 라면 안먹기 vs 평생 탄산 안먹기",
        "개구리 맛 초콜릿 vs 초콜릿 맛 개구리", "평생 여름 vs 평생 겨울",
        "과거로 돌아가기 vs 미래로 돌아가기",
    ]
    @State private var round2Index = 0
    @State private var motionManager = CMMotionManager()
    @State private var middle: Double = 0.0
    @State private var timer: Timer?
    @State private var time = 10
    @State private var isAnswered = false
    @State private var shouldStartAfterSpeech = false
    @State private var choice = ""

    let synthesizer = AVSpeechSynthesizer()

    var body: some View {

        VStack {
            Text("\(round2[round2Index])").onChange(of: round2Index) { _ in
                startRound2()
            }
            if round2Index == 4 && isAnswered {
                NavigationLink("Round3로", destination: Round3())
            }
        }.onAppear {
            speechCoordinator.didFinishSpeaking = {
                if shouldStartAfterSpeech {
                    startTimer(round2Index)
                    chooseByMotion(round2Index)
                    shouldStartAfterSpeech = false
                }
            }
            startRound2()
        }
    }

    func startRound2() {
        isAnswered = false
        time = 10
        timer?.invalidate()
        motionManager.stopDeviceMotionUpdates()
        choice = ""

        speechCoordinator.speak(round2[round2Index])
        shouldStartAfterSpeech = true
    }

    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR")
        synthesizer.speak(utterance)
    }

    func speak(_ time: Int) {
        speak("\(time)")
    }

    func startTimer(_ index: Int) {
        timer = Timer.scheduledTimer(
            withTimeInterval: 1, repeats: true
        ) { _ in
            if time > 0 {
                time -= 1
                WKInterfaceDevice.current().play(.start)
            } else {
                timer?.invalidate()
                print("종료")

            }
        }
    }

    func chooseByMotion(_ index: Int) {
        var degree: Double = 1.0

        guard motionManager.isDeviceMotionAvailable else {
            print("unavailable")

            return
        }

        middle = 0.0
        motionManager.deviceMotionUpdateInterval = 0.1

        motionManager.startDeviceMotionUpdates(to: .main) {
            (deviceMotion: CMDeviceMotion?, error: Error?) in
            guard let data = deviceMotion, error == nil else {
                print(
                    "Failed to get device motion data: \(error?.localizedDescription ?? "Unknown error")"
                )
                return
            }

            let roll = data.attitude.roll
            let value = roll - self.middle
            if isAnswered == false {
                if value > degree {
                    choice = "2번"
                    isAnswered = true
                } else if value < -degree {
                    choice = "1번"
                    isAnswered = true
                }
                if isAnswered {
                    speechCoordinator.speak(choice)
                    timer?.invalidate()
                    motionManager.stopDeviceMotionUpdates()
                    if round2Index != 4 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            round2Index += 1
                        }
                    }
                }
            }
        }

    }

}

#Preview {
    Round2()
}
