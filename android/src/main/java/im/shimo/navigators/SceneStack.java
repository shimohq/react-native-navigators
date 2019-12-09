package im.shimo.navigators;

import android.content.Context;

public class SceneStack extends SceneContainer {

    private static final String TAG = "SceneStack";

//    SceneStackRootView rootView;


    public SceneStack(Context context) {
        super(context);
//        rootView = new SceneStackRootView(context);
//        addView(rootView);
    }

//    @Override
//    protected SceneStackModel adapt(Scene scene) {
//        return new SceneStackModel(scene);
//    }



//    @Override
//    public void addView(View child) {
//        SceneStackRootView rootView = new SceneStackRootView(getContext());
//        rootView.addView(child);
//        super.addView(rootView);
//    }
//
//
//    @Override
//    public void removeView(View view) {
//        ViewParent parent = view.getParent();
//        if (parent instanceof SceneStackRootView) {
//            if (parent.getParent() instanceof SceneStack){
//                super.removeView((View) parent);
//            }
//        } else {
//            super.removeView(view);
//        }
//    }

    @Override
    void getAnimationOnPush(Scene scene, int[] anim) {
        switch (scene.getStackAnimation()) {
            case NONE:
//                anim[0] = R.anim.no_anim;
//                anim[1] = R.anim.no_anim;
                break;
            default:
            case DEFAULT:
            case SLIDE_FROM_RIGHT:
                anim[0] = R.anim.slide_in_right;
                anim[1] = R.anim.slide_out_left_p50;
                break;
            case SLIDE_FROM_LEFT:
                anim[0] = R.anim.slide_in_left;
                anim[1] = R.anim.slide_out_right_p50;
                break;
            case SLIDE_FROM_TOP:
                anim[0] = R.anim.slide_in_top;
                anim[1] = R.anim.no_anim;
                break;
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
//                anim[0] = R.anim.no_anim;
//                anim[1] = R.anim.no_anim;
                break;
            default:
            case DEFAULT:
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
            case SLIDE_FROM_BOTTOM:
                anim[0] = R.anim.no_anim;
                anim[1] = R.anim.slide_out_bottom;
                break;
        }
    }

//    public void setHeader(SceneStackHeader sceneStackHeader) {
//        if (mSceneStackHeader == sceneStackHeader) return;
//        mSceneStackHeader = sceneStackHeader;
//        addViewInLayout(mSceneStackHeader, 0, generateDefaultLayoutParams());
//        notifyChildUpdate();
//    }
//
//    public void removeHeader() {
//        mSceneStackHeader = null;
//        notifyChildUpdate();
//    }

    @Override
    protected void onLayout(boolean changed, int l, int t, int r, int b) {
        super.onLayout(changed, l, t, r, b);
    }

    @Override
    protected void onUpdate() {
        super.onUpdate();
    }


}
