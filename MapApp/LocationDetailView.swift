//
//  LocationDetailView.swift
//  MapApp
//
//  Created by Nguyễn Khang Hữu on 28/02/2024.
//

import SwiftUI
import MapKit
struct LocationDetailView: View {
    @Binding var mapSelection: MKMapItem?
    @State var show: Bool = false
    @State private var lookArroundScreen: MKLookAroundScene?
    @Binding var getDirections : Bool
    var body: some View {
        VStack{
            HStack{
                VStack(alignment: .leading){
                    Text(mapSelection?.placemark.name ?? "")
                        .font(.title)
                        .fontWeight(.semibold)
                    Text(mapSelection?.placemark.title ?? "")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                        .lineLimit(12)
                        .padding(.trailing)
                }
                Spacer()
                Button{
                    show.toggle()
                    mapSelection = nil
                }label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 24,height: 24)
                        .foregroundStyle(.gray , Color(.systemGray6))
                }
            }
            if let scene = lookArroundScreen{
                LookAroundPreview(initialScene: scene)
                    .frame(height: 200)
                    .cornerRadius(15)
                    .padding()
            }
            else{
                ContentUnavailableView("No preview available", systemImage:"eye.slash")
            }
            HStack{
                Button(
                    action: {
                        if let mapSelection{
                            mapSelection.openInMaps()
                        }
                    },
                    label: {
                        Text("Open in map")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 140,height: 48)
                            .background(.green)
                            .cornerRadius(12)
                    }
                )
                
                Button {
                    getDirections = true
                    show = false
                } label: {
                    Text("Open in map")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 140,height: 48)
                        .background(.blue)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal)
        }
        .onAppear{
            print("DEBUG: Did call on appear")
            fetchLookArroundPreview()
        }
        .onChange(of: mapSelection) { oldValue, newValue in
            print("DEBUG: Did call on change")
            fetchLookArroundPreview()
        }
    }
}

extension LocationDetailView{
    func fetchLookArroundPreview(){
        if let mapSelection{
            lookArroundScreen = nil
            Task{
                let request = MKLookAroundSceneRequest(mapItem: mapSelection)
                lookArroundScreen = try?await request.scene
            }
        }
    }
}

#Preview {
    LocationDetailView(mapSelection: .constant(nil), getDirections: .constant(false))
}
