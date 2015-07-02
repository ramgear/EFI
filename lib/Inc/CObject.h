/*
 * @file	CObject.h
 * @author	Eakkasit L.
 * @version	1.0.0
 * @date	26/06/2015
 * @brief	none
 *
 *  Created on: Jun 26, 2015
 *      Author: eakkasit
 */

#ifndef COBJECT_H_
#define COBJECT_H_

#include "typedef.h"

/*
 * @brief	Object class is the super class for all class.
 */
class CObject {
public:
	virtual ~CObject() {}

	virtual const CString toString() {
		static const CString _objString = "CObject";

		return _objString;
	}
};


#endif /* COBJECT_H_ */
