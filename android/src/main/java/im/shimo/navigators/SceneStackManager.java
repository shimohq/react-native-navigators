package im.shimo.navigators;

import androidx.annotation.NonNull;

import com.facebook.react.module.annotations.ReactModule;

@ReactModule(name = SceneStackManager.REACT_CLASS)
public class SceneStackManager extends SceneModalManager {

    static final String REACT_CLASS = "RNNativeStackNavigator";

    @NonNull
    @Override
    public String getName() {
        return REACT_CLASS;
    }
}
