#import <ObjFW/ObjFW.h>
#import "Exceptions/A2SEDSException.h"

#include <glib.h>
#include <gio/gio.h>
#include <libedataserver/libedataserver.h>
#include <libebook/libebook.h>

OF_ASSUME_NONNULL_BEGIN

@interface A2SEvolutionDataService : OFObject

- (ESourceRegistry*) retrieveRegistry;
- (ESource *) retrieveDefaultAddressbookSource;
- (EBookClient *) retrieveEBookClient;
- (OFArray *) retrieveContacts;

@end

OF_ASSUME_NONNULL_END
