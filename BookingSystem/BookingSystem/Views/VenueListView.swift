import SwiftUI

struct VenueListView: View {
    @EnvironmentObject private var viewModel: BookingViewModel
    @State private var showingBookingView = false
    @State private var selectedVenue: Venue?
    
    var body: some View {
        NavigationStack {
            List(viewModel.availableVenues) { venue in
                VenueRow(venue: venue)
                    .onTapGesture {
                        selectedVenue = venue
                        showingBookingView = true
                    }
            }
            .navigationTitle("Select Venue")
            .sheet(isPresented: $showingBookingView) {
                if let venue = selectedVenue {
                    BookingView(venue: venue)
                        .environmentObject(viewModel)
                }
            }
        }
    }
}

struct VenueRow: View {
    let venue: Venue
    
    var body: some View {
        HStack {
            Image(systemName: venue.type.icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading) {
                Text(venue.name)
                    .font(.headline)
                Text(venue.type.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(venue.seatPrice)
                .font(.caption)
        }
        .padding(.vertical, 8)
    }
}