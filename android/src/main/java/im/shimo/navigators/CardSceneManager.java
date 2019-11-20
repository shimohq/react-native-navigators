package im.shimo.navigators;

import androidx.annotation.NonNull;

/**
 * Created by jiang on 2019-11-19
 */

public class CardSceneManager extends SceneModalManager {

    static final String REACT_CLASS = "RNNativeCardNavigator";

    @NonNull
    @Override
    public String getName() {
        return REACT_CLASS;
    }

}
