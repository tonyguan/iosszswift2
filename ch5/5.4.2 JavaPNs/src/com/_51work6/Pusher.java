package com._51work6;

import javapns.Push;
import javapns.notification.PushNotificationPayload;

public class Pusher {

	public static void main(String[] args) {
		
		try {
			
			PushNotificationPayload payload = new PushNotificationPayload();
		
			payload.addCustomAlertBody("新年好！from Java");
			payload.addBadge(11);
			payload.addSound("default");

			Push.payload(payload, "ssl/a.p12", "51work6.com", false,
					"9965e2454864168c3c897f27bd800cd507f0858c2ebb1f52526fc97adf9556e9");

		} catch (Exception e) {
			e.printStackTrace();
		}
	}

}
