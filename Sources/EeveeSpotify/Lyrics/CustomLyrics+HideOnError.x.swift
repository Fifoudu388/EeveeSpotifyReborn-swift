import Orion
import UIKit

class ErrorViewControllerHook: ClassHook<UIViewController> {
    typealias Group = BaseLyricsGroup
    
    static var targetName: String {
        switch EeveeSpotify.hookTarget {
        case .lastAvailableiOS14: return "Lyrics_CoreImpl.ErrorViewController"
        default: return "Lyrics_NPVCommunicatorImpl.ErrorViewController"
        }
    }
    
    func loadView() {
        orig.loadView()
        
        guard UserDefaults.lyricsOptions.hideOnError else {
            return
        }
        
        if let controller = nowPlayingScrollViewController {
            controller.dataSource.activeProviders.removeAll {
                NSStringFromClass(type(of: $0)) == HookTargetNameHelper.lyricsScrollProvider
            }
            
            controller.collectionView().reloadData()
        }
        else if let controller = npvScrollViewController, let scrollDS = scrollDataSource {
            guard let lyricsProviderIndex = scrollDS.activeProviders.firstIndex(where: {
                NSStringFromClass(type(of: $0)) == HookTargetNameHelper.lyricsScrollProvider
            }) else { return }
            
            let collectionView = controller.collectionView()
            guard let ds = collectionView.dataSource else { return }
            let dataSource = Ivars<__UIDiffableDataSource>(ds)._impl
            
            let itemIdentifiers = dataSource.itemIdentifiers()
            guard lyricsProviderIndex < itemIdentifiers.count else { return }
            let lyricsProviderItemIdentifier = itemIdentifiers[lyricsProviderIndex]
            
            dataSource.deleteItemsWithIdentifiers([lyricsProviderItemIdentifier])
        }
    }
}
