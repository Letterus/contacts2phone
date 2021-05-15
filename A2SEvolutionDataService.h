#import <ObjFW/ObjFW.h>
#import "Exceptions/A2SEDSException.h"

#include <glib.h>
#include <gio/gio.h>
#include <libedataserver/libedataserver.h>
#include <libebook/libebook.h>

OF_ASSUME_NONNULL_BEGIN

@interface A2SEvolutionDataService : OFObject

@property (nonatomic) ESourceRegistry* registry;
@property (nonatomic) ESource* defaultAddressbookSource;
@property (nonatomic) EBookClient* client;
@property (nonatomic) GSList* contacts;

@end

OF_ASSUME_NONNULL_END
