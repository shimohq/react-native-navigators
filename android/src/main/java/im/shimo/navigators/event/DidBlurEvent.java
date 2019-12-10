package im.shimo.navigators.event;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.uimanager.events.Event;
import com.facebook.react.uimanager.events.RCTEventEmitter;

/**
 * Created by jiang on 2019-11-06
 */

public class DidBlurEvent extends Event<DidBlurEvent> {

    public static final String EVENT_NAME = "onDidBlur";
    private final boolean mIsDismissed;

    public DidBlurEvent(int viewTag, boolean isDismissed) {
        super(viewTag);
        mIsDismissed = isDismissed;
    }

    @Override
    public String getEventName() {
        return EVENT_NAME;
    }

    @Override
    public void dispatch(RCTEventEmitter rctEventEmitter) {
        final WritableMap map = Arguments.createMap();
        map.putBoolean("dismissed", mIsDismissed);
        rctEventEmitter.receiveEvent(getViewTag(), getEventName(), map);
    }
}
