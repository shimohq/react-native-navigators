package im.shimo.navigators;

public class SceneBridge {
    private SceneBridgeDelegate mSceneBridgeDelegate;
    private static SceneBridge INSTANCE;

    public static SceneBridge getInstance() {
        if (INSTANCE == null) {
            synchronized (SceneBridge.class) {
                if (INSTANCE == null) {
                    INSTANCE = new SceneBridge();
                }
            }
        }
        return INSTANCE;
    }

    public SceneBridgeDelegate getSceneBridgeDelegate() {
        return mSceneBridgeDelegate;
    }

    public void setSceneBridgeDelegate(SceneBridgeDelegate sceneBridgeDelegate) {
        mSceneBridgeDelegate = sceneBridgeDelegate;
    }

    public interface SceneBridgeDelegate {
        boolean isKeyboardShowing();
    }
}
