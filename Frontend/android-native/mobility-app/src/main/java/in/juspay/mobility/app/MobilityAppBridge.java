package in.juspay.mobility.app;

import static android.app.Activity.RESULT_OK;
import static androidx.core.app.ActivityCompat.startIntentSenderForResult;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.IntentSender;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.location.Location;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.webkit.JavascriptInterface;

import com.clevertap.android.sdk.CleverTapAPI;
import com.facebook.appevents.AppEventsLogger;
import com.google.android.gms.auth.api.credentials.Credential;
import com.google.android.gms.auth.api.credentials.Credentials;
import com.google.android.gms.auth.api.credentials.HintRequest;
import com.google.android.gms.tasks.Task;
import com.google.android.play.core.review.ReviewInfo;
import com.google.android.play.core.review.ReviewManager;
import com.google.android.play.core.review.ReviewManagerFactory;
import com.google.firebase.analytics.FirebaseAnalytics;
import com.google.firebase.messaging.FirebaseMessaging;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

import in.juspay.hyper.bridge.HyperBridge;
import in.juspay.hyper.core.BridgeComponents;
import in.juspay.hyper.core.ExecutorManager;
import in.juspay.hypersdk.data.KeyValueStore;
import in.juspay.mobility.app.callbacks.CallBack;

public class MobilityAppBridge extends HyperBridge {

    // Log Tags
    private static final String CHATS = "CHATS";
    private static final String META_LOG = "META_LOG";
    private static final String CALLBACK = "CALLBACK";
    private static final String UTILS = "UTILS";

    private static FirebaseAnalytics mFirebaseAnalytics;
    CleverTapAPI clevertapDefaultInstance;
    protected static String storeChatMessageCallBack = null;
    public static String storeCallBackOpenChatScreen = null;
    public static String storeDetectPhoneNumbersCallBack = null;


    // Permission request Code
    private static final int CREDENTIAL_PICKER_REQUEST = 74;

    private static final ArrayList<SendMessageCallBack> sendMessageCallBacks = new ArrayList<>();
    CallBack callBack = new CallBack() {
        @Override
        public void customerCallBack(String notificationType) {
            Log.i(CALLBACK, "Not required");
        }

        @Override
        public void driverCallBack(String notificationType) {
            Log.i(CALLBACK, "Not required");
        }

        @Override
        public void imageUploadCallBack(String encImage, String filename, String filePath) {
            Log.i(CALLBACK, "Not required");
        }

        @Override
        public void chatCallBack(String message, String sentBy, String dateFormatted, String len) {
            callChatMessageCallBack(message, sentBy, dateFormatted, len);
        }

        @Override
        public void inAppCallBack(String inAppCallBack) {
            callInAppNotificationCallBack(inAppCallBack);
        }
    };

    public MobilityAppBridge(BridgeComponents bridgeComponents) {
        super(bridgeComponents);
        mFirebaseAnalytics = FirebaseAnalytics.getInstance(bridgeComponents.getContext());
        ChatService.registerCallback(callBack);
        InAppNotification.registerCallback(callBack);
        clevertapDefaultInstance = CleverTapAPI.getDefaultInstance(bridgeComponents.getContext());
    }

    @JavascriptInterface
    public void factoryResetApp() {
        if (bridgeComponents.getActivity() != null) {
            final PackageManager pm = bridgeComponents.getActivity().getPackageManager();
            final Intent intent = pm.getLaunchIntentForPackage(bridgeComponents.getActivity().getPackageName());
            bridgeComponents.getActivity().finishAffinity(); // Finishes all activities.
            bridgeComponents.getContext().startActivity(intent);    // Start the launch activity
        }
    }

    @Override
    public void reset() {
        ChatService.deRegisterCallback(callBack);
        InAppNotification.deRegisterCallBack(callBack);
    }

    // region Store And Trigger CallBack
    @JavascriptInterface
    public void storeCallBackMessageUpdated(final String channelId, final String uuid, final String callback) {
        storeChatMessageCallBack = callback;
        KeyValueStore.write(bridgeComponents.getContext(), bridgeComponents.getSdkName(), "CHAT_CHANNEL_ID", channelId); // Update the Local Storage Value
        ChatService.chatChannelID = channelId;
        ChatService.chatUserId = uuid;
    }

    public void callChatMessageCallBack(String message, String sentBy, String dateFormatted, String len) {
        if (storeChatMessageCallBack != null) {
            String javascript = String.format("window.callUICallback(\"%s\",\"%s\",\"%s\",\"%s\",\"%s\");", storeChatMessageCallBack, message, sentBy, dateFormatted, len);
            bridgeComponents.getJsCallback().addJsToWebView(javascript);
        }
    }

    @JavascriptInterface
    public void removeChatMessageCallback() {
        storeChatMessageCallBack = null;
    }

    public void callInAppNotificationCallBack(String onTapAction) {
        String javascript = String.format(Locale.ENGLISH, "window.callUICallback(\"%s\");", onTapAction);
        bridgeComponents.getJsCallback().addJsToWebView(javascript);
    }
    // endregion

    @JavascriptInterface
    public void firebaseLogEvent(String event) {
        Bundle params = new Bundle();
        mFirebaseAnalytics.logEvent(event, params);
    }

    @JavascriptInterface
    public void firebaseLogEventWithParams(String event, String paramKey, String paramValue) {
        Bundle params = new Bundle();
        params.putString(paramKey, paramValue);
        mFirebaseAnalytics.logEvent(event, params);
    }

    @JavascriptInterface
    public void firebaseLogEventWithTwoParams(String event, String paramKey1, String paramValue1, String paramKey2, String paramValue2) {
        Bundle params = new Bundle();
        params.putString(paramKey1, paramValue1);
        params.putString(paramKey2, paramValue2);
        mFirebaseAnalytics.logEvent(event, params);
    }

    @JavascriptInterface
    public void firebaseUserID(String id) {
        mFirebaseAnalytics.setUserId(id);
    }

    @JavascriptInterface
    public void setFCMToken(final String callback) {
        ExecutorManager.runOnMainThread(() -> FirebaseMessaging.getInstance().getToken()
                .addOnCompleteListener(task -> {
                    if (!task.isSuccessful()) {
                        return;
                    }
                    // Get new FCM registration token
                    String token = task.getResult();
                    KeyValueStore.write(bridgeComponents.getContext(), bridgeComponents.getSdkName(), "FCM_TOKEN", token);
                    String javascript = String.format(Locale.ENGLISH, "window.callUICallback('%s','%s');", callback, token);
                    if (callback != null) {
                        bridgeComponents.getJsCallback().addJsToWebView(javascript);
                    }
                }));
    }

    @JavascriptInterface
    public void metaLogEvent(String event) {
        try {
            AppEventsLogger logger = AppEventsLogger.newLogger(bridgeComponents.getContext());
            logger.logEvent(event);
        } catch (Exception e) {
            Log.e(META_LOG, "Error in metaLogEvent " + e);
        }
    }

    @JavascriptInterface
    public void metaLogEventWithParams(String event, String paramKey, String paramValue) {
        try {
            Bundle params = new Bundle();
            params.putString(paramKey, paramValue);
            AppEventsLogger logger = AppEventsLogger.newLogger(bridgeComponents.getContext());
            logger.logEvent(event,params);
        } catch (Exception e) {
            Log.e(META_LOG, "Error in metaLogEventWithParams : " + e);
        }
    }

    @JavascriptInterface
    public void metaLogEventWithTwoParams(String event, String paramKey1, String paramValue1, String paramKey2, String paramValue2) {
        try {
            Bundle params = new Bundle();
            params.putString(paramKey1, paramValue1);
            params.putString(paramKey2, paramValue2);
            AppEventsLogger logger = AppEventsLogger.newLogger(bridgeComponents.getContext());
            logger.logEvent(event,params);
        } catch (Exception e) {
            Log.e(META_LOG, "Error in metaLogEventWithTwoParams : " + e);
        }
    }

    @JavascriptInterface
    public void launchInAppRatingPopup() {
        ReviewManager manager = ReviewManagerFactory.create(bridgeComponents.getContext());
        Task<ReviewInfo> request = manager.requestReviewFlow();
        request.addOnCompleteListener(task -> {
            if (task.isSuccessful() && bridgeComponents.getActivity() != null) {
                // We can get the ReviewInfo object
                ReviewInfo reviewInfo = task.getResult();
                Task<Void> flow = manager.launchReviewFlow(bridgeComponents.getActivity(), reviewInfo);
                flow.addOnCompleteListener(task1 -> {
                    // The flow has finished. The API does not indicate whether the user
                    // reviewed or not, or even whether the review dialog was shown.
                });
            }

        });
    }
    // endregion

    //region Chat Utiils
    @JavascriptInterface
    public static void sendMessage(final String message) {
        for (SendMessageCallBack sendMessageCallBack : sendMessageCallBacks) {
            sendMessageCallBack.sendMessage(message);
        }
    }

    @JavascriptInterface
    public void storeCallBackOpenChatScreen(final String callback) {
        storeCallBackOpenChatScreen = callback;
    }

    @JavascriptInterface
    public void removeCallBackOpenChatScreen() {
        storeCallBackOpenChatScreen = null;
    }

    @JavascriptInterface
    public void startChatListenerService() {
        try {
            Context context = bridgeComponents.getContext();
            SharedPreferences sharedPref = context.getSharedPreferences(context.getString(R.string.preference_file_key), Context.MODE_PRIVATE);
            String appState = sharedPref.getString("ACTIVITY_STATUS", "null");
            Intent chatListenerService = new Intent(context, ChatService.class);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && appState.equals("onPause")) {
                AlarmManager manager = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
                Intent alarmIntent = new Intent(context, ChatBroadCastReceiver.class);
                PendingIntent pendingIntent = PendingIntent.getBroadcast(context, 0, alarmIntent, PendingIntent.FLAG_IMMUTABLE);
                manager.setExact(AlarmManager.RTC_WAKEUP, System.currentTimeMillis(), pendingIntent);
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(chatListenerService);
            } else {
                context.startService(chatListenerService);
            }
        } catch (Exception e) {
            Log.e(CHATS, "Failed to start ChatService : " + e);
        }
    }

    @JavascriptInterface
    public void stopChatListenerService() {
        try {
            Intent chatListenerService = new Intent(bridgeComponents.getContext(), ChatService.class);
            Intent overlayService = new Intent(bridgeComponents.getContext(), MessageOverlayService.class);
            bridgeComponents.getContext().stopService(chatListenerService);
            bridgeComponents.getContext().stopService(overlayService);
        } catch (Exception e) {
            Log.e(CHATS, "Failed to stop ChatService : " + e);
        }
    }

    public interface SendMessageCallBack {
        void sendMessage(String message);
    }

    public static void registerSendMessageCallBack(SendMessageCallBack callBack) {
        sendMessageCallBacks.add(callBack);
    }

    public static void deRegisterSendMessageCallBack(SendMessageCallBack callBack) {
        sendMessageCallBacks.remove(callBack);
    }
    // endregion

    @JavascriptInterface
    public void detectPhoneNumbers(final String callback) {
        storeDetectPhoneNumbersCallBack = callback;
        HintRequest hintRequest = new HintRequest.Builder()
                .setPhoneNumberIdentifierSupported(true)
                .build();
        PendingIntent intent = Credentials.getClient(bridgeComponents.getContext()).getHintPickerIntent(hintRequest);
        try {
            if (bridgeComponents.getActivity() != null) {
                startIntentSenderForResult(bridgeComponents.getActivity(), intent.getIntentSender(), CREDENTIAL_PICKER_REQUEST, null, 0, 0, 0, new Bundle());
            }
        } catch (IntentSender.SendIntentException e) {
            e.printStackTrace();
        }
    }

    @JavascriptInterface
    public void cleverTapEvent(String event, String params) {
        if (clevertapDefaultInstance != null) {
            Map<String, Object> resultMap = new HashMap<>();
            try {
                JSONArray jsonArray = new JSONArray(params);

                for (int i = 0; i < jsonArray.length(); i++) {
                    JSONObject jsonObject = jsonArray.getJSONObject(i);
                    String key = jsonObject.getString("key");
                    Object value = jsonObject.get("value");
                    resultMap.put(key, value);
                }
            } catch (JSONException e) {
                e.printStackTrace();
                return;
            }
            clevertapDefaultInstance.pushEvent(event, resultMap);
        }
    }

    @JavascriptInterface
    public void setCleverTapUserData(String key, String value) {
        HashMap<String, Object> profileUpdate = new HashMap<>();
        try {
            profileUpdate.put(key, value);
        } catch (Exception e) {
            Log.e(UTILS, "Error sending user data: " + e);
        }

        if (clevertapDefaultInstance != null) {
            clevertapDefaultInstance.onUserLogin(profileUpdate);
            SharedPreferences sharedPrefs = bridgeComponents.getContext().getSharedPreferences(bridgeComponents.getContext().getString(R.string.preference_file_key), Context.MODE_PRIVATE);
            String fcmRegId = sharedPrefs.getString("FCM_TOKEN", "null");
            clevertapDefaultInstance.pushFcmRegistrationId(fcmRegId, true);
        }
    }

    @JavascriptInterface
    public void setCleverTapUserProp(String key, String value) {
        HashMap<String, Object> profileUpdate = new HashMap<>();
        try {
            profileUpdate.put(key, value);
        } catch (Exception e) {
            Log.e(UTILS, "Error sending user data: " + e);
        }
        if (clevertapDefaultInstance != null)
            clevertapDefaultInstance.pushProfile(profileUpdate);
    }


    @JavascriptInterface
    public void cleverTapCustomEvent(String event) {
        if (clevertapDefaultInstance != null)
            clevertapDefaultInstance.pushEvent(event);
    }

    @JavascriptInterface
    public void cleverTapCustomEventWithParams(String event, String paramKey, String paramValue) {
        HashMap<String, Object> mapCustomEvent = new HashMap<>();
        mapCustomEvent.put(paramKey, paramValue);
        if (clevertapDefaultInstance != null)
            clevertapDefaultInstance.pushEvent(event, mapCustomEvent);
    }

    @JavascriptInterface
    public void cleverTapSetLocation() {
        Location location = clevertapDefaultInstance.getLocation();
        clevertapDefaultInstance.setLocation(location);
    }

    @JavascriptInterface
    public void openWhatsAppSupport(String contactNumber) {
        String url = "https://api.whatsapp.com/send?phone=" + contactNumber;
        Intent intent = new Intent(Intent.ACTION_VIEW);
        intent.setData(Uri.parse(url));
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        bridgeComponents.getContext().startActivity(intent);
    }


    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == CREDENTIAL_PICKER_REQUEST) {
            if (resultCode == RESULT_OK) {
                Credential credentials = data.getParcelableExtra(Credential.EXTRA_KEY);
                String selectedNumber = credentials.getId().substring(3);
                String javascript = String.format(Locale.ENGLISH, "window.callUICallback('%s','%s');",
                        storeDetectPhoneNumbersCallBack, selectedNumber); //mobile_number
                bridgeComponents.getJsCallback().addJsToWebView(javascript);
            }
        }
        return super.onActivityResult(requestCode, resultCode, data);
    }

    @Override
    public boolean onRequestPermissionResult(int requestCode, String[] permissions, int[] grantResults) {
        return super.onRequestPermissionResult(requestCode, permissions, grantResults);
    }
}
