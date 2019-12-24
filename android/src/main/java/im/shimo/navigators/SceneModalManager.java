package im.shimo.navigators;

import android.view.View;

import androidx.annotation.NonNull;

import com.facebook.react.module.annotations.ReactModule;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;

import java.util.List;

@ReactModule(name = SceneModalManager.REACT_CLASS)
public class SceneModalManager extends ViewGroupManager<SceneModal> {

    static final String REACT_CLASS = "RNNativeModalNavigator";
    private static final String TAG = "SceneModalManager";


    @NonNull
    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @NonNull
    @Override
    protected SceneModal createViewInstance(@NonNull ThemedReactContext reactContext) {
        return new SceneModal(reactContext);
    }

    @Override
    public void addView(SceneModal parent, View child, int index) {
        if (!(child instanceof Scene)) {
            throw new IllegalArgumentException("Attempt attach child that is not of type RNScenes");
        }
        parent.addScene((Scene) child, index);
    }

    @Override
    public void addViews(SceneModal parent, List<View> views) {
        super.addViews(parent, views);
    }

    @Override
    public void removeViewAt(SceneModal parent, int index) {
        parent.removeSceneAt(index);
    }

    @Override
    public int getChildCount(SceneModal parent) {
        return parent.getSceneCount();
    }

    @Override
    public View getChildAt(SceneModal parent, int index) {
        return parent.getSceneAt(index);
    }

    @Override
    public boolean needsCustomLayoutForChildren() {
        return true;
    }
}
