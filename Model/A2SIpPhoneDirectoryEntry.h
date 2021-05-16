#include <ObjFW/OFObject.h>
#import <ObjFW/ObjFW.h>

OF_ASSUME_NONNULL_BEGIN

@interface A2SIpPhoneDirectoryEntry : OFObject <OFSerialization>

@property (retain,nonatomic) OFString* name;
@property (retain,nonatomic) OFString* telephone;
@property (retain,nonatomic) OFString* office;
@property (retain,nonatomic) OFString* mobile;

/**
 * @brief The object serialized into an IpPhoneDirectoryEntry XML element.
 */
@property (readonly, nonatomic) OFXMLElement *XMLElementBySerializing;

- (instancetype)initWithSerialization: (OFXMLElement *)element;

- (OFString*)description;

@end

OF_ASSUME_NONNULL_END
