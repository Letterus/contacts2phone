#import <ObjFW/ObjFW.h>

OF_ASSUME_NONNULL_BEGIN

@interface A2SDescriptionException: OFException

@property (retain, nonatomic) OFString *description;

+ (instancetype)exceptionWithDescription: (OFString*)description;
+ (instancetype)exceptionWithDescriptionCString: (char*)cdescription;


- (instancetype)initWithDescription: (OFString*)description;
- (instancetype)initWithDescriptionCString: (char*)cdescription;

- (void)setDescription: (OFString*)description;
- (void)setDescriptionCString: (char*)cdescription;

@end

OF_ASSUME_NONNULL_END
