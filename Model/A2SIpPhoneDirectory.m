#import "A2SIpPhoneDirectory.h"
#include <ObjFW/OFMutableString.h>
#include <ObjFW/OFObject.h>
#import "A2SIpPhoneDirectoryEntry.h"
#import "../Exception/A2SEDSException.h"
#include <string.h>

const OFStringEncoding _encoding = OFStringEncodingUTF8;

@implementation A2SIpPhoneDirectory

- (instancetype)init
{
	self = [super init];

	_entries = nil;

	return self;
}

- (instancetype)initWithSerialization: (OFXMLElement *)element
{
    @throw [OFNotImplementedException exceptionWithSelector:@selector(initWithSerialization) object:self];
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
        BOOL gotPhoneNumber = NO;

        A2SIpPhoneDirectoryEntry* newEntry = [[A2SIpPhoneDirectoryEntry alloc] init];

        @try {
            [self addNameToEntry:newEntry fromEvolutionContact:econtact];
            if([self addTelephoneToEntry:newEntry fromEvolutionContact:econtact])
                gotPhoneNumber = YES;

            if([self addOfficeToEntry:newEntry fromEvolutionContact:econtact])
                gotPhoneNumber = YES;

            if([self addMobileToEntry:newEntry fromEvolutionContact:econtact])
                gotPhoneNumber = YES;

            if(!gotPhoneNumber)
                @throw [A2SEDSException exceptionWithDescription: @"Found no phone number."];

        } @catch(id e) {
            [newEntry release];
            continue;
        }

        [self.entries addObject:newEntry];
        //FIXME Always 0 ?!
        OFLog(@"Number of entries: %i", self.entries.count);

        OFLog(@"Added to Directory Entry: %@", [newEntry description]);

        [newEntry release];
    }
}

-(void)addNameToEntry:(A2SIpPhoneDirectoryEntry *)entry fromEvolutionContact:(EContact *)econtact
{
    char* fullname  = (char*) e_contact_get(econtact, E_CONTACT_FULL_NAME);
    char* givenname = (char*) e_contact_get(econtact, E_CONTACT_GIVEN_NAME);

    if([self isValidNameField:fullname]) {
        entry.name = [OFString stringWithCString: fullname
                                        encoding: _encoding];
    } else if([self isValidNameField:givenname]) {
        entry.name = [OFString stringWithCString: givenname
                                        encoding: _encoding];
    } else {
        @throw [A2SEDSException exceptionWithDescription: @"Name fields are empty."];
    }
}

-(BOOL)addTelephoneToEntry:(A2SIpPhoneDirectoryEntry *)entry fromEvolutionContact:(EContact *)econtact
{
    OFString* home    = [self getEContactField:E_CONTACT_PHONE_HOME fromEContact:econtact];
    OFString* home2   = [self getEContactField:E_CONTACT_PHONE_HOME_2 fromEContact:econtact];
    OFString* other   = [self getEContactField:E_CONTACT_PHONE_OTHER fromEContact:econtact];

    if ([self isValidPhoneField:home]) {
        entry.telephone = home;
        return YES;

    } else if ([self isValidPhoneField:home2]) {
        entry.telephone = home2;
        return YES;

    } else if ([self isValidPhoneField:other]) {
        entry.telephone = other;
        return YES;
    }

    return NO;
}

-(BOOL)addOfficeToEntry:(A2SIpPhoneDirectoryEntry *)entry fromEvolutionContact:(EContact *)econtact
{
    OFString* business   = [self getEContactField:E_CONTACT_PHONE_BUSINESS fromEContact:econtact];
    OFString* business2  = [self getEContactField:E_CONTACT_PHONE_BUSINESS_2 fromEContact:econtact];
    OFString* company    = [self getEContactField:E_CONTACT_PHONE_COMPANY fromEContact:econtact];

    if([self isValidPhoneField:business] && ![business isEqual:entry.telephone]) {
        entry.office = business;
        return YES;

    } else if ([self isValidPhoneField:business2] && ![business2 isEqual:entry.telephone]) {
        entry.office = business2;
        return YES;

    } else if ([self isValidPhoneField:company] && ![company isEqual:entry.telephone]) {
        entry.office = company;
        return YES;
    }
    
    return NO;
}

-(BOOL)addMobileToEntry:(A2SIpPhoneDirectoryEntry *)entry fromEvolutionContact:(EContact *)econtact
{
    OFString* mobile = [self getEContactField:E_CONTACT_PHONE_MOBILE fromEContact:econtact];
    OFString* pager  = [self getEContactField:E_CONTACT_PHONE_PAGER fromEContact:econtact];
    OFString* car    = [self getEContactField:E_CONTACT_PHONE_CAR fromEContact:econtact];

    if([self isValidPhoneField:mobile] && ![mobile isEqual:entry.telephone]) {
        entry.mobile = mobile;
        return YES;

    } else if ([self isValidPhoneField:pager] && ![pager isEqual:entry.telephone]) {
        entry.mobile = pager;
        return YES;

    } else if ([self isValidPhoneField:car] && ![car isEqual:entry.telephone]) {
        entry.mobile = car;
        return YES;
    }

    return NO;
}

-(BOOL)isValidNameField:(char*) nameField
{
    if(nameField != NULL && strcmp(nameField, "") != 0)
        return YES;

    return NO;
}

-(BOOL)isValidPhoneField:(OFString*) phoneField
{
    if(phoneField != nil && ![phoneField isEqual:@""] && [phoneField length] > 3)
        return YES;

    return NO;
}

-(OFString*)getEContactField:(EContactField) field fromEContact:(EContact *)econtact
{
    if(e_contact_get(econtact, field) != NULL)
        return [OFString stringWithCString: (char*) e_contact_get(econtact, field)
                                  encoding: _encoding];

    return nil;
}

- (OFXMLElement *)XMLElementBySerializing
{
    void *pool = objc_autoreleasePoolPush();

	OFXMLElement *element = [OFXMLElement elementWithName: @"IPPhoneDirectory"];

    for(A2SIpPhoneDirectoryEntry *entry in self.entries) {
        [element addChild:entry.XMLElementBySerializing];
        //OFLog(entry.stringBySerializing);
    }    

    [element retain];

	objc_autoreleasePoolPop(pool);

    return [element autorelease];
}

@end
