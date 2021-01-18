package im.shimo.navigators;


import android.content.Context;
import android.util.Log;
import android.view.ViewGroup;

import com.facebook.react.bridge.Dynamic;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.modules.i18nmanager.I18nUtil;
import com.facebook.react.uimanager.LayoutShadowNode;
import com.facebook.react.uimanager.NativeViewHierarchyOptimizer;
import com.facebook.react.uimanager.ReactShadowNodeImpl;
import com.facebook.react.uimanager.annotations.ReactProp;

import java.util.ArrayList;


public class SplitSceneShadowNode extends LayoutShadowNode {


  private boolean isSplitMode = false;


  @Override
  public void addChildAt(ReactShadowNodeImpl child, int i) {
    super.addChildAt(child, i);
    if (I18nUtil.getInstance().doLeftAndRightSwapInRTL(getThemedContext())){

    }
  }

  @Override
  public void setStyleHeight(float heightPx) {
    super.setStyleHeight(heightPx);
  }

  @Override
  public void setStyleWidth(float widthPx) {
    super.setStyleWidth(widthPx);
  }

  @Override
  public void setWidth(Dynamic width) {
    super.setWidth(width);
  }

  @Override
  public void onBeforeLayout(NativeViewHierarchyOptimizer nativeViewHierarchyOptimizer) {
    super.onBeforeLayout(nativeViewHierarchyOptimizer);
  }



}
