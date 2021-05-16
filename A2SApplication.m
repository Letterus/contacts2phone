#include <ObjFW/OFStdIOStream.h>
#import <ObjFW/ObjFW.h>
#import "A2SEvolutionDataService.h"
#import "Model/A2SIpPhoneDirectory.h"

@interface A2SApplication: OFObject <OFApplicationDelegate>
@end

OF_APPLICATION_DELEGATE(A2SApplication)

@implementation A2SApplication
- (void)applicationDidFinishLaunching
{
    A2SEvolutionDataService *service = [[A2SEvolutionDataService alloc] init];
    A2SIpPhoneDirectory *directory = [[A2SIpPhoneDirectory alloc] init];
    
    [directory importFromEvolutionBook: service.contacts];

    [OFStdOut writeString:directory.stringBySerializing];

    [OFStdErr writeLine: @"Finished!"];
    [OFApplication terminate];
}

@end
