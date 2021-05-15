#import <ObjFW/ObjFW.h>
#import "A2SEvolutionDataService.h"

@interface A2SApplication: OFObject <OFApplicationDelegate>
@end

OF_APPLICATION_DELEGATE(A2SApplication)

@implementation A2SApplication
- (void)applicationDidFinishLaunching
{
    A2SEvolutionDataService *service = [[A2SEvolutionDataService alloc] init];
    
    GSList* contacts = service.contacts;
    
    for(GSList *element = contacts; element != NULL; element = element->next)
    {
        EContact *econtact = element->data;

        [OFStdOut writeLine: [OFString stringWithCString: e_contact_get(econtact, E_CONTACT_FULL_NAME)
                                                encoding: OFStringEncodingUTF8]];
    }

    [OFStdOut writeLine: @"Finished!"];
    [OFApplication terminate];
}

@end
