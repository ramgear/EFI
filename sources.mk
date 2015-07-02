
# Application source
CSRCS	+= $(wildcard ${PROJECTPATH}/src/*.c)
CSRCS	+= ${PROJECTPATH}/BSP/STM32F4-Discovery/stm32f4_discovery.c

CPPSRCS	+= $(wildcard ${PROJECTPATH}/src/*.cpp)

INCPATH	+= 	${PROJECTPATH}/include \
			${PROJECTPATH}/BSP/STM32F4-Discovery 
	
DEFS	+= -DSTM32F407xx -DHSE_VALUE=8000000