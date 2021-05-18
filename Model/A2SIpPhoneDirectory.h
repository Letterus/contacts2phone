#import <ObjFW/ObjFW.h>

#include <gio/gio.h>
#include <glib.h>
#include <libebook/libebook.h>

OF_ASSUME_NONNULL_BEGIN

@interface A2SIpPhoneDirectory : OFObject <OFSerialization>

@property (retain, nonatomic) OFMutableArray* entries;

/**
 * @brief The object serialized into an IPPhoneDirectory XML element.
 */
@property (readonly, nonatomic) OFXMLElement* XMLElementBySerializing;

- (instancetype)initWithSerialization:(OFXMLElement*)element;

- (void)importFromEvolutionBook:(GSList*)evolutionContacts;

@end

OF_ASSUME_NONNULL_END
