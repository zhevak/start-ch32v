#include <ch32v00x.h>
#include <stdbool.h>

#include "system.h"



int main(void)
{
  system_initSystick();
  leds_init();

  leds_led1_on();
  leds_led2_off();

  __enable_irq();
  while (true)
  {
    if (system_isSysTick())
    {
      leds_led1_toggle();
      leds_led2_toggle();
    }
  }
}
