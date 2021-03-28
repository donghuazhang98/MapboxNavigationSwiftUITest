import SwiftUI
import Mapbox
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections

extension MGLPointAnnotation {
    convenience init(title: String, coordinate: CLLocationCoordinate2D) {
        self.init()
        self.title = title
        self.coordinate = coordinate
    }
}

struct MapView: UIViewRepresentable {
    @Binding var annotations: [MGLPointAnnotation]
    @Binding var route: Route?
    @Binding var routeOptions: NavigationRouteOptions?
    @Binding var showNavigation: Bool
    
    private let mapView: NavigationMapView = NavigationMapView(frame: .zero, styleURL: MGLStyle.streetsStyleURL)
    
    // MARK: - Configuring UIViewRepresentable protocol
    
    func makeUIView(context: UIViewRepresentableContext<MapView>) -> MGLMapView {
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.follow, animated: false, completionHandler: nil)
        
        // Add a gesture recognizer to the map view
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(MapView.Coordinator.didLongPress(_:)))
        mapView.addGestureRecognizer(longPress)
        
        return mapView
    }
    
    func updateUIView(_ uiView: MGLMapView, context: UIViewRepresentableContext<MapView>) {
        updateAnnotations()
    }
    
    func makeCoordinator() -> MapView.Coordinator {
        Coordinator(self)
    }
    
    // MARK: - Configuring MGLMapView
    
    func styleURL(_ styleURL: URL) -> MapView {
        mapView.styleURL = styleURL
        return self
    }
    
    func centerCoordinate(_ centerCoordinate: CLLocationCoordinate2D) -> MapView {
        mapView.centerCoordinate = centerCoordinate
        return self
    }
    
    func zoomLevel(_ zoomLevel: Double) -> MapView {
        mapView.zoomLevel = zoomLevel
        return self
    }
    
    private func updateAnnotations() {
        if let currentAnnotations = mapView.annotations {
            mapView.removeAnnotations(currentAnnotations)
        }
        mapView.addAnnotations(annotations)
    }
    
    // MARK: - Implementing MGLMapViewDelegate
    
    final class Coordinator: NSObject, MGLMapViewDelegate {
        var control: MapView
        var route: Route?
        var routeOptions: NavigationRouteOptions?
        
        init(_ control: MapView) {
            self.control = control
        }
        
        func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
            // Add a gesture recognizer to the map view
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.didLongPress(_:)))
            self.control.mapView.addGestureRecognizer(longPress)
        }
        
        func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
            return nil
        }
         
        // Implement the delegate method that allows annotations to show callouts when tapped
        func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
            return true
        }
        
        // Present the navigation view controller when the callout is selected
        func mapView(_ mapView: MGLMapView, tapOnCalloutFor annotation: MGLAnnotation) {
            self.control.showNavigation = true
        }
        
        @objc func didLongPress(_ sender: UILongPressGestureRecognizer) {
            guard sender.state == .began else { return }
            
            // Converts point where user did a long press to map coordinates
            let point = sender.location(in: self.control.mapView)
            let coordinate = self.control.mapView.convert(point, toCoordinateFrom: self.control.mapView)
            
            if let origin = self.control.mapView.userLocation?.coordinate {
                // Calculate the route from the user's location to the set destination
                calculateRoute(from: origin, to: coordinate)
            } else {
                print("Failed to get user location, make sure to allow location access for this application.")
            }
        }
        
        // Calculate route to be used for navigation
        func calculateRoute(from origin: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
            // Coordinate accuracy is how close the route must come to the waypoint in order to be considered viable. It is measured in meters. A negative value indicates that the route is viable regardless of how far the route is from the waypoint.
            let origin = Waypoint(coordinate: origin, coordinateAccuracy: -1, name: "Start")
            let destination = Waypoint(coordinate: destination, coordinateAccuracy: -1, name: "Finish")
            
            // Specify that the route is intended for automobiles avoiding traffic
            let routeOptions = NavigationRouteOptions(waypoints: [origin, destination], profileIdentifier: .automobileAvoidingTraffic)
            
            // Generate the route object and draw it on the map
            Directions.shared.calculate(routeOptions) { [weak self] (session, result) in
                switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                case .success(let response):
                    guard let route = response.routes?.first, let strongSelf = self else {
                        return
                    }
                    
                    strongSelf.control.route = route
                    strongSelf.control.routeOptions = routeOptions
                    
                    // Draw the route on the map after creating it
                    strongSelf.control.mapView.show([route])
                    
                    // Show destination waypoint on the map
                    strongSelf.control.mapView.showWaypoints(on: route)
                    
                    // Display callout view on destination annotation
                    if let annotation = strongSelf.control.mapView.annotations?.first as? MGLPointAnnotation {
                        annotation.title = "Start navigation"
                        strongSelf.control.mapView.selectAnnotation(annotation, animated: true, completionHandler: nil)
                    }
                }
            }
        }
        
    }
    
}


