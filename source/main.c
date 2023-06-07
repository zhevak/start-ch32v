#include <ch32v00x.h>
#include <stdbool.h>

#include "system.h"



int main(void)
{
  system_initSystick();

  __enable_irq();
  while (true)
  {
    if (system_isSysTick())
    {
    }
  }
}
