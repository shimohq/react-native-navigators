package im.shimo.navigators;

import androidx.annotation.NonNull;

import com.facebook.react.uimanager.LayoutShadowNode;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;

public class SplitPlaceholderManager extends ViewGroupManager<SplitPlaceholder> {
  @NonNull
  @Override
  public String getName() {
    return "RNNativeSplitPlaceholder";
  }

  @NonNull
  @Override
  protected SplitPlaceholder createViewInstance(@NonNull ThemedReactContext reactContext) {
    return new SplitPlaceholder(reactContext);
  }

  @Override
  public LayoutShadowNode createShadowNodeInstance() {
    return new SceneShadowNode();
  }

  @Override
  public Class<? extends LayoutShadowNode> getShadowNodeClass() {
    return SceneShadowNode.class;
  }
}
