#import "A2SEvolutionDataService.h"

@implementation A2SEvolutionDataService

- (ESourceRegistry*) retrieveRegistry
{
    GCancellable *cble = g_cancellable_new();
    GError *err = NULL;
	
	ESourceRegistry* registry;
	
    @try {
        registry = e_source_registry_new_sync (cble, &err);
        g_assert((registry != NULL && err == NULL) || (registry == NULL && err != NULL));
        
        if(err != NULL)				   
            @throw [A2SEDSException exceptionWithDescriptionCString: err->message];
        
    } @catch (id e) {
        g_free(registry);
        registry = NULL;
        g_error_free (err);
        @throw e;
    }
    
    return registry;
}


- (ESource *) retrieveDefaultAddressbookSource
{
    ESourceRegistry* registry = [self retrieveRegistry];
    ESource *addressbook;

    @try {
        addressbook = e_source_registry_ref_default_address_book(registry);
        if(addressbook == NULL)		   
	        @throw [A2SEDSException exceptionWithDescription: @"Could not retrieve default addressbook from Evolution Data Server."];
	        
    } @catch (id e) {
        g_free(registry);
        registry = NULL;
	    @throw e;
    }
    
    return addressbook;
}


- (EBookClient *) retrieveEBookClient
{
    ESource *addressbook = [self retrieveDefaultAddressbookSource];
    EBookClient *client;

    GCancellable *cble = g_cancellable_new();
    GError *err = NULL;
	
    @try {
        client = (EBookClient*) e_book_client_connect_sync(addressbook, 5, cble, &err);

        g_assert((client != NULL && err == NULL) || (client == NULL && err != NULL));
	
        if(err != NULL)				   
            @throw [A2SEDSException exceptionWithDescriptionCString: err->message];
		    
    } @catch (id e) {
        g_free(client);
        client = NULL;
        g_error_free (err);
        @throw e;
    }
    
    return client;
}


- (OFArray *) retrieveContacts
{
    EBookClient *client = [self retrieveEBookClient];
    
    GSList *contactsList = NULL;
    const gchar *sexp = "";
    GCancellable *cble = g_cancellable_new();
    GError *err = NULL;
	
    @try {
        e_book_client_get_contacts_sync(client, sexp, &contactsList, cble, &err);
	
        g_assert((contactsList != NULL && err == NULL) || (contactsList == NULL && err != NULL));
	
        if(err != NULL)				   
            @throw [A2SEDSException exceptionWithDescriptionCString: err->message];
		    
    } @catch (id e) {
        g_free(client);
        client = NULL;
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
    
    return nil;
}

@end
