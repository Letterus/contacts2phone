#import "A2SEvolutionDataService.h"

@implementation A2SEvolutionDataService

- (instancetype)init
{
    self = [super init];

    _registry = NULL;
    _defaultAddressbookSource = NULL;
    _client = NULL;
    _contacts = NULL;

    return self;
}

- (void)dealloc
{
    g_clear_object(&_registry);
    g_clear_object(&_defaultAddressbookSource);
    g_clear_object(&_client);
    g_slist_free_full(_contacts, g_object_unref);

    [super dealloc];
}

#pragma mark - Property getters

- (ESourceRegistry*)registry
{
    if (_registry != NULL)
        return _registry;

    _registry = [self retrieveRegistry];
    return _registry;
}

- (ESource*)defaultAddressbookSource
{
    if (_defaultAddressbookSource != NULL)
        return _defaultAddressbookSource;

    _defaultAddressbookSource = [self retrieveDefaultAddressbookSource];
    return _defaultAddressbookSource;
}

- (EBookClient*)client
{
    if (_client != NULL)
        return _client;

    _client = [self retrieveEBookClient];
    return _client;
}

- (GSList*)contacts
{
    if (_contacts != NULL)
        return _contacts;

    _contacts = [self retrieveContacts];
    return _contacts;
}

#pragma mark - Private methods - fetching data from EDS

- (ESourceRegistry*)retrieveRegistry
{
    GCancellable* cble = g_cancellable_new();
    GError* err = NULL;

    ESourceRegistry* registry;

    @try {
        registry = e_source_registry_new_sync(cble, &err);
        g_assert((registry != NULL && err == NULL) || (registry == NULL && err != NULL));

        if (err != NULL)
            @throw [A2SEDSException exceptionWithDescriptionCString:err->message];

    } @catch (id e) {
        g_clear_object(&registry);
        registry = NULL;
        g_error_free(err);
        @throw e;
    }

    return registry;
}

- (ESource*)retrieveDefaultAddressbookSource
{
    ESourceRegistry* registry = self.registry;
    ESource* addressbook;

    @try {
        addressbook = e_source_registry_ref_default_address_book(registry);
        if (addressbook == NULL)
            @throw [A2SEDSException exceptionWithDescription:@"Could not retrieve default addressbook from Evolution Data Server."];

    } @catch (id e) {
        g_clear_object(&registry);
        registry = NULL;
        @throw e;
    }

    return addressbook;
}

- (EBookClient*)retrieveEBookClient
{
    ESource* addressbook = self.defaultAddressbookSource;
    EBookClient* client;

    GCancellable* cble = g_cancellable_new();
    GError* err = NULL;

    @try {
        client = (EBookClient*)e_book_client_connect_sync(addressbook, 5, cble, &err);

        g_assert((client != NULL && err == NULL) || (client == NULL && err != NULL));

        if (err != NULL)
            @throw [A2SEDSException exceptionWithDescriptionCString:err->message];

    } @catch (id e) {
        g_clear_object(&client);
        client = NULL;
        g_error_free(err);
        @throw e;
    }

    return client;
}

- (GSList*)retrieveContacts
{
    EBookClient* client = self.client;

    GSList* contactsList = NULL;
    const gchar* sexp = "";
    GCancellable* cble = g_cancellable_new();
    GError* err = NULL;

    @try {
        e_book_client_get_contacts_sync(client, sexp, &contactsList, cble, &err);

        g_assert((contactsList != NULL && err == NULL) || (contactsList == NULL && err != NULL));

        if (err != NULL)
            @throw [A2SEDSException exceptionWithDescriptionCString:err->message];

    } @catch (id e) {
        g_clear_object(&client);
        g_error_free(err);
        @throw e;
    }

    return contactsList;
}

@end
