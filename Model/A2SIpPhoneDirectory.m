#import "A2SIpPhoneDirectory.h"
#import "A2SIpPhoneDirectoryEntry.h"
#import "../Exception/A2SEDSException.h"
#include <string.h>

@implementation A2SIpPhoneDirectory

- (instancetype)init
{
	self = [super init];

	_entries = nil;

	return self;
}

- (void) dealloc
{
    [_entries release];

    [super dealloc];
}

-(void) importFromEvolutionBook: (GSList*) evolutionContacts
{
    for(GSList *element = evolutionContacts; element != NULL; element = element->next) {
        EContact *econtact = element->data;

        A2SIpPhoneDirectoryEntry* newEntry = [[A2SIpPhoneDirectoryEntry alloc] init];

        @try {
            [self addNameToEntry:newEntry fromEvolutionContact:econtact];
            [self addTelephoneToEntry:newEntry fromEvolutionContact:econtact];
            [self addOfficeToEntry:newEntry fromEvolutionContact:econtact];
            [self addMobileToEntry:newEntry fromEvolutionContact:econtact];
        } @catch(id e) {
            [newEntry release];
            continue;
        }

        [self.entries addObject:newEntry];
        [newEntry release];
    }
}

-(void)addNameToEntry:(A2SIpPhoneDirectoryEntry *)entry fromEvolutionContact:(EContact *)econtact
{
    char* fullname  = (char*) e_contact_get(econtact, E_CONTACT_FULL_NAME);
    char* givenname = (char*) e_contact_get(econtact, E_CONTACT_GIVEN_NAME);
    OFStringEncoding encoding = OFStringEncodingUTF8;

    if([self isValidNameField:fullname]) {
        entry.name = [OFString stringWithCString: fullname
                                        encoding: encoding];

        OFLog(@"Full name is %@", [OFString stringWithCString: fullname
                                                     encoding: encoding]);
    } else if([self isValidNameField:givenname]) {
        entry.name = [OFString stringWithCString: givenname
                                        encoding: encoding];

        OFLog(@"Given name is %@", [OFString stringWithCString: givenname
                                                      encoding: encoding]);
    } else {
        free(fullname);
        free(givenname);
        @throw [A2SEDSException exceptionWithDescription: @"Empty names field."];
    }

}

-(BOOL)isValidNameField:(char*) nameField
{
    if(nameField != NULL && strcmp(nameField, "") != 0)
        return YES;

    return NO;
}
@end
