//
//  Round3.swift
//  watchtest Watch App
//
//  Created by jiwon on 5/31/25.
//

import AVFoundation
import CoreMotion
import SwiftUI
import WatchKit

struct Round3: View {

    @StateObject private var speechCoordinator = SpeechCoordinator()

    let round3 = [
        "예전에 바람핀 전여친 vs 분노 조절 장애 생존자",
        "중2병 걸린 생존자 vs 자존심 강한 리더", "사람을 죽인 적 있는 생존자 vs 거짓말이 습관인 생존자",
        "차별이 심한 생존자 vs 손해보는 일을 안하는 생존자", "상대가 편한 꼴을 못보는 생존자 vs 눈치가 너무 없는 생존자",
    ]
    @State private var round3Index = 0
    @State private var motionManager = CMMotionManager()
    @State private var middle: Double = 0.0
    @State private var timer: Timer?
    @State private var time = 10
    @State private var isAnswered = false
    @State private var shouldStartAfterSpeech = false
    @State private var choice = ""
    @State private var intro = false
    let message = "어느날 온 세상에 좀비 바이러스가 퍼졌습니다. 이때 가장 같이 있기 싫은 생존자와 생존자 그룹을 골라보세요."

    let synthesizer = AVSpeechSynthesizer()

    var body: some View {

        VStack {
            Text("\(round3[round3Index])").onChange(of: round3Index) { _ in
                startRound3()
            }
            if round3Index == 4 && isAnswered {
                NavigationLink("게임 완료!", destination: End())
            }
        }.onAppear {
            speechCoordinator.didFinishSpeaking = {
                if intro == false {
                    intro = true
                    startRound3()
                } else if shouldStartAfterSpeech {
                    startTimer(round3Index)
                    chooseByMotion(round3Index)
                    shouldStartAfterSpeech = false
                }
            }
            speechCoordinator.speak(message)
        }
    }

    func startRound3() {
        isAnswered = false
        time = 10
        timer?.invalidate()
        motionManager.stopDeviceMotionUpdates()
        choice = ""

        speechCoordinator.speak(round3[round3Index])
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
                    if round3Index != 4 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            round3Index += 1
                        }
                    }
                }
            }
        }

    }

}

#Preview {
    Round3()
}
