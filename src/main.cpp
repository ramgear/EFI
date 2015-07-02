//
// This file is part of the GNU ARM Eclipse distribution.
// Copyright (c) 2014 Liviu Ionescu.
//

// ----------------------------------------------------------------------------

#ifdef __cplusplus
extern "C" {
#endif

#include <stdio.h>
#include <stdlib.h>
#include "Trace.h"

#include "CTimer.h"
#include "CLEDDevice.h"

// ----- Timing definitions -------------------------------------------------

// Keep the LED on for 1/4 of a second.
#define ON_OFF_TICKS (TIMER_FREQUENCY_HZ * 1 / 4)

#define LEDS_NUM 4
CLEDDevice leds[] = {
		{"LED3", GPIOD, GPIO_PIN_13},
		{"LED4", GPIOD, GPIO_PIN_12},
		{"LED6", GPIOD, GPIO_PIN_15},
		{"LED5", GPIOD, GPIO_PIN_14},
		{NULL, NULL, 0},
};

CTimer timer;

int main(void)
{
  // Send a greeting to the trace device (skipped on Release).
  trace_puts("Eclipse C++ Hello World!");

  // At this stage the system clock should have already been configured
  // at high speed.
  trace_printf("System clock: %uHz\n", SystemCoreClock);

	CLEDDevice *led = leds;
	while(led->GetName() != NULL)
	{
		if(led->Init())
			trace_printf("%s init done.\n", led->toString());

		led++;
	}

	timer.start();

  uint32_t seconds = 0;

  uint32_t stat = 0;

  // Infinite loop
  while (1)
    {
	  if(led->GetName() == NULL)
	  {
		  led = leds;
		  stat = !stat;
	  }

	  if(stat != 0)
		  led->On();
	  else
		  led->Off();

      timer.sleep(ON_OFF_TICKS);

      led++;
      ++seconds;

      // Count seconds on the trace device.
      trace_printf("Second %u\n", seconds);
    }
  // Infinite loop, never return.
}

// ----- SysTick_Handler() ----------------------------------------------------

void
SysTick_Handler (void)
{
  timer.tick ();
}

// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
#ifdef __cplusplus
}
#endif
