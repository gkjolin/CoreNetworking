//
//  AFNetworkTypes.h
//  Amber
//
//  Created by Keith Duncan on 15/03/2009.
//  Copyright 2009 thirty-three. All rights reserved.
//

#import <Foundation/Foundation.h>

struct AFSocketType {
	SInt32 socketType;
	SInt32 protocol;
};
typedef struct AFSocketType AFSocketType;

extern AFSocketType AFSocketTypeTCP;
extern AFSocketType AFSocketTypeUDP;