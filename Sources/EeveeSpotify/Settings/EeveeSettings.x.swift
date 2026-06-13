#if false

import Orion
import SwiftUI
import UIKit

class SettingsListViewControllerHook: ClassHook<UIViewController> {
    static let targetName = "_TtC21Settings_PlatformImpl26SettingsListViewController"

    func viewWillAppear(_ animated: Bool) {
        orig.viewWillAppear(animated)

        guard
            let navigationController = target.navigationController,
            navigationController.viewControllers.first == target,
            target.navigationItem.rightBarButtonItem == nil
        else { return }

        let button = UIButton()

        button.setImage(
            BundleHelper.shared.uiImage("github").withRenderingMode(.alwaysOriginal),
            for: .normal
        )

        button.addTarget(
            self,
            action: #selector(openEeveeSettings),
            for: .touchUpInside
        )

        let menuBarItem = UIBarButtonItem(customView: button)

        menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 22).isActive = true
        menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 22).isActive = true

        target.navigationItem.rightBarButtonItem = menuBarItem
    }

    @objc func openEeveeSettings() {
        guard let navigationController = target.navigationController else { return }

        let eeveeSettingsController = EeveeSettingsViewController(
            target.view.bounds,
            settingsView: AnyView(EeveeSettingsView(navigationController: navigationController)),
            navigationTitle: "EeveeSpotify"
        )

        let button = UIButton()

        button.setImage(
            BundleHelper.shared.uiImage("github").withRenderingMode(.alwaysOriginal),
            for: .normal
        )

        button.addTarget(
            eeveeSettingsController,
            action: #selector(eeveeSettingsController.openRepositoryUrl(_:)),
            for: .touchUpInside
        )

        let menuBarItem = UIBarButtonItem(customView: button)

        menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 22).isActive = true
        menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 22).isActive = true

        eeveeSettingsController.navigationItem.rightBarButtonItem = menuBarItem

        navigationController.pushViewController(
            eeveeSettingsController,
            animated: true
        )
    }
}

#endif
