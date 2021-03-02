package im.shimo.navigators;

import android.graphics.Rect;

import com.facebook.react.uimanager.LayoutShadowNode;
import com.facebook.yoga.YogaEdge;

public class SceneShadowNode extends LayoutShadowNode {

  @Override
  public void setLocalData(Object data) {
    if (data instanceof Rect) {
      setPosition(YogaEdge.START.intValue(), ((Rect) data).left);
      setPosition(YogaEdge.TOP.intValue(), ((Rect) data).top);
      setStyleWidth(((Rect) data).width());
      setStyleHeight(((Rect) data).height());
    }
  }
}
