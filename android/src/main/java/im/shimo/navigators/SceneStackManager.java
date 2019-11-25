package im.shimo.navigators;

import android.util.Log;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;

import com.facebook.react.module.annotations.ReactModule;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;

@ReactModule(name = SceneStackManager.REACT_CLASS)
public class SceneStackManager extends ViewGroupManager<SceneStack> {

    static final String REACT_CLASS = "RNNativeStackNavigator";
    private static final String TAG = "SceneStackManager";

    @NonNull
    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @NonNull
    @Override
    protected SceneStack createViewInstance(@NonNull ThemedReactContext reactContext) {
        return new SceneStack(reactContext);
    }

    @Override
    public void addView(SceneStack parent, View child, int index) {
        if (!(child instanceof Scene)) {
            throw new IllegalArgumentException("Attempt attach child that is not of type Scene");
        }
        parent.addScene((Scene) child, index);
    }


    @Override
    public void removeViewAt(SceneStack parent, int index) {
        prepareOutTransition(parent.getSceneAt(index));
        parent.removeSceneAt(index);
    }


    private void prepareOutTransition(Scene scene) {
        startTransitionRecursive(scene);
    }

    private void startTransitionRecursive(ViewGroup parent) {
        for (int i = 0, size = parent.getChildCount(); i < size; i++) {
            View child = parent.getChildAt(i);
            parent.startViewTransition(child);
            if (child instanceof ViewGroup) {
                startTransitionRecursive((ViewGroup) child);
            }
        }
    }

    @Override
    public int getChildCount(SceneStack parent) {
        return parent.getSceneCount();
    }

    @Override
    public View getChildAt(SceneStack parent, int index) {
        return parent.getSceneAt(index);
    }

    @Override
    public boolean needsCustomLayoutForChildren() {
        return true;
    }
}
