#import "A2SEDSException.h"

@implementation A2SEDSException

- (OFString *)description
{
	return [OFString stringWithFormat: 
	        @"Evolution Data Server reports error: %@", [super description]];
}
@end
