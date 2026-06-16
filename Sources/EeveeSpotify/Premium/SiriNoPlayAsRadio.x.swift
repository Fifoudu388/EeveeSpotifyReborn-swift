import Orion
import Intents

class INMediaItemHook: ClassHook<INMediaItem> {
    typealias Group = BasePremiumPatchingGroup
    
    func identifier() -> String {
        var identifier = orig.identifier()
        
        if identifier.contains("play-command") {
            let components = identifier.components(separatedBy: ":")
            
            guard
                components.indices.contains(2),
                let jsonData = Data(base64Encoded: components[2]),
                let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
            else { return identifier }
                
            if let feedbackDetails = json["feedback_details"] as? [String: Any],
               feedbackDetails["restriction"] as? String == "play-as-radio",
               var context = json["context"] as? [String: Any],
               let urlString = context["url"] as? String
            {
                context["url"] = urlString.removeMatches(":station")
                
                var mutableJson = json
                mutableJson["context"] = context
                
                if let newData = try? JSONSerialization.data(withJSONObject: mutableJson) {
                    identifier = "spotify:play-command:\(newData.base64EncodedString())"
                }
            }
        }
        
        return identifier
    }
}
