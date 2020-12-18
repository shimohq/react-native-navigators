package im.shimo.navigators;

import android.view.View;

import androidx.annotation.NonNull;

import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;

import java.util.List;

/**
 * Created by jiang on 2019-11-19
 */

public class SceneCardManager extends ViewGroupManager<SceneCard> {

    static final String REACT_CLASS = "RNNativeCardNavigator";

    @NonNull
    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @NonNull
    @Override
    protected SceneCard createViewInstance(@NonNull ThemedReactContext reactContext) {
        return new SceneCard(reactContext);
    }

    @Override
    public void addView(SceneCard parent, View child, int index) {
        if (!(child instanceof Scene)) {
            throw new IllegalArgumentException("Attempt attach child that is not of type RNScenes");
        }
        parent.addScene((Scene) child, index);
    }

    @Override
    public void addViews(SceneCard parent, List<View> views) {
        super.addViews(parent, views);
    }

    @Override
    public void removeViewAt(SceneCard parent, int index) {
        parent.removeSceneAt(index);
    }

    @Override
    public int getChildCount(SceneCard parent) {
        return parent.getSceneCount();
    }

    @Override
    public View getChildAt(SceneCard parent, int index) {
        return parent.getSceneAt(index);
    }

    @Override
    public boolean needsCustomLayoutForChildren() {
        return true;
    }
}
