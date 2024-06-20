//
//  AIAssistantTextChatViewModel.swift
//  Fluse
//
//  Created by KEEVIN MITCHELL on 6/14/24.
// <> concrete type
import ChatGPTSwift
import ChatGPTUI
import Observation
import Foundation

@Observable
class AIAssistantTextChatViewModel: TextChatViewModel<AIAssistantResponseView> {
    
    let functionsManager: FunctionsManager
    let db = DatabaseManager.shared
 
    init(apiKey: String, model: ChatGPTModel = .gpt_hyphen_4o) {
        self.functionsManager = .init(apiKey: apiKey)
        super.init(senderImage: "sender", botImage: "botImage", model: model, apiKey: apiKey)
        self.functionsManager.addLogConfirmationCallback = { [weak self] isConfirmed,  props in
            guard let self, let id = props.messageID, let index = self.messages.firstIndex(where: { $0.id == id}) else {
                return
            }
            var messageRow = self.messages[index]
            let text: String
            if isConfirmed {
                try? self.db.add(log: props.log)
                text = "Sure, Ive added this log to your list of expenses."
            } else {
                text = "OK, I will not be adding this log.."
            }
            let response = AIAssistantResponse(text: text, type: .addExpenseLog(.init(log: props.log, messageID: id, userConfirmation: isConfirmed ? .confirmed : .cancelled, confirmationCallback: props.confirmationCallback)))
            /// updating the ui with the response
            messageRow.response = .customContent({ AIAssistantResponseView(response: response)})
            self.messages[index] = messageRow
        } // class
    }
    
    @MainActor
    override func sendTapped() async {
        self.task = Task {
            let text = inputMessage
            inputMessage = ""
            await callFunction(text)
        }
    }
    @MainActor
    override func retry(message: MessageRow<AIAssistantResponseView>) async {
        self.task = Task {
            guard let index = messages.firstIndex(where: { $0.id == message.id }) else {
                return
            }
            self.messages.remove(at: index)
            await callFunction(message.sendText)
        }
        
    }
    
    // New Method
    @MainActor
    func callFunction(_ prompt: String) async {
        isPrompting = true
        var messageRow = MessageRow<AIAssistantResponseView>(
            isPrompting: true,
            sendImage: senderImage,
            send: .rawText(prompt),
            responseImage: botImage,
            response: .rawText(""),
            responseError: nil)
        
        self.messages.append(messageRow)
        
        do {
            let response = try await functionsManager.prompt(prompt, model: model, messageID: messageRow.id)
            messageRow.response = .customContent({ AIAssistantResponseView(response: response)})
            
        } catch {
            messageRow.responseError = error.localizedDescription
        }
        
        messageRow.isPrompting = false
        self.messages[self.messages.count - 1] = messageRow
        isPrompting = false
        
    }
}
