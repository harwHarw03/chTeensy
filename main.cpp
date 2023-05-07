#include <modules/VehicleType/FixedWing/FixedWing.h>
//  #include <modules/VehicleType/MultiCopter/MultiCopter.h>
// #include <modules/VehicleType/VTOLPLane/VTOLPlane.h>
#include <modules/Radio/Radio.h>
#include <modules/GPS/GPS.h>
#include <modules/InertialSensor/InvenSense_MPU9250.h>
#include <modules/Compass/Compass.h>
#include <modules/Barometer/Barometer.h>
#include <modules/Telemetry/Telemetry.h>


GPS_Thread gps_thd;
Radio_Thread rc_thd;
Compass_Thread compass_thd;
Barometer_Thread barometer_thd;
Telem_Thread telem_thd;
Receive_Thread receive_thread;

uint8_t id;

int main()
{
  /*
   * System initializations.
   * - HAL initialization, this also initializes the configured device drivers
   *   and performs the board-specific initializations.
   */  
  halInit();

  /**
   * ChibiOS/RT initialization
   */
  chSysInit();

  /*
   * Enabling interrupts, initialization done.
   */
  osalSysEnable();
  /*
   * Initialize peripheral
   */
  SYS::init();
  fixwing.setup();
  // copter.setup();
  // vplane.setup();
  gps_thd.start(NORMALPRIO);
  rc_thd.start(NORMALPRIO);
  barometer_thd.start(NORMALPRIO);
  compass_thd.start(NORMALPRIO);
  receive_thread.start(NORMALPRIO);
  telem_thd.start(NORMALPRIO - 1);
  uint32_t main_loop_time, exec_time;
  while (true)
  {
    /** main loop */
    main_loop_time = SYS::micros();
    imu().update();
    fixwing.loop();
    // copter.loop();
    // vplane.loop();
    exec_time = SYS::micros() - main_loop_time;
    chThdSleepMicroseconds(AVAILABLE_SLEEP(exec_time, 2500));
  }
}
