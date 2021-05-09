#import <ObjFW/ObjFW.h>
#import "Exceptions/A2SEDSException.h"

#include <glib.h>
#include <gio/gio.h>
#include <libedataserver/libedataserver.h>
#include <libebook/libebook.h>


@interface A2SApplication: OFObject <OFApplicationDelegate>
@end

OF_APPLICATION_DELEGATE(A2SApplication)

@implementation A2SApplication
- (void)applicationDidFinishLaunching
{
    [self retrieveContactsFrom: [self retrieveAdressbookSource]];	

    [OFStdOut writeLine: @"Finished!"];
    [OFApplication terminate];
}

-(ESource*)retrieveAdressbookSource
{
    GCancellable *cble = g_cancellable_new();
    GError *err = NULL;
	    
    ESourceRegistry *registry;
    @try {
        registry = e_source_registry_new_sync (cble, &err);
        g_assert((registry != NULL && err == NULL) || (registry == NULL && err != NULL));
        
        if(err != NULL)				   
            @throw [A2SEDSException exceptionWithDescriptionCString: err->message];
        
    } @catch (id e) {
        g_free(registry);
        g_error_free (err);
        @throw e;
    }

    ESource *addressbook;
    @try {
        addressbook = e_source_registry_ref_default_address_book(registry);
        if(addressbook == NULL)		   
	        @throw [A2SEDSException exceptionWithDescriptionCString: err->message];
	        
    } @catch (id e) {
        g_free(registry);
	    @throw e;
    }
	
    return addressbook;
}

-(OFMutableArray*)retrieveContactsFrom: (ESource*) addressbookSource
{
    OFMutableArray *contactsArray = [[OFMutableArray alloc] init];
	
    GCancellable *cble = g_cancellable_new();
    GError *err = NULL;
	
    EBookClient *client;
    @try {
        client = (EBookClient*) e_book_client_connect_sync(addressbookSource, 5, cble, &err);

        g_assert((client != NULL && err == NULL) || (client == NULL && err != NULL));
	
        if(err != NULL)				   
            @throw [A2SEDSException exceptionWithDescriptionCString: err->message];
		    
    } @catch (id e) {
        g_free(client);
        g_error_free (err);
        @throw e;
    }

    GSList *contactsList = NULL;
    const gchar *sexp = "";
    cble = g_cancellable_new();
    err = NULL;
	
    @try {
        e_book_client_get_contacts_sync(client, sexp, &contactsList, cble, &err);
	
        g_assert((contactsList != NULL && err == NULL) || (contactsList == NULL && err != NULL));
	
        if(err != NULL)				   
            @throw [A2SEDSException exceptionWithDescriptionCString: err->message];
		    
    } @catch (id e) {
        g_free(client);
        g_error_free(err);
        @throw e;
    }

    for(GSList *element = contactsList; element != NULL; element = element->next)
    {
        EContact *econtact = element->data;
        //[contactsArray addObject: contact];
		
        [OFStdOut writeLine: [OFString stringWithCString: e_contact_get(econtact, E_CONTACT_FULL_NAME)
                                                encoding: OFStringEncodingUTF8]];
    }	
	
    return contactsArray;
}
@end
