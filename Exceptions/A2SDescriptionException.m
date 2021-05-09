#import "A2SDescriptionException.h"

@implementation A2SDescriptionException

@synthesize description = _description;

+ (instancetype)exceptionWithDescription: (OFString*)description
{
	return [[[self alloc] initWithDescription: description] autorelease];
}

+ (instancetype)exceptionWithDescriptionCString: (char*)cdescription
{
	return [[[self alloc] initWithDescriptionCString: cdescription] autorelease];
}

- (instancetype)initWithDescription: (OFString*)description
{
	self = [super init];

	_description = description;
	
	return self;
}

- (instancetype)initWithDescriptionCString: (char*)cdescription
{
	self = [super init];

	_description = [OFString stringWithCString: cdescription
                                      encoding: OFStringEncodingUTF8];
	
	return self;
}

- (void)setDescription: (OFString*)description
{
    _description = description;
    [description autorelease];
}

- (void)setDescriptionCString: (char*)cdescription
{
    _description = [OFString stringWithCString: cdescription
                                      encoding: OFStringEncodingUTF8];
}

- (OFString *)description
{
	return _description;
}
@end
