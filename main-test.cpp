#include <Arduino.h>
#include <ChRt.h>
static THD_WORKING_AREA(wa_thd1, 64);
static THD_FUNCTION(thd1, arg){
	(void)arg;
	pinMode(LED_BUILTIN, OUTPUT);
	while(1){
		digitalWrite(LED_BUILTIN, HIGH);
		chThdSleepMilliseconds(1000);
		digitalWrite(LED_BUILTIN, LOW);
		chThdSleepMilliseconds(500);
	}
}

void chSetup(){
	chThdCreateStatic(wa_thd1, sizeof(wa_thd1),NORMALPRIO + 1, thd1, NULL);
}

void setup(){
	chBegin(chSetup);
	Serial.begin(9600);
}
void loop(){
	Serial.println("Hello");
	delay(500);
}

