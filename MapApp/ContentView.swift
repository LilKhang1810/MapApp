//
//  ContentView.swift
//  MapApp
//
//  Created by Nguyễn Khang Hữu on 28/02/2024.
//

import SwiftUI
import MapKit
struct ContentView: View {
    @State var cameraPosition: MapCameraPosition = .region(.userRegion)
    @State private var searchText = ""
    @State private var results = [MKMapItem]()
    @State private var mapSelection : MKMapItem?
    @State private var getDirections: Bool = false
    @State private var routeDisplaying = false
    @State private var route: MKRoute?
    @State private var routeDestination: MKMapItem?
    @State var showDetail = false
    var body: some View {
        Map(position: $cameraPosition,selection: $mapSelection){
            Annotation("My location", coordinate: .userLocation) {
                ZStack{
                    Circle()
                        .frame(width:32,height: 32)
                        .foregroundColor(.blue.opacity(0.25))
                    Circle()
                        .frame(width: 20,height: 20)
                        .foregroundColor(.white)
                    Circle()
                        .frame(width: 12,height: 12)
                        .foregroundColor(.blue)
                }
            }
            ForEach(results,id: \.self){item in
                if routeDisplaying{
                    if item == routeDestination{
                        let placemark = item.placemark
                        Marker(placemark.name ?? "", coordinate: placemark.coordinate)
                    }
                } else{
                    let placemark = item.placemark
                    Marker(placemark.name ?? "", coordinate: placemark.coordinate)
                }
            }
            if let route{
                MapPolyline(route.polyline)
                    .stroke(.blue,lineWidth: 5)
            }
        }
        .overlay(alignment: .top){
            TextField("Search for a location", text: $searchText)
                .font(.subheadline)
                .padding(12)
                .background(.white)
                .padding()
                .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
        }
        .onSubmit(of: .text) {
            Task{
                await searchPlace()
            }
        }
        .onChange(of: getDirections, { oldValue, newValue in
            if newValue{
                fetchRoute()
            }
            
        })
        .onChange(of: mapSelection, { oldValue, newValue in
            showDetail = newValue != nil
        })
        .sheet(isPresented: $showDetail, content: {
            LocationDetailView(mapSelection: $mapSelection,show: showDetail, getDirections: $getDirections)
                .presentationDetents([.height(340)])
                .presentationBackgroundInteraction(.enabled(upThrough: .height(340)))
                .presentationCornerRadius(12)
        })
        .mapControls {
            MapCompass()
            MapPitchToggle()
            MapUserLocationButton()
        }
    }
}


extension ContentView{
    func searchPlace() async{
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = .userRegion
        let results = try? await MKLocalSearch(request: request).start()
        self.results = results?.mapItems ?? []
    }
    func fetchRoute(){
        if let mapSelection{
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: .init(coordinate: .userLocation))
            request.destination = mapSelection
            Task{
                let result = try?await MKDirections(request: request).calculate()
                route = result?.routes.first
                routeDestination = mapSelection
                withAnimation(.snappy){
                    routeDisplaying = true
                    showDetail = false
                    if let rect = route?.polyline.boundingMapRect, routeDisplaying{
                        cameraPosition = .rect(rect)
                    }
                }
            }
        }
    }
}

extension CLLocationCoordinate2D{
    static var userLocation: CLLocationCoordinate2D{
        return .init(latitude: 25.774173, longitude: -80.19362)
    }
    
}
extension MKCoordinateRegion{
    static var userRegion: MKCoordinateRegion{
        return .init(center: .userLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
    }
}
#Preview {
    ContentView()
}
