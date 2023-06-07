/**
@file    leds.h
@version 0.0
@date    2023.05.19

@author  Alexander
@email   zhevak@mail.ru

@brief   вставьте сюда краткое описание файла
*/


#ifndef __LEDS_H__
#define __LEDS_H__

// Определение битов порта PC
#define LED1  (0x02)   // Бит 1
#define LED2  (0x04)   // Бит 2



void leds_init(void);

void leds_led1_on(void);
void leds_led2_on(void);

void leds_led1_off(void);
void leds_led2_off(void);


#endif  // __LEDS_H__
