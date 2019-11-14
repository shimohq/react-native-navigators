package im.shimo.navigators;

import android.util.Log;
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

        Log.d(TAG, "addView() called with: parent = [" + parent + "], child = [" + child + "], index = [" + index + "]");
    }

    @Override
    public void addViews(SceneModal parent, List<View> views) {
        Log.d(TAG, "addViews() called with: parent = [" + parent + "], views = [" + views + "]");
        super.addViews(parent, views);
    }

    @Override
    public void removeViewAt(SceneModal parent, int index) {
        Log.d(TAG, "removeViewAt() called with: parent = [" + parent + "], index = [" + index + "]");
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


}
