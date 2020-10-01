//
//  ViewController.swift
//  Voice2Text
//
//  Created by 樋口大樹 on 2020/09/26.
//  Copyright © 2020 樋口大樹. All rights reserved.
//

import UIKit
import Speech
import AVFoundation

class ViewController: UIViewController, My_ViewDelegate{
    
    var isRecording = false
    let recognizer  = SFSpeechRecognizer(locale: Locale.init(identifier: "ja_JP"))!
    var audioEngine    : AVAudioEngine!
    var recognitionReq : SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    var my_view        : CustomView!
    
    func recordButtonTapped() {
        if isRecording {
            print("録音停止")
            stopLiveTranscription()
        } else {
            print("録音開始")
            try! startLiveTranscription()
        }
        isRecording = !isRecording
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let view_frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        my_view = CustomView(frame: view_frame)
        self.view = my_view
        //委譲先はこのクラス.
        self.my_view.delegate = self
        audioEngine = AVAudioEngine()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //マイクを使うプライバシーの確認.
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            DispatchQueue.main.async {
                if authStatus != SFSpeechRecognizerAuthorizationStatus.authorized {
                    self.my_view.recordButton.isEnabled = false
                    self.my_view.recordButton.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
                }
            }
        }
    }
    
    func stopLiveTranscription() {
        //録音停止状態：ボタン白色
        self.my_view.recordButton.backgroundColor = .white
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionReq?.endAudio()
    }
    
    func startLiveTranscription() throws {
        //録音中：ボタン赤色
        self.my_view.recordButton.backgroundColor = .red
        
        // もし前回の音声認識タスクが実行中ならキャンセル
        if let recognitionTask = self.recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        //self.my_view.Voice2TextView.text = ""
        
        // 音声認識リクエストの作成
        recognitionReq = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionReq = recognitionReq else {
            return
        }
        //各発言に対して中間結果を返すかどうかを示すブール値.
        recognitionReq.shouldReportPartialResults = true
        
        // オーディオセッションの設定
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        //オーディオエンジンの入力ノード.
        let inputNode = audioEngine.inputNode
        
        // マイク入力の設定
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 2048, format: recordingFormat) { (buffer, time) in
            recognitionReq.append(buffer)
        }
        //このメソッドは、オーディオエンジンが起動するために必要なリソースの多くを事前に割り当てます。これを使用して、オーディオの入力や出力をよりレスポンスよく開始します。
        audioEngine.prepare()
        try audioEngine.start()
        
        recognitionTask = recognizer.recognitionTask(with: recognitionReq, resultHandler: { (result, error) in
            if let error = error {
                print("\(error)")
            } else {
                DispatchQueue.main.async {
                    //result : 音声認識要求の部分的な結果または最終的な結果を含むオブジェクト。
                    //bestTranscription : 最も信頼度の高い翻訳結果.
                    self.my_view.Voice2TextView.text = result?.bestTranscription.formattedString
                    print(result?.transcriptions)
                }
            }
        })
    }
}
