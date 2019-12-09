package im.shimo.navigators;

import android.view.View;

import androidx.annotation.NonNull;

import com.facebook.react.module.annotations.ReactModule;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;

import java.util.List;

@ReactModule(name = SceneStackManager.REACT_CLASS)
public class SceneStackManager extends ViewGroupManager<SceneStack> {

    static final String REACT_CLASS = "RNNativeStackNavigator";

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
            throw new IllegalArgumentException("Attempt attach child that is not of type RNScenes");
        }
        parent.addScene((Scene) child, index);
    }

    @Override
    public void addViews(SceneStack parent, List<View> views) {
        super.addViews(parent, views);
    }

    @Override
    public void removeViewAt(SceneStack parent, int index) {
        parent.removeSceneAt(index);
    }

    @Override
    public int getChildCount(SceneStack parent) {
        return parent.getSceneCount();
    }

    @Override
    public View getChildAt(SceneStack parent, int index) {
        return parent.getSceneAt(index);
    }
}
