import SwiftUI
import Mapbox
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections

struct ContentView: View {
    @State var annotations: [MGLPointAnnotation] = [
    ]
    
    // Navigation route generated when select an annotation
    @State var route: Route?
    @State var routeOptions: NavigationRouteOptions?
    @State var showNavigation: Bool = false
    
    var body: some View {
        ZStack(alignment: .top) {
            MapView(annotations: $annotations, route: $route, routeOptions: $routeOptions, showNavigation: $showNavigation).zoomLevel(16)
            SearchBarViewController()
                .frame(width: 300, height: 40)
                .offset(y: 10)
            if showNavigation {
                MapNavigationView(route: $route, routeOptions: $routeOptions, showNavigation: $showNavigation)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
