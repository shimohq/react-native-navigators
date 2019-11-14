package im.shimo.navigators;

import android.util.Log;
import android.view.View;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.JSApplicationCausedNativeException;
import com.facebook.react.module.annotations.ReactModule;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;
import com.facebook.react.uimanager.annotations.ReactProp;

@ReactModule(name = SceneStackHeaderManager.REACT_CLASS)
public class SceneStackHeaderManager extends ViewGroupManager<SceneStackHeader> {

    static final String REACT_CLASS = "RNNativeStackHeader";
    private static final String TAG = "SceneStackHeaderManager";

    @NonNull
    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @NonNull
    @Override
    protected SceneStackHeader createViewInstance(@NonNull ThemedReactContext reactContext) {
        return new SceneStackHeader(reactContext);
    }

    @Override
    public void addView(SceneStackHeader parent, View child, int index) {
        if (!(child instanceof SceneStackHeaderItem)) {
            throw new JSApplicationCausedNativeException("Config children should be of type " + SceneStackHeaderItemManager.REACT_CLASS);
        }
        parent.addHeaderItemView((SceneStackHeaderItem) child, index);
        Log.d(TAG, "addView() called with: parent = [" + parent + "], child = [" + child + "], index = [" + index + "]");
    }

    @Override
    public void removeViewAt(SceneStackHeader parent, int index) {
        parent.removeHeaderItemView(index);
        Log.d(TAG, "removeViewAt() called with: parent = [" + parent + "], index = [" + index + "]");
    }

    @Override
    public int getChildCount(SceneStackHeader parent) {
        return parent.getHeaderItemCount();
    }

    @Override
    public View getChildAt(SceneStackHeader parent, int index) {
        return parent.getHeaderItem(index);
    }

    @Override
    public boolean needsCustomLayoutForChildren() {
        return true;
    }

    @ReactProp(name = "headerBackgroundColor", customType = "Color")
    public void setHeaderBackgroundColor(SceneStackHeader header, int color) {
        header.setBackgroundColor(color);
    }

    @ReactProp(name = "headerBorderColor", customType = "Color")
    public void setHeaderBorderColor(SceneStackHeader header, int color) {
        header.setBottomBorderColor(color);
        Log.d(TAG, "setHeaderBorderColor() called with: config = [" + header + "], color = [" + color + "]");
    }

}
