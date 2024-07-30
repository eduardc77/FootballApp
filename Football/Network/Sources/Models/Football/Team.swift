
public struct Team: Decodable {
    public let id: Int
    public let sportId: Int?
    public let countryId: Int?
    public let venueId: Int?
    public let gender: String
    public let name: String
    public let shortCode: String?
    public let imagePath: String
    public let founded: Int?
    public let type: String
    public let placeholder: Bool
    public let lastPlayedAt: String?
}

public struct TeamsResponseModel: Decodable {
    public let data: [Team]
    public let pagination: Pagination
    public let subscription: [Subscription]
    public let rateLimit: RateLimit
    public let timezone: String
}
