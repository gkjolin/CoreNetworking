//
//  AFNetworkConnectionLayer.h
//  Amber
//
//  Created by Keith Duncan on 31/03/2009.
//  Copyright 2009. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CoreNetworking/AFNetworkTransportLayer.h"

/*
	Connection Layers
 */

@protocol AFNetworkConnectionLayerHostDelegate <AFNetworkTransportLayerHostDelegate>

/*!
	\param layer
	Could be the host that spawned it or an intermediate object.
 */
- (void)networkLayer:(id)layer didAcceptConnection:(id <AFNetworkTransportLayer>)connection;

@end


@protocol AFNetworkConnectionLayerControlDelegate <AFNetworkTransportLayerControlDelegate>

@end


@protocol AFNetworkConnectionLayerDataDelegate <AFNetworkTransportLayerDataDelegate>

@end

@protocol AFNetworkConnectionLayerDelegate <AFNetworkConnectionLayerControlDelegate, AFNetworkConnectionLayerDataDelegate>

@end

#pragma mark -

/*!
	\brief
	An AFNetworkConnectionLayer should maintain a stateful connection between endpoints.
 */
@protocol AFNetworkConnectionLayer <AFNetworkTransportLayer>

@property (assign, nonatomic) id <AFNetworkConnectionLayerDelegate> delegate;

 @optional

/*!
	\brief
	Pass a dictionary with the SSL keys specified in CFSocketStream.h
	
	\details
	Any immediate error is returned by reference, if negotiation fails the error will be delivered by 
 */
- (BOOL)startTLS:(NSDictionary *)options error:(NSError **)errorRef;

/*!
	\brief
	This method can be used to determine if SSL/TLS has been started on the connection.
 */
- (BOOL)isSecure;

@end
