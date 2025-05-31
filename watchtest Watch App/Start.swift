//
//  Start.swift
//  watchtest Watch App
//
//  Created by jiwon on 5/31/25.
//

import AVFoundation
import SwiftUI

struct Start: View {

    let synthesizer = AVSpeechSynthesizer()
    let message =
        "회전 제스처 선택 게임에 오신 것을 환영합니다! 질문은 총 19개이며 약 3~5분 소요됩니다. 손목을 돌려 질문에 응답해 주세요."

    var body: some View {
        NavigationStack {
            VStack {
                NavigationLink("🎮 시작하기", destination: ContentView())
            }.onAppear { speak(message) }
        }
    }
    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR")
        synthesizer.speak(utterance)
    }
}

#Preview {
    Start()
}
