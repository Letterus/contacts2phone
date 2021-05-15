#import <ObjFW/ObjFW.h>

#include <glib.h>
#include <gio/gio.h>
#include <libebook/libebook.h>

OF_ASSUME_NONNULL_BEGIN

@interface A2SIpPhoneDirectoryEntry : OFObject

@property (retain,nonatomic) OFString* name;
@property (retain,nonatomic) OFString* telephone;
@property (retain,nonatomic) OFString* office;
@property (retain,nonatomic) OFString* mobile;

@end

OF_ASSUME_NONNULL_END
