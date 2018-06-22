import Foundation

/**
 A visual instruction banner contains all the information necessary for creating a visual cue about a given `RouteStep`.
 */
@objc(MBVisualInstructionBanner)
open class VisualInstructionBanner: NSObject, NSSecureCoding {
    
    /**
     The distance at which the visual instruction should be shown, measured in meters from the beginning of the step.
     */
    @objc public let distanceAlongStep: CLLocationDistance

    /**
     The most important information to convey to the user about the `RouteStep`.
     */
    @objc public var primaryInstruction: VisualInstruction
    
    /**
     Less important details about the `RouteStep`.
     */
    @objc public let secondaryInstruction: VisualInstruction?
    
    /**
     Which side of a bidirectional road the driver should drive on, also known as the rule of the road.
     */
    @objc public var drivingSide: DrivingSide
    
    /**
     Initializes a new visual instruction banner object based on the given JSON dictionary representation and a driving side.
     
     - parameter json: A JSON object that conforms to the [primary or secondary banner](https://www.mapbox.com/api-documentation/#banner-instruction-object) format described in the Directions API documentation.
     - parameter drivingSide: The side of the road the user should drive on. This value should be consistent with the containing route step.
     */
    @objc(initWithJSON:drivingSide:)
    public convenience init(json: [String: Any], drivingSide: DrivingSide) {
        let distanceAlongStep = json["distanceAlongGeometry"] as! CLLocationDistance
        
        let primary = json["primary"] as! JSONDictionary
        let secondary = json["secondary"] as? JSONDictionary
        
        let primaryInstruction = VisualInstruction(json: primary)
        var secondaryInstruction: VisualInstruction? = nil
        if let secondary = secondary {
            secondaryInstruction = VisualInstruction(json: secondary)
        }
        
        self.init(distanceAlongStep: distanceAlongStep, primaryInstruction: primaryInstruction, secondaryInstruction: secondaryInstruction, drivingSide: drivingSide)
    }
    
    /**
     Initializes a new visual instruction banner object that displays the given information.
     
     - parameter distanceAlongStep: The distance at which the visual instruction should be shown, measured in meters from the beginning of the step.
     - parameter primaryInstruction: The most important information to convey to the user about the `RouteStep`.
     - parameter secondaryInstruction: Less important details about the `RouteStep`.
     - parameter drivingSide: Which side of a bidirectional road the driver should drive on.
     */
    @objc public init(distanceAlongStep: CLLocationDistance, primaryInstruction: VisualInstruction, secondaryInstruction: VisualInstruction?, drivingSide: DrivingSide) {
        self.distanceAlongStep = distanceAlongStep
        self.primaryInstruction = primaryInstruction
        self.secondaryInstruction = secondaryInstruction
        self.drivingSide = drivingSide
    }
    
    public required init?(coder decoder: NSCoder) {
        distanceAlongStep = decoder.decodeDouble(forKey: "distanceAlongStep")
        
        if let drivingSideDescription = decoder.decodeObject(of: NSString.self, forKey: "drivingSide") as String?, let drivingSide = DrivingSide(description: drivingSideDescription) {
            self.drivingSide = drivingSide
        } else {
            self.drivingSide = .right
        }
        
        guard let primaryInstruction = decoder.decodeObject(of: VisualInstruction.self, forKey: "primary") else {
            return nil
        }
        self.primaryInstruction = primaryInstruction
        self.secondaryInstruction = decoder.decodeObject(of: VisualInstruction.self, forKey: "secondary")
    }
    
    open static var supportsSecureCoding = true
    
    public func encode(with coder: NSCoder) {
        coder.encode(distanceAlongStep, forKey: "distanceAlongStep")
        coder.encode(primaryInstruction, forKey: "primary")
        coder.encode(secondaryInstruction, forKey: "secondary")
        coder.encode(drivingSide, forKey: "drivingSide")
    }
}
