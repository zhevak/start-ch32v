/**
@file    leds.c
@version 0.0
@date    2023.05.19

@author  Alexander
@email   zhevak@mail.ru

@brief   вставьте сюда краткое описание файла
*/

#include <ch32v00x.h>

#include "leds.h"


void leds_init(void)
{
  RCC->APB2PCENR |= RCC_IOPCEN;
  GPIOC->CFGLR    = 0x00000220;  // 2 = Push/Pull Out 2 MHz
  GPIOC->OUTDR    = 0;
}


void leds_led1_off(void) {GPIOC->BCR = LED1;}
void leds_led2_off(void) {GPIOC->BCR = LED2;}

void leds_led1_on(void) {GPIOC->BSHR = LED1;}
void leds_led2_on(void) {GPIOC->BSHR = LED2;}

void leds_led1_toggle(void)
{
  if (GPIOC->INDR & LED1)
    GPIOC->BCR = LED1;
  else
    GPIOC->BSHR = LED1;
}

void leds_led2_toggle(void)
{
  if (GPIOC->INDR & LED2)
    GPIOC->BCR = LED2;
  else
    GPIOC->BSHR = LED2;
}
