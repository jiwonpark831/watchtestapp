//
//  ContentView.swift
//  watchtest Watch App
//
//  Created by jiwon on 5/30/25.
//

import AVFoundation
import CoreMotion
import SwiftUI
import WatchKit

class SpeechCoordinator: NSObject, ObservableObject, AVSpeechSynthesizerDelegate
{  // 지피티가 짜준 코드..
    let synthesizer = AVSpeechSynthesizer()
    var didFinishSpeaking: (() -> Void)?

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR")
        synthesizer.speak(utterance)
    }

    func speak(_ time: Int) {
        speak("\(time)")
    }

    func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didFinish utterance: AVSpeechUtterance
    ) {
        didFinishSpeaking?()
    }
}

struct ContentView: View {

    @StateObject private var speechCoordinator = SpeechCoordinator()

    let round1 = [
        "둘 중 자주 먹는 것은? 짜장면 vs 짬뽕", "둘 중에 하나만 고른다면?물냉 vs 비냉",
        "아이스 아메리카노 vs 따뜻한 아메리카노", "둘 중에 하나만 고른다면? 진매 vs 진순",
        "지금 당장 떠날 수 있다면? 산 vs 바다", "여친과 연락할 때 전화 vs 문자",
        "둘 중에 하나만 고른다면? 쌀떡 vs 밀떡", "민트초코 나는 호 vs 불호", "붕어빵을 먹을 때 나는 머리 vs 꼬리",
    ]
    @State var round1Index = 0
    @State private var motionManager = CMMotionManager()
    @State private var middle: Double = 0.0
    @State var timer: Timer?
    @State var time = 10
    @State var isAnswered = false
    @State var shouldStartAfterSpeech = false
    @State var choice = ""

    let synthesizer = AVSpeechSynthesizer()

    var body: some View {

        VStack {
            Text("\(round1[round1Index])").onChange(of: round1Index) { _ in
                startRound1()
            }
            .onAppear {
                speechCoordinator.didFinishSpeaking = {
                    if shouldStartAfterSpeech {
                        startTimer(round1Index)
                        chooseByMotion(round1Index)
                        shouldStartAfterSpeech = false
                    }
                }
                startRound1()
            }
        }
    }

    func startRound1() {
        isAnswered = false
        time = 10
        timer?.invalidate()
        motionManager.stopDeviceMotionUpdates()
        choice = ""

        speechCoordinator.speak(round1[round1Index])
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
        if index <= 2 {
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
        } else {
            timer = Timer.scheduledTimer(
                withTimeInterval: 1, repeats: true
            ) { _ in
                if time > 0 {
                    speak(time)
                    time -= 1
                } else {
                    timer?.invalidate()
                    print("종료")

                }
            }
        }
    }

    func chooseByMotion(_ index: Int) {
        var degree: Double
        switch index {
        case 0, 3, 6: degree = 0.5
        case 1, 4, 7: degree = 1.0
        case 2, 5, 8: degree = 1.5
        default: degree = 1
        }

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
                    choice = "오른쪽"
                    isAnswered = true
                } else if value < -degree {
                    choice = "왼쪽"
                    isAnswered = true
                }
                if isAnswered {
                    switch index {
                    case 0, 1, 2: speechCoordinator.speak(choice)
                    case 3, 4, 5: WKInterfaceDevice.current().play(.start)
                    case 6, 7, 8:
                        WKInterfaceDevice.current().play(.start)
                        speechCoordinator.speak(choice)
                    default: speechCoordinator.speak(choice)
                    }
                    timer?.invalidate()
                    motionManager.stopDeviceMotionUpdates()
                    if round1Index != 8 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            round1Index += 1
                        }
                    }
                }
            }
        }

    }

}

#Preview {
    ContentView()
}
