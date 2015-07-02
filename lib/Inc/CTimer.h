/*
 * TImer.h
 *
 *  Created on: Jul 1, 2015
 *      Author: eakkasit
 */

#ifndef LIB_INC_CTIMER_H_
#define LIB_INC_CTIMER_H_

#include "CObject.h"
#include "stm32f4xx_hal.h"

#define TIMER_FREQUENCY_HZ (1000u)

typedef uint32_t timer_ticks_t;

class CTimer : public CObject
{
private:
	volatile timer_ticks_t timer_delayCount;

public:
	inline void start()
	{
		  // Use SysTick as reference for the delay loops.
		  SysTick_Config (SystemCoreClock / TIMER_FREQUENCY_HZ);
	}

	inline void sleep(timer_ticks_t ticks)
	{
		  timer_delayCount = ticks;

		  // Busy wait until the SysTick decrements the counter to zero.
		  while (timer_delayCount != 0u)
		    ;
	}

	inline void tick()
	{
		  // Decrement to zero the counter used by the delay routine.
		  if (timer_delayCount != 0u)
		    {
		      --timer_delayCount;
		    }
	}
};

#endif /* LIB_INC_CTIMER_H_ */
