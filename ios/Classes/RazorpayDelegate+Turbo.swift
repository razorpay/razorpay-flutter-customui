
import Flutter
import Razorpay
import WebKit
import TurboUpiPluginUAT

typealias TurboDictionary = Dictionary<String,Any>
typealias TurboArrayDictionary = Array<TurboDictionary>

extension RazorpayDelegate {
    //MARK: Flutter call back methods
    
    func getLinkedUpiAccounts(mobileNumber: String, result: @escaping FlutterResult, eventSink: @escaping FlutterEventSink){
        self.pendingResult = result
        self.eventSink = eventSink
        self.initilizeSDK(withKey: self.merchantKey, result: result)
        if let isUi = self.isTurboUI, isUi == true {
            razorpay?.upiTurboUI?.getLinkedUpiAccounts(mobileNumber: mobileNumber, resultDelegate: self)
        } else {
            razorpay?.upiTurbo?.getLinkedUpiAccounts(mobileNumber: mobileNumber, resultDelegate: self)
        }
    }
    
    //Payment
    func submitTurbo(tempOptions: Dictionary<String, Any>) {
        guard var payload = tempOptions["payload"] as? [AnyHashable: Any] else { return }
        if let amount = payload["amount"] as? Int {
            payload["amount"] = "\(amount)"
        }
        if let amountDouble = payload["amount"] as? Double {
            payload["amount"] = "\(Int(amountDouble))"
        }
        
        payload.removeValue(forKey: "key")
        if !self.upiAccounts.isEmpty {
            if let upiAccountStr = tempOptions["upiAccount"] as? String {
                if let selectedUpiAccount = getUpiAccount(upiAccountStr){
                    payload["upiAccount"] = selectedUpiAccount
                    self.razorpay?.authorize(payload)
                    
                    let rootVC = UIApplication.shared.keyWindow?.rootViewController
                    if let navCtrl = self.navController {
                        navCtrl.modalPresentationStyle = .fullScreen
                        rootVC?.present(navCtrl, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    //MARK: Custom Headless
    
    func setupUpiPin(cardStr: String,result: @escaping FlutterResult, eventSink: @escaping FlutterEventSink) {
        self.pendingResult = result
        self.eventSink = eventSink
        if let upiCard = getUpicard(cardStr), let selectedBankAccount = self.selectedBankAccount {
            let selectBankAction = LinkUpiAction(action: .setUpiPin)
            selectBankAction.setUpiPin(selectedBankAccount, upiCard)
        }
    }
    func linkNewUpiAccount(mobileNumber: String, result: @escaping FlutterResult, eventSink: @escaping FlutterEventSink){
        self.pendingResult = result
        self.eventSink = eventSink
        self.razorpay?.upiTurbo?.linkNewAccount(mobileNumber: mobileNumber, linkActionDelegate: self)
    }
    
    func register(result: @escaping FlutterResult, eventSink: @escaping FlutterEventSink){
        self.pendingResult = result
        self.eventSink = eventSink
        let register = LinkUpiAction(action: .sendSms)
        register.registerDevice()
    }

    
    func getBankAccounts(bankStr: String, result: @escaping FlutterResult, eventSink: @escaping FlutterEventSink) {
        self.pendingResult = result
        self.eventSink = eventSink
        if let bank = getBank(bankStr) {
            let selectBankAction = LinkUpiAction(action: .selectBank)
            selectBankAction.selectedBank(bank)
        }
    }
    
    func selectedBankAccount(bankAccountStr: String , result: @escaping FlutterResult, eventSink: @escaping FlutterEventSink){
        self.pendingResult = result
        self.eventSink = eventSink
        if let bankAccount = getBankAccount(bankAccountStr) {
            self.selectedBankAccount = bankAccount
            let selectBankAction = LinkUpiAction(action: .selectBankAccount)
            selectBankAction.selectedBankAccount(bankAccount)
        }
     }
    
    func  getBalance(upiAccountStr: String , result: @escaping FlutterResult, eventSink: @escaping FlutterEventSink){
        self.pendingResult = result
        self.eventSink = eventSink
        var reply = TurboDictionary()
        if let upiAccount = getUpiAccount(upiAccountStr) {
            self.razorpay?.upiTurbo?.fetchAccountBalance(upiAccount: upiAccount, handler: { response, error in
                guard error == nil else {
                    let err = error as? TurboError
                    self.handleAndPublishTurboError(error: err)
                    return
                }
                guard let balanceResponse = response as? UpiAccountBalance else {
                    return
                }
                if let balanceResponseStr = self.getAccountbalanceJSON(balanceResponse) {
                    reply["data"] = balanceResponseStr
                    self.sendReply(data: reply)
                }
            })
        }
    }

    func changeUpiPin(upiAccountStr: String , result: @escaping FlutterResult, eventSink: @escaping FlutterEventSink) {
        self.pendingResult = result
        self.eventSink = eventSink
        var reply = TurboDictionary()
        if let upiAccount = getUpiAccount(upiAccountStr) {
            self.razorpay?.upiTurbo?.changeUpiPin(upiAccount: upiAccount, handler: { response, error in
                guard error == nil else {
                    let err = error as? TurboError
                    self.handleAndPublishTurboError(error: err)
                    return
                }
                print("Upi Pin changed Successfully")
                reply["data"] = upiAccountStr
                self.sendReply(data: reply)
            })
        }
    }

    func resetUpiPin(resetDict: TurboDictionary , result: @escaping FlutterResult, eventSink: @escaping FlutterEventSink){
        self.pendingResult = result
        self.eventSink = eventSink
        var reply = TurboDictionary()
        
        guard let upiAccountStr = resetDict["upiAccount"] as? String else { return }
        guard let cardStr = resetDict["card"] as? String else { return }

        if let upiAccount = getUpiAccount(upiAccountStr), let upiCard = getUpicard(cardStr) {
            self.razorpay?.upiTurbo?.resetUpiPin(upiAccount: upiAccount, card: upiCard, handler: { response, error in
                guard error == nil else {
                    let err = error as? TurboError
                    self.handleAndPublishTurboError(error: err)
                    return
                }
                print("Reset UPI Pin Successfully")
                reply["data"] = upiAccountStr
                self.sendReply(data: reply)
            })
        }
    }

    func delink(upiAccountStr: String , result: @escaping FlutterResult, eventSink: @escaping FlutterEventSink) {
        self.pendingResult = result
        self.eventSink = eventSink
        var reply = TurboDictionary()
        if let upiAccount = getUpiAccount(upiAccountStr) {
            self.razorpay?.upiTurbo?.delinkVpa(upiAccount: upiAccount, handler: { response, error in
                guard error == nil else {
                    let err = error as? TurboError
                    self.handleAndPublishTurboError(error: err)
                    return
                }
                
                print("VPA Delinked Successfully")
                reply["data"] = "Successfully delink your account"
                self.sendReply(data: reply)
            })
        }
    }
    
    func isTurboPluginAvailable(result: @escaping FlutterResult, eventSink: @escaping FlutterEventSink) {
        self.pendingResult = result
        self.eventSink = eventSink
        var reply = TurboDictionary()
#if canImport(TurboUpiPluginUAT)
        reply["isTurboPluginAvailable"] =  true
        #else
        reply["isTurboPluginAvailable"] =  false
        #endif
        sendReply(data: reply)
    }
    
    //MARK: Custom UI
    
    func linkNewUpiAccountUI(mobileNumber: String, color: String, result: @escaping FlutterResult, eventSink: @escaping FlutterEventSink){
        self.pendingResult = result
        self.eventSink = eventSink
        self.initilizeSDK(withKey: self.merchantKey, result: result)
        self.razorpay?.upiTurboUI?.linkNewUpiAccount(mobileNumber: mobileNumber, color: color, completionHandler: { response, error in
            guard error == nil else {
                let err = error as? TurboError
                self.handleAndPublishTurboError(error: err)
                return
            }
            if let accList = response as? [TurboUpiPluginUAT.UpiAccount] {
                var reply = Dictionary<String,Any>()
                reply["data"] = self.getUpiAccountJSON(accList)
                self.sendReply(data: reply)
            }
        })
    }
    
    func manageAccount(customerMobile: String , result: @escaping FlutterResult, eventSink: @escaping FlutterEventSink) {
        self.pendingResult = result
        self.eventSink = eventSink
        self.initilizeSDK(withKey: self.merchantKey, result: result)
        self.razorpay?.upiTurboUI?.manageUpiAccount(mobileNumber: customerMobile, color: "")
    }
    
    //Prefetch
    func prefetchAndLinkNewUpiAccountUI(dict: TurboDictionary , result: @escaping FlutterResult, eventSink: @escaping FlutterEventSink) {
        self.pendingResult = result
        self.eventSink = eventSink
        
        var reply = TurboDictionary()
        reply["responseEvent"] = PREFETCH_AND_LINK_NEW_UPI_ACCOUNT_EVENT
        
        let dict = [
            "accountsWithPinSet": [
                ["bank_logo_url": "https://cdn.razorpay.com/bank/AXIS.gif", "vpa": ["bank_account": ["state": "linkingInProgress","beneficiary_name": "PRIYANK PRAVINCHANDRA SHAH", "bank": ["ifsc": "AXIS0000003", "id": "607153", "logo": "https://cdn.razorpay.com/bank/AXIS.gif", "code": "607153", "bankPlaceholderUrl": "https://betacdn.np.razorpay.in/placeholder/bank_placeholder.png", "name": "AXIS"], "masked_account_number": "XXXX474120", "ifsc": "AXIS0000003", "creds": ["atmpin": ["set": false, "length": 6], "upipin": ["set": true, "length": 6], "sms": ["set": false, "length": 6]]], "default": false, "username": "917012969837-1", "handle": "axis", "address": "917012969837-1@axis", "active": false, "validated": false], "bankPlaceholderUrl": "https://betacdn.np.razorpay.in/placeholder/bank_placeholder.png", "ifsc": "AXIS0000003", "bank_name": "AXIS", "account_number": "XXXX474120", "isUpiAccount": true],
                
                ["bank_logo_url": "https://cdn.razorpay.com/bank/AABE.gif", "bankPlaceholderUrl": "https://betacdn.np.razorpay.in/placeholder/bank_placeholder.png", "vpa": ["bank_account": ["state": "linkingSuccess","beneficiary_name": "ABC", "ifsc": "AABE0877543", "bank": ["name": "Mybene", "logo": "https://cdn.razorpay.com/bank/AABE.gif", "code": "000000", "bankPlaceholderUrl": "https://betacdn.np.razorpay.in/placeholder/bank_placeholder.png", "ifsc": "AABE0877543", "id": "000000"], "creds": ["upipin": ["length": 6, "set": true], "sms": ["length": 6, "set": false], "atmpin": ["length": 6, "set": false]], "masked_account_number": "857775XXXXXXXX9"], "address": "917012969837-4@axis", "username": "917012969837-4", "validated": false, "default": false, "active": false, "handle": "axis"], "account_number": "857775XXXXXXXX9", "ifsc": "AABE0877543", "isUpiAccount": true, "bank_name": "Mybene"],
                
                ["account_number": "XXXXXXXXXX000052", "bank_logo_url": "https://cdn.razorpay.com/bank/AABC.gif", "bankPlaceholderUrl": "https://betacdn.np.razorpay.in/placeholder/bank_placeholder.png", "isUpiAccount": true, "bank_name": "MYPSP", "ifsc": "AABC0000823", "vpa": ["validated": false, "address": "917012969837-3@axis", "bank_account": ["state": "linkingFailed","ifsc": "AABC0000823", "beneficiary_name": "ABC", "masked_account_number": "XXXXXXXXXX000052", "creds": ["atmpin": ["length": 6, "set": false], "sms": ["length": 6, "set": false], "upipin": ["length": 4, "set": true]], "bank": ["name": "MYPSP", "ifsc": "AABC0000823", "bankPlaceholderUrl": "https://betacdn.np.razorpay.in/placeholder/bank_placeholder.png", "id": "504432", "logo": "https://cdn.razorpay.com/bank/AABC.gif", "code": "504432"]], "default": false, "username": "917012969837-3", "handle": "axis", "active": false]]
            ],
            "accountsWithPinNotSet": [
                ["state": "linkingSuccess","ifsc": "AABC0000823", "beneficiary_name": "ABC", "masked_account_number": "XXXXXXXXXX000052", "creds": ["atmpin": ["length": 6, "set": false], "sms": ["length": 6, "set": false], "upipin": ["length": 4, "set": true]], "bank": ["name": "MYPSP", "ifsc": "AABC0000823", "bankPlaceholderUrl": "https://betacdn.np.razorpay.in/placeholder/bank_placeholder.png", "id": "504432", "logo": "https://cdn.razorpay.com/bank/AABC.gif", "code": "504432"]
                ],
                
                ["state": "linkingSuccess","beneficiary_name": "ABC", "ifsc": "AABE0877543", "bank": ["name": "Mybene", "logo": "https://cdn.razorpay.com/bank/AABE.gif", "code": "000000", "bankPlaceholderUrl": "https://betacdn.np.razorpay.in/placeholder/bank_placeholder.png", "ifsc": "AABE0877543", "id": "000000"], "creds": ["upipin": ["length": 6, "set": true], "sms": ["length": 6, "set": false], "atmpin": ["length": 6, "set": false]], "masked_account_number": "857775XXXXXXXX9"]
            ]
        ]
        
        if let finalDictStr = self.convertDictionaryToJSON(dict) {
            reply["data"] = finalDictStr
            self.onEventSuccess(&reply)
        }
        return
        
        guard let customerMobile = dict["customerMobile"] as? String else { return }
        let color = dict["color"] as? String ?? ""
        
        self.razorpay?.upiTurboUI?
            .setCustomerMobile(mobile: customerMobile)
            .setColor(color: color)
            .prefetchAndLinkUpiAccountsWithUI(completionHandler: { response, error in
                guard error == nil else {
                    let err = error as? TurboError
                    self.handleAndPublishTurboError(error: err)
                    self.onEventError(reply: &reply, err?.errorDescription ?? "")
                    return
                }
                
                var pinNotSetArr = TurboArrayDictionary()
                var pinSetArr = TurboArrayDictionary()

                if let upiAllAccount = response as? UpiAllAccounts {
                    if let accountWithPinNotSet = upiAllAccount.accountsWithPinNotSet {
                        for account in accountWithPinNotSet {
                            let bankAccountDict = self.getUpiBankAccountDict(account)
                            pinNotSetArr.append(bankAccountDict)
                        }
                    }
                    
                    if let accountWithPinSet = upiAllAccount.accountsWithPinSet {
                        for account in accountWithPinSet {
                            if let bankAccount = account as? UpiBankAccount {
                                var bankAccountsDict = self.getUpiBankAccountDict(bankAccount)
                                bankAccountsDict["isUpiAccount"] = false
                                pinSetArr.append(bankAccountsDict)
                            }
                            if let upiAccount = account as? UpiAccount {
                                var upiAccountDict = self.getUpiAccountDict(upiAccount)
                                upiAccountDict["isUpiAccount"] = true
                                pinSetArr.append(upiAccountDict)
                            }
                        }
                    }
                }
                
                let finalDict = [
                    "accountsWithPinNotSet": pinNotSetArr,
                    "accountsWithPinSet": pinSetArr
                ]
                if let finalDictStr = self.convertDictionaryToJSON(finalDict) {
                    reply["data"] = finalDictStr
                    self.onEventSuccess(&reply)
                }
            })
    }
    
    func setPrefetchUPIPinWithUI(bankAccountStr: String , result: @escaping FlutterResult, eventSink: @escaping FlutterEventSink){
        self.pendingResult = result
        self.eventSink = eventSink
        if let bankAccount = getBankAccount(bankAccountStr) {
            self.razorpay?
                .upiTurboUI?
                .setUpiPinWithUI(bankAccount, completionHandler: { response, error in
                    guard error == nil else {
                        let err = error as? TurboError
                        self.handleAndPublishTurboError(error: err)
                        return
                    }
                    if let accList = response as? [TurboUpiPluginUAT.UpiAccount] {
                        var reply = Dictionary<String,Any>()
                        reply["data"] = self.getUpiAccountJSON(accList)
                        self.sendReply(data: reply)
                    }
                })
        }
    }

    //MARK: File methods
    private func onEventSuccess(_ reply: inout TurboDictionary) {
        reply["type"] = CODE_EVENT_SUCCESS
        sendReplyByEventSink(reply)
    }

    private func onEventError(reply: inout TurboDictionary , _ errorDescription: String) {
        reply["type"] = CODE_EVENT_ERROR
        reply["error"] = errorDescription
        sendReplyByEventSink(reply)
    }
    
    private func onEventDefaultError(reply: inout TurboDictionary) {
        reply["type"] = CODE_EVENT_ERROR
        reply["error"] = "Something went wrong!"
        sendReplyByEventSink(reply)
    }
    
    func sendReplyByEventSink(_ reply: TurboDictionary) {
        self.eventSink(reply)
    }
    
    func sendReply(data: TurboDictionary) {
        pendingResult(data)
    }
    
    fileprivate func convertDictionaryToJSON<T: Any>(_ dictionary: T) -> String?  {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted) else {
            print("Something is wrong while converting dictionary to JSON data.")
            return nil
         }

         guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            print("Something is wrong while converting JSON data to JSON string.")
            return nil
         }

         return jsonString
    }
    
    func convertToDictionary(_ text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func getUpiAccount(_ upiAccountStr: String) -> UpiAccount? {
        guard let upiDict = convertToDictionary(upiAccountStr) else { return nil }
        guard let vpa = upiDict["vpa"] as? TurboDictionary, let address = vpa["address"] as? String  else { return nil }
        let filterUpiAccounts = self.upiAccounts.filter({ $0.vpa?.address == address })
        if !filterUpiAccounts.isEmpty {
            if let selectedUpiAccount = filterUpiAccounts.first {
                return selectedUpiAccount
            }
        }
        return nil
    }
    
    private func getBankJSON(_ allBanks: AllBanks) -> String {
        
        if let banksList = allBanks.banks as? [UpiBank], let popularBanks = allBanks.popularBanks as? [UpiBank] {
            self.upiBanks = banksList
            var allBanksDict: TurboDictionary = [:]
            if !banksList.isEmpty {
                var bankDict = banksList.toArrayDictionary()
                var popularBankDict = popularBanks.toArrayDictionary()
                
                bankDict = bankDict.map { var dict = $0; dict["data"] = nil; return dict }
                popularBankDict = bankDict.map { var dict = $0; dict["data"] = nil; return dict }
                
                allBanksDict["popularBanks"] =  popularBankDict
                allBanksDict["banks"] = bankDict
                
                if let bankStr = convertDictionaryToJSON(allBanksDict) {
                   return bankStr
                }
            }
        }
        return ""
    }
    
    private func getBank(_ bankStr: String) -> UpiBank? {
        if let bank = convertToDictionary(bankStr) {
            print(bank)
            if let ifsc = bank["ifsc"] as? String {
                let upiBanks = self.upiBanks.filter({ $0.ifsc == ifsc })
                if !upiBanks.isEmpty {
                    if let upiBank = upiBanks.first {
                        return upiBank
                    }
                }
            }
        }
        return nil
    }
    
    private func getBankAccount(_ bankStr: String) -> UpiBankAccount? {
        if let bankAccount = convertToDictionary(bankStr) {
            if let accountNumber = bankAccount["masked_account_number"] as? String {
                let upiBankAccounts = self.upiBankAccounts.filter({ $0.accountNumber == accountNumber })
                if !upiBankAccounts.isEmpty {
                    if let upiBankAccount = upiBankAccounts.first {
                        return upiBankAccount
                    }
                }
            }
        }
        return nil
    }
    
    private func getUpicard(_ cardStr: String) -> UpiCard? {
        if let bankAccount = convertToDictionary(cardStr) {
            guard let expiryMonth = bankAccount["expiryMonth"] as? String, let expiryYear = bankAccount["expiryYear"] as? String, let lastSixDigits = bankAccount["lastSixDigits"] as? String else {
                return nil
            }
            return UpiCard(expMonth: expiryMonth, expYear: expiryYear, lastSixDigits: lastSixDigits)
            
        }
        return nil
    }
    
    private func getBankAccountJSON(_ bankAccounts: [UpiBankAccount]) -> String {
        self.upiBankAccounts = bankAccounts
        var bankAccountArrayDict = TurboArrayDictionary()
        if !bankAccounts.isEmpty {
            for account in bankAccounts {
                let dict = getUpiBankAccountDict(account)
                bankAccountArrayDict.append(dict)
            }
        }
                
        if let bankAccountStr = convertDictionaryToJSON(bankAccountArrayDict) {
            return bankAccountStr
        }
        
        return ""
    }
    
    private func getUpiBankAccountDict(_ account: UpiBankAccount) -> TurboDictionary {
        var dict = TurboDictionary()
        dict["ifsc"] = account.ifsc
        dict["masked_account_number"] = account.accountNumber
        dict["beneficiary_name"] = account.beneficiaryName
        dict["state"] = self.getStringStateFromBankAccounutState(account.state)
        if let bank = account.bank {
            var bankDict = bank.toDictionary()
            bankDict["data"] = nil
            dict["bank"] = bankDict
        }
        if let creds = account.creds {
            var credDict = TurboDictionary()
            if let upiPIn = creds.upipin {
                credDict["upipin"] = upiPIn.toDictionary()
            }
            if let atmPin = creds.atmpin {
                credDict["atmpin"] = atmPin.toDictionary()
            }
            if let sms = creds.sms {
                credDict["sms"] = sms.toDictionary()
            }
            dict["creds"] = credDict
        }
        return dict
    }
    
    private func getStringStateFromBankAccounutState(_ state: UpiBankAccountState) -> String? {
        switch state {
            
        case .upiPinNotSet:
            return "upiPinNotSet"

        case .upiPinSet:
            return "upiPinSet"

        case .linkingInProgress:
            return "linkingInProgress"

        case .linkingSuccess:
            return "linkingSuccess"

        case .linkingFailed:
            return "linkingFailed"

        @unknown default:
            return "linkingSuccess"

        }
    }
    
    private func getUpiAccountJSON(_ upiAccounts: [UpiAccount]) -> String? {
        self.upiAccounts = upiAccounts
        var upiAccountArrayDict = TurboArrayDictionary()
        if !upiAccounts.isEmpty {
            for account in upiAccounts {
                let dict = getUpiAccountDict(account)
                upiAccountArrayDict.append(dict)
            }
        }
        
        if let bankAccountStr = convertDictionaryToJSON(upiAccountArrayDict) {
            return bankAccountStr
        }
        
        return nil
    }
    
    
    private func getUpiAccountDict(_ account: UpiAccount) -> TurboDictionary {
        var dict = TurboDictionary()
        dict["account_number"] = account.accountNumber
        dict["bank_logo_url"] = account.bankLogoUrl
        dict["bank_name"] = account.bankName
        dict["bankPlaceholderUrl"] = account.bankPlaceholderUrl
        dict["ifsc"] = account.ifsc
     //   dict["pinLength"] = account.pinLength

        if let vpa = account.vpa {
            var vpaDict = TurboDictionary()
            vpaDict["address"] = vpa.address
            vpaDict["handle"] = vpa.handle
            vpaDict["active"] = vpa.active
            vpaDict["default"] = vpa.isDefault
            vpaDict["validated"] = vpa.validated
            vpaDict["username"] = vpa.username
            if let account = vpa.bankAccount {
                vpaDict["bank_account"] = getUpiBankAccountDict(account)
            }
            dict["vpa"] = vpaDict
        }
        
        return dict
    }
    
    private func getAccountbalanceJSON(_ accountBalance: UpiAccountBalance) -> String? {
        var dict = accountBalance.toDictionary()
        dict.removeValue(forKey: "success")
        if let balanceStr = convertDictionaryToJSON(dict) {
            return balanceStr
        }
        return nil
    }
    
    private func handleAndPublishTurboError(error: TurboError?) {
        self.pendingResult(FlutterError.init(code: error?.errorCode ?? "",
                                             message: error?.errorDescription,
                                             details: nil))
    }
    
}

extension RazorpayDelegate: UpiTurboLinkAccountDelegate {//UpiTurboLinkAccActionDelegate
    func onResponse(_ action: LinkUpiAction) {
        var reply = TurboDictionary()
        reply["responseEvent"] = LINK_NEW_UPI_ACCOUNT_EVENT
        switch action.code {
        case .sendSms:
            guard action.error == nil else {
                onEventError(reply: &reply, action.error?.errorDescription ?? "")
                return
            }
            action.registerDevice()
            
        case .selectBank:
            reply["action"] = "SELECT_BANK"
            
            guard action.error == nil else {
                onEventError(reply: &reply, action.error?.errorDescription ?? "")
                return
            }
            if let banks = action.data as? AllBanks {
                reply["data"] = getBankJSON(banks)
                onEventSuccess(&reply)
                
            } else {
                self.onEventDefaultError(reply: &reply)
            }
            
        case .selectBankAccount:
            reply["action"] = "SELECT_BANK_ACCOUNT"

            guard action.error == nil else {
                onEventError(reply: &reply, action.error?.errorDescription ?? "")
                return
            }
            
            if let bankAccounts = action.data as? [UpiBankAccount] {
                reply["data"] = getBankAccountJSON(bankAccounts)
                onEventSuccess(&reply)
            } else {
                self.onEventDefaultError(reply: &reply)
            }
            
        case .setUpiPin:
            reply["action"] = "SETUP_UPI_PIN"
            guard action.error == nil else {
                onEventError(reply: &reply, action.error?.errorDescription ?? "")
                return
            }
            reply["data"] = "SETUP_UPI_PIN"
            onEventSuccess(&reply)
        case .linkAccountResponse:
            reply["action"] = "STATUS"
            guard action.error == nil else {
                onEventError(reply: &reply, action.error?.errorDescription ?? "")
                return
            }
            if let upiAccounts = action.data as? [UpiAccount] {
                reply["data"] = getUpiAccountJSON(upiAccounts)
                onEventSuccess(&reply)
            } else {
                self.onEventDefaultError(reply: &reply)
            }
            //TODO: handle UPI Account Response here and save it globally in this file for further usage.
        case .loaderData:
            reply["action"] = "LOADER_DATA"
            print("onResponse() \(String(describing: action.data))")
             reply["data"] = ""
             onEventSuccess(&reply)
        case .consent:
            break
        @unknown default:
            break
        }
    }
}


extension RazorpayDelegate: UPITurboResultDelegate {
    func onErrorFetchingLinkedAcc(_ error: TurboUpiPluginUAT.TurboError?) {
        self.handleAndPublishTurboError(error: error)
    }
    
    func onSuccessFetchingLinkedAcc(_ accList: [TurboUpiPluginUAT.UpiAccount]) {
        var reply = Dictionary<String,Any>()
        reply["data"] = getUpiAccountJSON(accList)
        sendReply(data: reply)
    }
}



extension Array where Element: NSObject {
    func toArrayDictionary() -> TurboArrayDictionary {
        var localArray = TurboArrayDictionary()
        for object in self {
            localArray.append(object.toDictionary())
        }
        return localArray
    }
}

extension NSObject {
    func toDictionary() -> TurboDictionary {
      let mirror = Mirror(reflecting: self)
      let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (label:String?, value:Any) -> (String, Any)? in
        guard let label = label else { return nil }
        return (label, value)
      }).compactMap { $0 })
      return dict
    }
}
