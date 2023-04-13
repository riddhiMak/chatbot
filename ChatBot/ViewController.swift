//
//  ViewController.swift
//  ChatBot
//
//  Created by Riddhi Makwana on 31/08/21.
//

import UIKit
import ReverseExtension
import SwiftyJSON
import Alamofire
import Speech
import GrowingTextView

class ViewController: UIViewController {
    public private(set) var isRecording = false
    @IBOutlet weak var recordButton: UIButton!

    private var audioEngine: AVAudioEngine!
    private var inputNode: AVAudioInputNode!
    private var audioSession: AVAudioSession!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?

    @IBOutlet weak var lblMessage : UILabel!
    @IBOutlet weak var txtMessage : GrowingTextView!
    @IBOutlet weak var tblView : UITableView!
    @IBOutlet weak var btnSend : UIButton!
    @IBOutlet weak var textViewBottomConstraint : NSLayoutConstraint!
    var messages = [Message]()
    let baseURL = "http://radiuschatbot.ngrok.io/webhooks/rest/webhook"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
          selector: #selector(self.keyboardNotification(notification:)),
          name: UIResponder.keyboardWillChangeFrameNotification,
          object: nil)
        // Do any additional setup after loading the view.
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        checkPermissions()
    }
    
    
    override func loadView() {
        super.loadView()
        tblView.dataSource = self
        tblView.delegate = self
        tblView.re.delegate = self
        
        tblView.re.scrollViewDidReachTop = { scrollView in
            print("scrollViewDidReachTop")
        }
        tblView.re.scrollViewDidReachBottom = { scrollView in
            print("scrollViewDidReachBottom")
        }
        txtMessage.layer.cornerRadius = 4.0
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            var keyboardHeight = UIScreen.main.bounds.height - endFrame.origin.y
            if #available(iOS 11, *) {
                if keyboardHeight > 0 {
                    keyboardHeight = keyboardHeight - view.safeAreaInsets.bottom
                }
            }
            textViewBottomConstraint.constant = keyboardHeight + 8
            view.layoutIfNeeded()
        }
    }

    
    @IBAction func btnRefresh(_ sender : UIButton){
        self.messages.removeAll()
        self.tblView.reloadData()
    }
    
    @IBAction func btnSend(_ sender : UIButton){
        if(txtMessage.text!.isEmpty){
            
        }else{
            let message = Message(text: self.txtMessage!.text!, date: Date(), type: .user, UIType: .regular, options : [])
            self.sendMessage(message)
            self.getResponse(strMessage: txtMessage.text ?? "", completion: { (response) in
                for obj in response{
                    if(obj?.buttons != nil){
                        let message = Message(text: obj?.text ?? "" , date: Date(), type: .bot,UIType: .withButtons,options : obj?.buttons ?? [])
                        self.receiveMessage(message)

                    }else{
                        let message = Message(text: obj?.text ?? "" , date: Date(), type: .bot,UIType: .regular,options : [])
                        self.receiveMessage(message)

                    }
                }
            })
            self.txtMessage.text = ""
            self.view.endEditing(true)
        }
    }
    // MARK:- send message
    func sendMessage(_ message: Message) {
        messages.append(message)
        
        tblView.beginUpdates()
        tblView.re.insertRows(at: [IndexPath(row: messages.count - 1, section: 0)], with: .automatic)
        
        tblView.endUpdates()
    }
    
    func receiveMessage(_ message: Message) {
        messages.append(message)
        
        tblView.beginUpdates()
        tblView.re.insertRows(at: [IndexPath(row: messages.count - 1, section: 0)], with: .automatic)
        
        tblView.endUpdates()
    }
    
    func getResponse (strMessage : String , completion: @escaping ([ResponseRootClass?]) -> ()){
        let dict = ["message":strMessage] as NSDictionary

        AF.request(baseURL, method: .post, parameters: dict as? Parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            switch response.result {
            case .success(_):

                do {
                    let obj = try JSONDecoder().decode([ResponseRootClass].self, from: response.data!)
                    completion(obj)
                } catch let jsonErr {
                    print("Failed to decode json:", jsonErr)
                }

                break
            case .failure(_):
                completion([])

                break
            }
        }
    }

}




extension ViewController : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let message = messages[messages.count - (indexPath.row + 1)]
        if(message.UIType == .withButtons){
            if(message.options.count != 0){
                let count = message.options.count
                return CGFloat(count * 50 + 50)
            }
        }
        
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[messages.count - (indexPath.row + 1)]
        switch message.type {
        case .user:
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell", for: indexPath) as! UserTableViewCell
            cell.imgBackground.layer.cornerRadius = 8.0
            cell.imgBackground.layer.masksToBounds = true
            cell.lblMessage.text = message.text
            return cell
            
        case .bot:
            switch message.UIType {
            case .regular:
                let cell = tableView.dequeueReusableCell(withIdentifier: "BotTableViewCell", for: indexPath) as! BotTableViewCell
                cell.imgBackground.layer.cornerRadius = 8.0
                cell.imgBackground.layer.masksToBounds = true
                cell.lblMessage.text = message.text
                return cell

            case .withButtons:
                let cell = tableView.dequeueReusableCell(withIdentifier: "CustomBotCell", for: indexPath) as! CustomBotCell
                cell.imgBackground.layer.cornerRadius = 8.0
                cell.imgBackground.layer.masksToBounds = true

                cell.loadCompanyCollectionView(arrFeature: message.options)
                cell.lblFeatureTitle.text = message.text
                
                cell.btnFeaturePressed  = { payload , title in
                    let message = Message(text: title, date: Date(), type: .user, UIType: .regular, options : [])
                    self.sendMessage(message)

                    self.getResponse(strMessage: payload) { (response) in
                        for obj in response{
                            if(obj?.buttons != nil){
                                let message = Message(text: obj?.text ?? "" , date: Date(), type: .bot,UIType: .withButtons,options : obj?.buttons ?? [])
                                self.receiveMessage(message)

                            }else{
                                let message = Message(text: obj?.text ?? "" , date: Date(), type: .bot,UIType: .regular,options : [])
                                self.receiveMessage(message)

                            }
                        }
                    }
                }
                return cell

           

            }
        }
    }
    
    
}
extension ViewController {
    // MARK: - Privacy
    private func checkPermissions() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized: break
                default: self.handlePermissionFailed()
                }
            }
        }
    }

    private func handlePermissionFailed() {
        // Present an alert asking the user to change their settings.
        let ac = UIAlertController(title: "This app must have access to speech recognition to work.",
                                   message: "Please consider updating your settings.",
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Open settings", style: .default) { _ in
            let url = URL(string: UIApplication.openSettingsURLString)!
            UIApplication.shared.open(url)
        })
        ac.addAction(UIAlertAction(title: "Close", style: .cancel))
        present(ac, animated: true)

        // Disable the record button.
        recordButton.isEnabled = false
//        recordButton.setTitle("Speech recognition not available.", for: .normal)
    }
}
// MARK: - Speech - to - text
extension ViewController : SFSpeechRecognizerDelegate{
   
    // MARK: - User interface
    @IBAction func recordButtonTapped(_ sender: UIButton) {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
        isRecording.toggle()
       // sender.setImage(isRecording ? UIImage(named: "mic.circle") : UIImage(named: "record.circle") , for: .normal)
        //sender.setTitle((isRecording ? "Stop" : "Start") + " recording", for: .normal)
    }

    private func handleError(withMessage message: String) {
        // Present an alert.
        let ac = UIAlertController(title: "An error occured", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)

        // Disable record button.
//        recordButton.setTitle("Not available.", for: .normal)
        recordButton.isEnabled = false
    }
    
    // MARK: - Speech recognition
    private func startRecording() {
        // MARK: 1. Create a recognizer.
        guard let recognizer = SFSpeechRecognizer(), recognizer.isAvailable else {
            handleError(withMessage: "Speech recognizer not available.")
            return
        }

        // MARK: 2. Create a speech recognition request.
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest!.shouldReportPartialResults = true

        recognizer.recognitionTask(with: recognitionRequest!) { (result, error) in
            guard error == nil else { self.handleError(withMessage: error!.localizedDescription); return }
            guard let result = result else { return }

            print("got a new result: \(result.bestTranscription.formattedString), final : \(result.isFinal)")
            if result.isFinal {
                DispatchQueue.main.async {
                    self.updateUI(withResult: result)
                }
            }
        }

        // MARK: 3. Create a recording and classification pipeline.
        audioEngine = AVAudioEngine()

        inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            self.recognitionRequest?.append(buffer)
        }

        // Build the graph.
        audioEngine.prepare()

        // MARK: 4. Start recognizing speech.
        do {
            // Activate the session.
            audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .spokenAudio, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

            // Start the processing pipeline.
            try audioEngine.start()
        } catch {
            handleError(withMessage: error.localizedDescription)
        }
    }

    
    private func updateUI(withResult result: SFSpeechRecognitionResult) {
        // Update the UI: Present an alert.
        let message = Message(text: result.bestTranscription.formattedString, date: Date(), type: .user, UIType: .regular, options : [])
        self.sendMessage(message)
        self.getResponse(strMessage: result.bestTranscription.formattedString, completion: { (response) in
            for obj in response{
                if(obj?.buttons != nil){
                    let message = Message(text: obj?.text ?? "" , date: Date(), type: .bot,UIType: .withButtons,options : obj?.buttons ?? [])
                    self.receiveMessage(message)

                }else{
                    let message = Message(text: obj?.text ?? "" , date: Date(), type: .bot,UIType: .regular,options : [])
                    self.receiveMessage(message)

                }
            }
        })
        let ac = UIAlertController(title: "You said:",
                                   message: result.bestTranscription.formattedString,
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(ac, animated: true)
    }

    private func stopRecording() {
        // End the recognition request.
        recognitionRequest?.endAudio()
        recognitionRequest = nil

        // Stop recording.
        audioEngine.stop()
        inputNode.removeTap(onBus: 0) // Call after audio engine is stopped as it modifies the graph.

        // Stop our session.
        try? audioSession.setActive(false)
        audioSession = nil
    }
}
extension ViewController: GrowingTextViewDelegate {
        
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [.curveLinear], animations: { () -> Void in
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}
