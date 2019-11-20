package im.shimo.navigators;

import android.util.Log;
import android.view.View;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.module.annotations.ReactModule;
import com.facebook.react.uimanager.LayoutShadowNode;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.facebook.react.views.view.ReactViewGroup;
import com.facebook.react.views.view.ReactViewManager;

@ReactModule(name = SceneStackHeaderItemManager.REACT_CLASS)
public class SceneStackHeaderItemManager extends ReactViewManager {

    private static final String TAG = "SceneStackHeaderItem";

    private static class InnerShadowNode extends LayoutShadowNode {
        @Override
        public void setLocalData(Object data) {
            SceneStackHeaderItem.Measurements measurements = (SceneStackHeaderItem.Measurements) data;
            setStyleWidth(measurements.width);
            setStyleHeight(measurements.height);
        }
    }

    protected static final String REACT_CLASS = "RNNativeStackHeaderItem";

    @NonNull
    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @NonNull
    @Override
    public ReactViewGroup createViewInstance(ThemedReactContext context) {
        return new SceneStackHeaderItem(context);
    }

    @NonNull
    @Override
    public LayoutShadowNode createShadowNodeInstance(@NonNull ReactApplicationContext context) {
        return new InnerShadowNode();
    }

    @Override
    public void addView(ReactViewGroup parent, View child, int index) {
        super.addView(parent, child, index);
        Log.d(TAG, "addView() called with: parent = [" + parent + "], child = [" + child + "], index = [" + index + "]");
    }

    @Override
    public void removeViewAt(ReactViewGroup parent, int index) {
        super.removeViewAt(parent, index);
        Log.d(TAG, "removeViewAt() called with: parent = [" + parent + "], index = [" + index + "]");
    }

    @ReactProp(name = "type")
    public void setType(SceneStackHeaderItem view, String type) {
        if ("left".equals(type)) {
            view.setType(SceneStackHeaderItem.Type.LEFT);
        } else if ("center".equals(type)) {
            view.setType(SceneStackHeaderItem.Type.CENTER);
        } else if ("right".equals(type)) {
            view.setType(SceneStackHeaderItem.Type.RIGHT);
        }
    }
}
