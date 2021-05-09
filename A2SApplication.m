#import <ObjFW/ObjFW.h>
#import "A2SEvolutionDataService.h"

@interface A2SApplication: OFObject <OFApplicationDelegate>
@end

OF_APPLICATION_DELEGATE(A2SApplication)

@implementation A2SApplication
- (void)applicationDidFinishLaunching
{
    A2SEvolutionDataService *service = [[A2SEvolutionDataService alloc] init];
    
    [service retrieveContacts];

    [OFStdOut writeLine: @"Finished!"];
    [OFApplication terminate];
}

@end
