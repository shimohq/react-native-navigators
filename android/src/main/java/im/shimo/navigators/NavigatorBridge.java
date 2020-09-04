package im.shimo.navigators;

public class NavigatorBridge {
    private NavigatorBridgeDelegate mNavigatorBridgeDelegate;
    private static NavigatorBridge INSTANCE;

    public static NavigatorBridge getInstance() {
        if (INSTANCE == null) {
            synchronized (NavigatorBridge.class) {
                if (INSTANCE == null) {
                    INSTANCE = new NavigatorBridge();
                }
            }
        }
        return INSTANCE;
    }

    public NavigatorBridgeDelegate getNavigatorBridgeDelegate() {
        return mNavigatorBridgeDelegate;
    }

    public void setNavigatorBridgeDelegate(NavigatorBridgeDelegate navigatorBridgeDelegate) {
        mNavigatorBridgeDelegate = navigatorBridgeDelegate;
    }

    public interface NavigatorBridgeDelegate {
        boolean isKeyboardShowing();
    }
}
