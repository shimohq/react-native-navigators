package im.shimo.navigators;

import android.content.Context;

public class SceneCard extends SceneContainer {

    public SceneCard(Context context) {
        super(context);
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

}
