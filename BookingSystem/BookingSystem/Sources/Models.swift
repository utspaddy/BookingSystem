import Foundation

struct Booking: Identifiable, Codable {
    let id: UUID
    let userId: String
    let venueId: String
    let seatNumbers: [String]
    let bookingDate: Date
    let bookingTime: String
    private(set) var status: BookingStatus
    let price: Double
    
    init(
        id: UUID = UUID(),
        userId: String,
        venueId: String,
        seatNumbers: [String],
        bookingDate: Date,
        bookingTime: String,
        status: BookingStatus = .confirmed,
        price: Double
    ) {
        self.id = id
        self.userId = userId
        self.venueId = venueId
        self.seatNumbers = seatNumbers
        self.bookingDate = bookingDate
        self.bookingTime = bookingTime
        self.status = status
        self.price = price
    }
    
    mutating func updateStatus(_ newStatus: BookingStatus) {
        status = newStatus
    }
}

enum BookingStatus: String, Codable, CaseIterable {
    case confirmed = "Confirmed"
    case cancelled = "Cancelled"
    case completed = "Completed"
}

struct Venue: Identifiable, Codable {
    let id: String
    let name: String
    let type: VenueType
    let seatLayout: SeatLayout
    let availableTimeSlots: [String]
    let maxSeatsPerBooking: Int
    let basePrice: Double
    let imageName: String
    
    var seatPrice: String {
        String(format: "$%.2f/seat", basePrice)
    }
}

struct SeatLayout: Codable {
    let rows: Int
    let columns: Int
    let unavailableSeats: [String]
    
    func isSeatAvailable(_ seatNumber: String) -> Bool {
        !unavailableSeats.contains(seatNumber)
    }
}

enum VenueType: String, Codable, CaseIterable {
    case restaurant = "Restaurant"
    case cinema = "Cinema"
    
    var icon: String {
        switch self {
        case .restaurant: return "fork.knife"
        case .cinema: return "film"
        }
    }
}

enum BookingError: LocalizedError {
    case noSeatsSelected
    case invalidDate
    case seatConflict
    case maxSeatsExceeded(Int)
    
    var errorDescription: String? {
        switch self {
        case .noSeatsSelected:
            return "Please select at least one seat"
        case .invalidDate:
            return "Selected date must be in the future"
        case .seatConflict:
            return "One or more seats are already booked"
        case .maxSeatsExceeded(let max):
            return "Maximum \(max) seats per booking"
        }
    }
}