#import <ObjFW/ObjFW.h>

#include <glib.h>
#include <gio/gio.h>
#include <libebook/libebook.h>

OF_ASSUME_NONNULL_BEGIN

@interface A2SIpPhoneDirectory : OFObject

@property (retain, nonatomic) OFMutableArray* entries;

-(void) importFromEvolutionBook: (GSList*) evolutionContacts;

@end

OF_ASSUME_NONNULL_END
