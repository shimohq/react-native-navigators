package im.shimo.navigators;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;

import java.util.ArrayList;

public class SplitScene extends SceneContainer {

  private static final String TAG = "SplitScene";

  private SplitRule DEFAULT_RULE = new SplitRule(LayoutParams.MATCH_PARENT, 0, Integer.MAX_VALUE);

  private ArrayList<SplitRule> mRules;
  private SplitRule mCurrentRule = DEFAULT_RULE;
  private Scene mPrimaryScene;
  private SplitPlaceholder mSplitPlaceholder;
  private boolean mIsSplitMode = false;


  public SplitScene(Context context) {
    super(context);
  }

  @Override
  protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
    if (!mIsSplitMode) {
      super.onMeasure(widthMeasureSpec, heightMeasureSpec);
    } else {
      setMeasuredDimension(getDefaultSize(getSuggestedMinimumWidth(), widthMeasureSpec),
        getDefaultSize(getSuggestedMinimumHeight(), heightMeasureSpec));
      for (int i = 0, size = getChildCount(); i < size; i++) {
        View child = getChildAt(i);
        if (child == mPrimaryScene) {
          child.measure(MeasureSpec.makeMeasureSpec(
            mCurrentRule.primarySceneWidth, MeasureSpec.EXACTLY), heightMeasureSpec);
        } else {
          if (child instanceof Scene) {
            if (child.getLayoutParams().width < 0) {
              int childWidth = getMeasuredWidth() - getPaddingLeft() - getPaddingRight() - mCurrentRule.primarySceneWidth;
              child.measure(MeasureSpec.makeMeasureSpec(childWidth, MeasureSpec.EXACTLY), heightMeasureSpec);
            } else {
              child.measure(MeasureSpec.makeMeasureSpec(
                child.getLayoutParams().width, MeasureSpec.EXACTLY), heightMeasureSpec);
            }

          }
        }
      }
    }


  }

  @Override
  void getAnimationOnPush(Scene scene, int[] anim) {
    switch (scene.getStackAnimation()) {
      case NONE:
        break;
      case SLIDE_FROM_RIGHT:
        anim[0] = R.anim.slide_in_right;
        anim[1] = mIsSplitMode ? R.anim.no_anim : R.anim.slide_out_left_p50;
        break;
      case SLIDE_FROM_LEFT:
        anim[0] = R.anim.slide_in_left;
        anim[1] = mIsSplitMode ? R.anim.no_anim : R.anim.slide_out_right_p50;
        break;
      case SLIDE_FROM_TOP:
        anim[0] = R.anim.slide_in_top;
        anim[1] = R.anim.no_anim;
        break;
      default:
      case DEFAULT:
      case SLIDE_FROM_BOTTOM:
        anim[0] = R.anim.slide_in_bottom;
        anim[1] = R.anim.no_anim;
        break;
    }
  }

  @Override
  void getAnimationOnPop(Scene scene, int[] anim) {
    switch (scene.getStackAnimation()) {
      case NONE:
        break;
      case SLIDE_FROM_RIGHT:
        anim[0] = mIsSplitMode ? R.anim.no_anim :R.anim.slide_in_left_p50;
        anim[1] = R.anim.slide_out_right;
        break;
      case SLIDE_FROM_LEFT:
        anim[0] = mIsSplitMode ? R.anim.no_anim :R.anim.slide_in_right_p50;
        anim[1] = R.anim.slide_out_left;
        break;
      case SLIDE_FROM_TOP:
        anim[0] = R.anim.no_anim;
        anim[1] = R.anim.slide_out_top;
        break;
      default:
      case DEFAULT:
      case SLIDE_FROM_BOTTOM:
        anim[0] = R.anim.no_anim;
        anim[1] = R.anim.slide_out_bottom;
        break;
    }
  }

  @Override
  protected void onLayout(boolean changed, int left, int top, int right, int bottom) {

    for (int i = 0, count = getChildCount(); i < count; i++) {
      View child = getChildAt(i);
      if (child.getVisibility() != GONE) {
        LayoutParams layoutParams = (LayoutParams) child.getLayoutParams();
        int childWidth = child.getMeasuredWidth();
        int childHeight = child.getMeasuredHeight();
        int childLeft = left + layoutParams.leftMargin;
        if (mIsSplitMode) {
          if (child != mPrimaryScene && mPrimaryScene != null) {
            if (!((Scene) child).isFullScreen()) {
              childLeft += mPrimaryScene.getMeasuredWidth();
            }
          }
        }
        child.layout(childLeft, top, childLeft + childWidth, top + childHeight);
      }
    }

  }


  @Override
  protected void addScene(Scene scene, int index) {
    super.addScene(scene, index);
    if (mSplitPlaceholder == null && scene instanceof SplitPlaceholder) {
      mSplitPlaceholder = (SplitPlaceholder) scene;
    } else if (mPrimaryScene == null) {
      mPrimaryScene = scene;
    }
  }

  @Override
  protected boolean isShow(ArrayList<Scene> scenes, int index, int size) {
    final Scene scene = scenes.get(index);
    if (mIsSplitMode && scene == mSplitPlaceholder) {
      return true;
    }
    if (scene == mPrimaryScene) {
      return true;
    }
    return super.isShow(scenes, index, size);
  }

  @Override
  protected Scene getTopScene(ArrayList<Scene> scenes) {
    if (mIsSplitMode) {
      for (int i = scenes.size() - 1; i >= 0; i--) {
        final Scene scene = scenes.get(i);
        if (scene == mPrimaryScene || scene == mSplitPlaceholder) {
          continue;
        }
        return scene;
      }
      return null;
    } else {
      return super.getTopScene(scenes);
    }
  }


  @Override
  protected void onSizeChanged(int w, int h, int oldw, int oldh) {
    super.onSizeChanged(w, h, oldw, oldh);
    if (mRules == null) return;
    final int width = getWidth();
    SplitRule current = null;
    for (SplitRule rule : mRules) {
      if (width >= rule.min && width <= rule.max) {
        current = rule;
        break;
      }
    }
    if (current != null) {
      mCurrentRule = current;
      mIsSplitMode = true;
    } else {
      mCurrentRule = DEFAULT_RULE;
      mIsSplitMode = false;
    }
    if (mSplitPlaceholder !=null){
      mSplitPlaceholder.setVisibility(mIsSplitMode?VISIBLE :GONE);
    }


    post(this::requestLayout);
  }

  public void setSplitRules(@NonNull ReadableArray rules) {
    mRules = new ArrayList<>();
    final Context context = getContext();
    for (int i = 0, size = rules.size(); i < size; i++) {
      final ReadableMap map = rules.getMap(i);
      mRules.add(SplitRule.form(map, context));
    }
  }

  public SplitRule getCurrentRule() {
    return mCurrentRule;
  }

  @Override
  protected ViewGroup.LayoutParams generateDefaultLayoutParams() {
    return new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT);
  }

  @Override
  protected ViewGroup.LayoutParams generateLayoutParams(ViewGroup.LayoutParams p) {
    return new LayoutParams(p);
  }

  @Override
  public ViewGroup.LayoutParams generateLayoutParams(AttributeSet attrs) {
    return new LayoutParams(getContext(), attrs);
  }

  public static class LayoutParams extends MarginLayoutParams {

    public LayoutParams(Context c, AttributeSet attrs) {
      super(c, attrs);
    }

    public LayoutParams(int width, int height) {
      super(width, height);
    }

    public LayoutParams(MarginLayoutParams source) {
      super(source);
    }

    public LayoutParams(ViewGroup.LayoutParams source) {
      super(source);
    }

  }


}
