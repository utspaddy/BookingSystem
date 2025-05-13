import SwiftUI

class BookingViewModel: ObservableObject {
    @Published var availableVenues: [Venue] = []
    @Published var userBookings: [Booking] = []
    @Published var selectedSeats: [String] = []
    @Published var selectedDate = Date()
    @Published var selectedTime = ""
    @Published var errorMessage: String?
    
    init() {
        loadSampleData()
    }
    
    private func loadSampleData() {
        availableVenues = [
            Venue(
                id: "cinema1",
                name: "Starlight Cinema",
                type: .cinema,
                seatLayout: SeatLayout(rows: 6, columns: 8, unavailableSeats: ["A3", "B5", "C2"]),
                availableTimeSlots: ["10:00", "13:00", "16:00", "19:00", "22:00"],
                maxSeatsPerBooking: 8,
                basePrice: 12.99,
                imageName: "popcorn"
            ),
            Venue(
                id: "rest1",
                name: "Gourmet Restaurant",
                type: .restaurant,
                seatLayout: SeatLayout(rows: 4, columns: 6, unavailableSeats: ["A1", "B3"]),
                availableTimeSlots: ["11:00", "12:30", "14:00", "15:30", "17:00", "19:00", "20:30"],
                maxSeatsPerBooking: 6,
                basePrice: 25.00,
                imageName: "fork.knife"
            )
        ]
        
        userBookings = [
            Booking(
                userId: "user1",
                venueId: "cinema1",
                seatNumbers: ["A5", "A6"],
                bookingDate: Date(),
                bookingTime: "19:00",
                status: .confirmed,
                price: 25.98
            )
        ]
    }
    
    func validateBooking(for venue: Venue) throws {
        guard !selectedSeats.isEmpty else {
            throw BookingError.noSeatsSelected
        }
        
        guard selectedDate >= Calendar.current.startOfDay(for: Date()) else {
            throw BookingError.invalidDate
        }
        
        guard selectedSeats.count <= venue.maxSeatsPerBooking else {
            throw BookingError.maxSeatsExceeded(venue.maxSeatsPerBooking)
        }
        
        // In real app, check against server for seat conflicts
        let conflictingSeats = selectedSeats.filter { seat in
            !venue.seatLayout.isSeatAvailable(seat) || 
            userBookings.contains { booking in
                booking.venueId == venue.id &&
                booking.seatNumbers.contains(seat) &&
                booking.bookingDate == selectedDate &&
                booking.bookingTime == selectedTime &&
                booking.status == .confirmed
            }
        }
        
        guard conflictingSeats.isEmpty else {
            throw BookingError.seatConflict
        }
    }
    
    func createBooking(userId: String, venue: Venue) -> Bool {
        do {
            try validateBooking(for: venue)
            
            let totalPrice = venue.basePrice * Double(selectedSeats.count)
            let newBooking = Booking(
                userId: userId,
                venueId: venue.id,
                seatNumbers: selectedSeats,
                bookingDate: selectedDate,
                bookingTime: selectedTime,
                status: .confirmed,
                price: totalPrice
            )
            
            userBookings.append(newBooking)
            selectedSeats = []
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    func cancelBooking(bookingId: UUID) -> Bool {
        guard let index = userBookings.firstIndex(where: { $0.id == bookingId }) else {
            return false
        }
        
        userBookings[index].updateStatus(.cancelled)
        return true
    }
}