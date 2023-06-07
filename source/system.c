
#include <ch32v00x.h>
#include <stdbool.h>

#include "system.h"


static volatile bool _systick;


__attribute__((interrupt("WCH-Interrupt-fast")))
void NMI_Handler(void)
{
}


__attribute__((interrupt("WCH-Interrupt-fast")))
void HardFault_Handler(void)
{
  while (true)
  {
  }
}



/**
*   Обработчик прерывания от системного таймера
*
*   Прерывание возникает 10 раз в секунду
*/
__attribute__((interrupt("WCH-Interrupt-fast")))
void SysTick_Handler(void)
{
  _systick = true;
  SysTick->SR = 0;
}


/**
*
*/
void system_initSystick(void)
{
  _systick = false;

  NVIC_EnableIRQ(SysTick_IRQn);

  SysTick->SR   = 0;
  SysTick->CMP  = 2400000 - 1;  // 100 мc
  SysTick->CNT  = 0;
  SysTick->CTLR = 0xF;
}


/**
*
*/
bool system_isSysTick(void)
{
  bool tmp = _systick;
  _systick = false;

  return tmp;
}



/**
*
*/
void system_init(void)
{
  RCC->CTLR  |=  RCC_HSION;    // Включаю HSI (24 МГц)
  RCC->CFGR0 &=  0x00000000;   // Отключаю MCO, пределители в исходное сотояние, HSI
  RCC->CTLR  &= ~(RCC_PLLON | RCC_CSSON | RCC_HSEON);  // Выключаю PLL и HSE
  RCC->CTLR  &= ~RCC_HSEBYP;  // Выключаю байпас
  RCC->INTR   = (RCC_CSSC | RCC_PLLRDYC | RCC_HSERDYC | RCC_HSIRDYC | RCC_LSIRDYC);  // Сбрасываю флаги

  FLASH->ACTLR &= ~FLASH_ACTLR_LATENCY;
  FLASH->ACTLR |=  FLASH_ACTLR_LATENCY_0;  // Цикл обращения к флеш-памяти

  RCC->CFGR0 |= RCC_HPRE_DIV1;             // HCLK = SYSCLK = 24 MHz

  // RCC->APB2PCENR |= RCC_IOPCEN | RCC_AFIOEN;  // Разрешаю тактирование функций и порта PC
  // GPIOC->CFGLR    = 0x000B0000;               // Конфигурация для бита 4 для вывода MCO
  // RCC->CFGR0     |= RCC_CFGR0_MCO_SYSCLK;     // На MCO будет выводится SYSCLK
}

