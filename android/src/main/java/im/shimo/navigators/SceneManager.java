package im.shimo.navigators;

import android.text.TextUtils;
import android.view.View;

import androidx.annotation.NonNull;

import com.facebook.react.common.MapBuilder;
import com.facebook.react.module.annotations.ReactModule;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;
import com.facebook.react.uimanager.annotations.ReactProp;

import java.util.Map;

import javax.annotation.Nullable;

import im.shimo.navigators.event.DidBlurEvent;
import im.shimo.navigators.event.DidFocusEvent;
import im.shimo.navigators.event.WillBlurEvent;
import im.shimo.navigators.event.WillFocusEvent;

@ReactModule(name = SceneManager.REACT_CLASS)
public class SceneManager extends ViewGroupManager<Scene> {

    protected static final String REACT_CLASS = "RNNativeScene";
    private static final String TAG = "SceneManager";

    @NonNull
    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @NonNull
    @Override
    protected Scene createViewInstance(@NonNull ThemedReactContext reactContext) {
        return new Scene(reactContext);
    }

    /**
     * 切换 scene 的动画
     * <p>
     * "default": 默认动画，stack 显示的时候从右往左，隐藏的时候从左往右。modal card 显示的时候从下往上，隐藏的时候从上往下
     * "none": 无动画
     * "slideFromTop": 显示的时候从上往下，隐藏的时候从下往上
     * "slideFromRight": 显示的时候从右往左，隐藏的时候从左往右
     * "slideFromBottom": 显示的时候从下往上，隐藏的时候从上往下
     * "slideFromLeft": 显示的时候从左往右，隐藏的时候从右往左
     * <p>
     * 默认：default
     */
    @ReactProp(name = "transition")
    public void transition(Scene view, String animation) {
        if (TextUtils.isEmpty(animation) || "default".equals(animation)) {
            view.setStackAnimation(Scene.StackAnimation.DEFAULT);
        } else if ("none".equals(animation)) {
            view.setStackAnimation(Scene.StackAnimation.NONE);
        } else if ("slideFromTop".equals(animation)) {
            view.setStackAnimation(Scene.StackAnimation.SLIDE_FROM_TOP);
        } else if ("slideFromRight".equals(animation)) {
            view.setStackAnimation(Scene.StackAnimation.SLIDE_FROM_RIGHT);
        } else if ("slideFromBottom".equals(animation)) {
            view.setStackAnimation(Scene.StackAnimation.SLIDE_FROM_BOTTOM);
        } else if ("slideFromLeft".equals(animation)) {
            view.setStackAnimation(Scene.StackAnimation.SLIDE_FROM_LEFT);
        }
    }

    /**
     * 是否开启手势返回
     * 暂不实现
     *
     * @param view
     * @param enable
     */
    @ReactProp(name = "gestureEnabled")
    public void gestureEnabled(Scene view, boolean enable) {
    }

    //隐藏 Blur -> Focus
    //显示 Focus -> Blur

    /**
     * @param closing 是否关闭 scene
     * @return
     */
    @ReactProp(name = "closing")
    public void closing(Scene view, boolean closing) {
        view.setClosing(closing);
    }

    /**
     * 是否透明
     * <p>
     * YES:  scene 显示之后下层的 scene 不会移除。
     * NO:  scene 显示之后下层的 scene 会移除，有利于内存释放。
     * <p>
     * 不适用于 stack，因为 stack 默认 YES，不可修改
     * 适用于 modal  Card：
     * <p>
     * 默认: NO
     *
     * @param view
     * @param isTransparent
     */
    @ReactProp(name = "transparent")
    public void transparent(Scene view, boolean isTransparent) {
        view.setTransparent(isTransparent);
    }


    @Nullable
    @Override
    public Map<String, Object> getExportedCustomDirectEventTypeConstants() {
        return MapBuilder.<String, Object>of(
                WillFocusEvent.EVENT_NAME, MapBuilder.of("registrationName", WillFocusEvent.EVENT_NAME),
                DidFocusEvent.EVENT_NAME, MapBuilder.of("registrationName", DidFocusEvent.EVENT_NAME),
                WillBlurEvent.EVENT_NAME, MapBuilder.of("registrationName", WillBlurEvent.EVENT_NAME),
                DidBlurEvent.EVENT_NAME, MapBuilder.of("registrationName", DidBlurEvent.EVENT_NAME)
        );
    }

    @Override
    public void removeViewAt(Scene parent, int index) {
        super.removeViewAt(parent, index);
//        View view = parent.getChildAt(index);
//        if (view instanceof SceneStackHeader) {
//            ViewParent sceneParent = parent.getParent();
//            if (sceneParent instanceof SceneStack) {
////                ((SceneStack) sceneParent).removeHeader();
//            }
//        } else {
//            parent.removeView(view);
//        }
    }


    @Override
    public void addView(Scene parent, View child, int index) {
        super.addView(parent,child,index);
//        if (child instanceof SceneStackHeader) {
//            ViewParent sceneParent = parent.getParent();
//            if (sceneParent instanceof SceneStack) {
////                ((SceneStack) sceneParent).setHeader(((SceneStackHeader) child));
//            }
//        } else {
//            super.addView(parent, child, index);
//        }
    }
}
