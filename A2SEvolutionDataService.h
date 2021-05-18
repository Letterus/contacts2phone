#import "Exception/A2SEDSException.h"
#import <ObjFW/ObjFW.h>

#include <gio/gio.h>
#include <glib.h>
#include <libebook/libebook.h>
#include <libedataserver/libedataserver.h>

OF_ASSUME_NONNULL_BEGIN

@interface A2SEvolutionDataService : OFObject

@property (nonatomic) ESourceRegistry* registry;
@property (nonatomic) ESource* defaultAddressbookSource;
@property (nonatomic) EBookClient* client;
@property (nonatomic) GSList* contacts;

@end

OF_ASSUME_NONNULL_END
