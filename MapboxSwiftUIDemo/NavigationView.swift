//
//  NavigationView.swift
//  DriveChat
//
//  Created by Microapples on 9/21/20.
//  Copyright © 2020 Programmer7. All rights reserved.
//
import SwiftUI
import Mapbox
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections

struct MapNavigationView: UIViewControllerRepresentable {
    @Binding var route: Route?
    @Binding var routeOptions: NavigationRouteOptions?
    @Binding var showNavigation:Bool

    func makeCoordinator() -> MapNavigationView.Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<MapNavigationView>) -> NavigationViewController {
        // Initiate the navigation view controller
        let navigationViewController = NavigationViewController(for: route!, routeIndex: 0, routeOptions: routeOptions!)
        navigationViewController.modalPresentationStyle = .none
        navigationViewController.delegate = context.coordinator
        
        return navigationViewController
    }
    
    func updateUIViewController(_ uiViewController: NavigationViewController, context: UIViewControllerRepresentableContext<MapNavigationView>) {
        // do nothing
    }
    
    class Coordinator: NSObject, NavigationViewControllerDelegate {
        var control: MapNavigationView
        var realRoute: Route?
        
        init(_ control: MapNavigationView) {
            self.control = control
            self.realRoute = nil
        }
        
        func navigationViewControllerDidDismiss(_ navigationViewController: NavigationViewController, byCanceling canceled: Bool) {
            
            navigationViewController.dismiss(animated: true, completion: nil)
            self.control.showNavigation = false
            navigationViewController.navigationService.stop()
        }
    }
}
