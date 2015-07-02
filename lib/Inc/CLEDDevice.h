/*
 * LEDDevice.h
 *
 *  Created on: Jun 26, 2015
 *      Author: eakkasit
 */

#ifndef LEDDEVICE_H_
#define LEDDEVICE_H_

#include "CGPIOBase.h"

class CLEDDevice : public CGPIOBase
{
private:
	const char *	mName;

public:
	CLEDDevice(const char *name, GPIO_TypeDef* port, uint32_t pin) :CGPIOBase(port, pin), mName(name)
	{

	}
	virtual ~CLEDDevice()
	{

	}

	bool_t Init(){

		  // Enable GPIO Peripheral clock
		uint32_t n = (((uint32_t)mPort - (uint32_t)GPIOA)/(GPIOB_BASE-GPIOA_BASE));

		  RCC->AHB1ENR |= (0x1 << n);

		  GPIO_InitTypeDef GPIO_InitStructure;

		  // Configure pin in output push/pull mode
		  GPIO_InitStructure.Pin = mPin;
		  GPIO_InitStructure.Mode = GPIO_MODE_OUTPUT_PP;
		  GPIO_InitStructure.Speed = GPIO_SPEED_FAST;
		  GPIO_InitStructure.Pull = GPIO_PULLUP;
		  HAL_GPIO_Init(mPort, &GPIO_InitStructure);

		  // Start with led turned off
		  this->Off();

		  CGPIOBase::Init();

		return true;
	}

	inline const char* GetName() { return mName; }

	const CString toString() {
		return mName;
	}
};



#endif /* LEDDEVICE_H_ */
