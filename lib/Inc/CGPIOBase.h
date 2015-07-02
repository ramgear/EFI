/*
 * GPIOBase.h
 *
 *  Created on: Jun 26, 2015
 *      Author: eakkasit
 */

#ifndef GPIOBASE_H_
#define GPIOBASE_H_

#include "CObject.h"

#include "stm32f4xx.h"
#include "stm32f4xx_hal.h"


class CGPIOBase : public CObject
{
protected:
	GPIO_TypeDef* mPort;
	uint32_t 		mPin;

public:
	CGPIOBase(GPIO_TypeDef* port, uint32_t pin)
	:mPort(port),mPin(pin) {

	}

	virtual ~CGPIOBase() {

	}

	inline GPIO_TypeDef* GetPort() { return mPort; }

	inline uint32_t GetPin() { return mPin; }

	virtual bool_t Init() {
		return true;
	}

	virtual void On(){
	    HAL_GPIO_WritePin(mPort,
	        mPin, GPIO_PIN_SET);
	}

	virtual void Off(){
	    HAL_GPIO_WritePin(mPort,
	        mPin, GPIO_PIN_RESET);
	}
};



#endif /* GPIOBASE_H_ */
