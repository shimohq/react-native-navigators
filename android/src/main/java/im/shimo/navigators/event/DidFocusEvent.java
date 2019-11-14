package im.shimo.navigators.event;

import android.util.Log;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.uimanager.events.Event;
import com.facebook.react.uimanager.events.RCTEventEmitter;

/**
 * Created by jiang on 2019-11-06
 */

public class DidFocusEvent extends Event<DidFocusEvent> {

    public static final String EVENT_NAME = "onDidFocus";

    public DidFocusEvent(int viewTag) {
        super(viewTag);
        Log.d("dispatch event", EVENT_NAME);
    }

    @Override
    public String getEventName() {
        return EVENT_NAME;
    }

    @Override
    public void dispatch(RCTEventEmitter rctEventEmitter) {
        rctEventEmitter.receiveEvent(getViewTag(), getEventName(), Arguments.createMap());
    }
}
