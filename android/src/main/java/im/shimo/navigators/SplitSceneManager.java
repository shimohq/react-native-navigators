package im.shimo.navigators;

import android.util.Log;
import android.view.View;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.uimanager.LayoutShadowNode;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;
import com.facebook.react.uimanager.annotations.ReactProp;

public class SplitSceneManager extends ViewGroupManager<SplitScene> {

  private static final String TAG = "SplitSceneManager";

  @NonNull
  @Override
  public String getName() {
    return "RNNativeSplitNavigator";
  }

//  @Override
//  public LayoutShadowNode createShadowNodeInstance() {
//    return new SplitSceneShadowNode();
//  }
//
//  @Override
//  public Class<? extends LayoutShadowNode> getShadowNodeClass() {
//    return SplitSceneShadowNode.class;
//  }

  @NonNull
  @Override
  protected SplitScene createViewInstance(@NonNull ThemedReactContext reactContext) {
    return new SplitScene(reactContext);
  }

  @ReactProp(name = "splitRules")
  public void splitRules(SplitScene splitScene, ReadableArray rules) {
    splitScene.setSplitRules(rules);
  }

  @ReactProp(name = "isSplitFullScreen")
  public void setIsSplitFullScreen(SplitScene scene, boolean isSplitFullScreen){
    scene.setSplitFullScreen(isSplitFullScreen);
  }

  @Override
  public void addView(SplitScene parent, View child, int index) {
    if (!(child instanceof Scene)) {
      throw new IllegalArgumentException("Attempt attach child that is not of type RNScenes");
    }
    parent.addScene((Scene) child, index);
  }

  @Override
  public void removeViewAt(SplitScene parent, int index) {
    parent.removeSceneAt(index);
  }

  @Override
  public int getChildCount(SplitScene parent) {
    return parent.getSceneCount();
  }



  @Override
  public boolean needsCustomLayoutForChildren() {
    return true;
  }

}
