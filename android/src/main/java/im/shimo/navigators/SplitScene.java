package im.shimo.navigators;

import android.animation.PropertyValuesHolder;
import android.animation.ValueAnimator;
import android.content.Context;
import android.util.AttributeSet;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;

import java.util.ArrayList;

public class SplitScene extends SceneContainer {

  private static final String TAG = "SplitScene";

  private static final SplitRule DEFAULT_RULE = new SplitRule(LayoutParams.MATCH_PARENT, 0, Integer.MAX_VALUE);

  private ArrayList<SplitRule> mRules;
  private SplitRule mCurrentRule = DEFAULT_RULE;
  private SplitPlaceholder mSplitPlaceholder;


  private static final int SPLIT_MODE_INVALID = 0;
  private static final int SPLIT_MODE_ON = 669;
  private static final int SPLIT_MODE_OFF = 688;
  private int mIsSplitMode = SPLIT_MODE_INVALID;
  private boolean mIsFullScreen;

  private final InnerSceneContainer mPrimaryContainer;
  private final InnerSceneContainer mSecondaryContainer;
  private final ArrayList<Scene> mSceneList = new ArrayList<>();


  public SplitScene(Context context) {
    super(context);
    mPrimaryContainer = new InnerSceneContainer(context);
    mSecondaryContainer = new InnerSceneContainer(context);
    addView(mPrimaryContainer);
    addView(mSecondaryContainer);
  }

  @Override
  protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
    if (!isSplitModeOn()) {
      super.onMeasure(widthMeasureSpec, heightMeasureSpec);
    } else {
      setMeasuredDimension(getDefaultSize(getSuggestedMinimumWidth(), widthMeasureSpec),
        getDefaultSize(getSuggestedMinimumHeight(), heightMeasureSpec));
      for (int i = 0, size = getChildCount(); i < size; i++) {
        View child = getChildAt(i);
        LayoutParams layoutParams = (LayoutParams) child.getLayoutParams();
        if (child instanceof Scene) {
          if (layoutParams.width < 0) {
            int childWidth = getMeasuredWidth() - getPaddingLeft() - getPaddingRight() - mCurrentRule.primarySceneWidth;
            child.measure(MeasureSpec.makeMeasureSpec(childWidth, MeasureSpec.EXACTLY), heightMeasureSpec);
          } else {
            child.measure(MeasureSpec.makeMeasureSpec(
              layoutParams.width, MeasureSpec.EXACTLY), heightMeasureSpec);
          }
        } else {
          if (child == mPrimaryContainer) {
            child.measure(MeasureSpec.makeMeasureSpec(
              mCurrentRule.primarySceneWidth, MeasureSpec.EXACTLY), heightMeasureSpec);
          } else {
            int childWidth = getMeasuredWidth() - layoutParams.leftMargin - layoutParams.rightMargin
              - getPaddingLeft() - getPaddingRight() - mCurrentRule.primarySceneWidth;
            child.measure(MeasureSpec.makeMeasureSpec(
              childWidth, MeasureSpec.EXACTLY), heightMeasureSpec);
          }

        }
      }
    }
  }


  private void setSplitMode(boolean isSplitMode) {
    if (isSplitMode && isSplitModeOn()) {
      return;
    }
    if (!isSplitMode && isSplitModeOff()) {
      return;
    }
    mIsSplitMode = isSplitMode ? SPLIT_MODE_ON : SPLIT_MODE_OFF;

    if (isSplitModeOn()) {
      mScenes.clear();
      mStack.clear();

      for (Scene scene : mSceneList) {
        removeView(scene);
        if (scene.isSplitPrimary()) {
          mPrimaryContainer.mScenes.add(scene);
          mPrimaryContainer.mStack.add(scene);
          mPrimaryContainer.addView(scene);
          scene.setContainer(mPrimaryContainer);
        } else {
          mSecondaryContainer.mScenes.add(scene);
          mSecondaryContainer.mStack.add(scene);
          mSecondaryContainer.addView(scene);
          scene.setContainer(mSecondaryContainer);
        }
      }


    }

    if (isSplitModeOff()) {
      mPrimaryContainer.clear();
      mSecondaryContainer.clear();

      for (Scene scene : mSceneList) {
        scene.setContainer(this);
        mScenes.add(scene);
        mStack.add(scene);
        addView(scene);
      }

    }

  }

  private boolean isSplitModeOn() {
    return mIsSplitMode == SPLIT_MODE_ON;
  }

  private boolean isSplitModeOff() {
    return mIsSplitMode == SPLIT_MODE_OFF;
  }

  @Override
  protected void onUpdate() {
    if (isSplitModeOn() && mSceneList.size() > 0 && (mPrimaryContainer.getSceneCount() == 0 || mSecondaryContainer.getSceneCount() == 0)) {
      for (Scene scene : mSceneList) {
        if (scene.isSplitPrimary()) {
          mPrimaryContainer.addScene(scene, mPrimaryContainer.getSceneCount());
        } else {
          mSecondaryContainer.addScene(scene, mSecondaryContainer.getSceneCount());
        }
      }
    }
    super.onUpdate();
  }

  @Override
  void getAnimationOnPush(Scene scene, int[] anim) {
    switch (scene.getStackAnimation()) {
      case NONE:
        break;
      case SLIDE_FROM_RIGHT:
        anim[0] = R.anim.slide_in_right;
        anim[1] = R.anim.slide_out_left_p50;
        break;
      case SLIDE_FROM_LEFT:
        anim[0] = R.anim.slide_in_left;
        anim[1] = R.anim.slide_out_right_p50;
        break;
      case SLIDE_FROM_TOP:
        anim[0] = scene == mSplitPlaceholder ? R.anim.no_anim : R.anim.slide_in_top;
        anim[1] = R.anim.no_anim;
        break;
      default:
      case DEFAULT:
      case SLIDE_FROM_BOTTOM:
        anim[0] = scene == mSplitPlaceholder ? R.anim.no_anim : R.anim.slide_in_bottom;
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
        anim[0] = R.anim.slide_in_left_p50;
        anim[1] = R.anim.slide_out_right;
        break;
      case SLIDE_FROM_LEFT:
        anim[0] = R.anim.slide_in_right_p50;
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
        int childWidth = child.getMeasuredWidth();
        int childHeight = child.getMeasuredHeight();
        int childLeft = left;
        if (isSplitModeOn()) {
          if (child == mSecondaryContainer) {
            LayoutParams layoutParams = (LayoutParams) child.getLayoutParams();
            childLeft += mCurrentRule.primarySceneWidth + layoutParams.leftMargin
              + layoutParams.rightMargin;
          }
        }
        child.layout(childLeft, top, childLeft + childWidth, top + childHeight);
      }
    }

  }


  @Override
  protected void addScene(Scene scene, int index) {
    if (mSplitPlaceholder == null && scene instanceof SplitPlaceholder) {
      mSplitPlaceholder = (SplitPlaceholder) scene;
    }
    if (isSplitModeOn()) {
      if (scene.isSplitPrimary()) {
        mPrimaryContainer.addScene(scene, mPrimaryContainer.getSceneCount());
      } else {
        mSecondaryContainer.addScene(scene, mSecondaryContainer.getSceneCount());
      }
      markUpdated();
    } else if (mIsSplitMode == SPLIT_MODE_OFF) {
      super.addScene(scene,index);
    }
    if (mIsSplitMode == SPLIT_MODE_INVALID) {
      markUpdated();
    }
    mSceneList.add(scene);
  }

  @Override
  protected int getSceneCount() {
    return mSceneList.size();
  }

  @Override
  protected Scene getSceneAt(int index) {
    return mSceneList.get(index);
  }

  @Override
  protected void removeSceneAt(int index) {
    if (!isSplitModeOn()) {
      super.removeSceneAt(index);
    } else {
      Scene scene = mSceneList.get(index);
      int i;
      if (scene.isSplitPrimary()) {
        i = mPrimaryContainer.indexOfScene(scene);
        if (i >= 0) {
          mPrimaryContainer.removeSceneAt(i);
        } else {
          Log.w(TAG, "scene: " + Integer.toHexString(scene.getId()) +
            " isSplitPrimary = " + scene.isSplitPrimary() + " but not in mPrimaryContainer");
        }
      } else {
        i = mSecondaryContainer.indexOfScene(scene);
        if (i >= 0) {
          mSecondaryContainer.removeSceneAt(i);
        } else {
          Log.w(TAG, "scene: " + Integer.toHexString(scene.getId()) +
            "isSplitPrimary = " + scene.isSplitPrimary() + " but not in mSecondaryContainer");
        }
      }
    }
    mSceneList.remove(index);
  }

  @Override
  protected boolean isShow(ArrayList<Scene> scenes, int index, int size) {
    final Scene scene = scenes.get(index);
    if (isSplitModeOn() && scene == mSplitPlaceholder) {
      return true;
    }
    if (scene.isSplitPrimary()) {
      return true;
    }
    return super.isShow(scenes, index, size);
  }

  @Override
  protected Scene getTopScene(ArrayList<Scene> scenes) {
    if (isSplitModeOn()) {
      for (int i = scenes.size() - 1; i >= 0; i--) {
        final Scene scene = scenes.get(i);
        if (scene.isSplitPrimary() || scene == mSplitPlaceholder) {
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
    boolean isSplitMode;
    if (current != null) {
      mCurrentRule = current;
      isSplitMode = true;
    } else {
      mCurrentRule = DEFAULT_RULE;
      isSplitMode = false;
    }

    setSplitMode(isSplitMode);
    if (mSplitPlaceholder != null) {
      mSplitPlaceholder.setVisibility(isSplitModeOn() ? VISIBLE : GONE);
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

  public void setSplitFullScreen(boolean isFullScreen) {
    if (mIsFullScreen == isFullScreen) return;
    mIsFullScreen = isFullScreen;

    int formLeft = mSecondaryContainer.getLeft();
    int left = 0;
    if (!mIsFullScreen) {
      left = mCurrentRule.primarySceneWidth;
    }

    ValueAnimator valueAnimator = ValueAnimator.ofPropertyValuesHolder(
      PropertyValuesHolder.ofInt("left", left, mSecondaryContainer.getLeft())
    );
    valueAnimator.setDuration(300);
    valueAnimator.addUpdateListener((ValueAnimator animation) -> {
      int l = (Integer) animation.getAnimatedValue("left");
      ViewGroup.LayoutParams layoutParams = mSecondaryContainer.getLayoutParams();
      if (layoutParams instanceof MarginLayoutParams) {
        ((MarginLayoutParams) layoutParams).leftMargin = -l;
        mSecondaryContainer.setLayoutParams(layoutParams);
      }
    });
    valueAnimator.start();

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

    @Override
    public String toString() {
      return "LayoutParams{" +
        "bottomMargin=" + bottomMargin +
        ", leftMargin=" + leftMargin +
        ", rightMargin=" + rightMargin +
        ", topMargin=" + topMargin +
        ", height=" + height +
        ", layoutAnimationParameters=" + layoutAnimationParameters +
        ", width=" + width +
        '}';
    }
  }

  static class InnerSceneContainer extends SceneStack {

    public InnerSceneContainer(Context context) {
      super(context);
    }

    void clear() {
      mScenes.clear();
      mStack.clear();
      removeAllViews();
    }

  }


}
