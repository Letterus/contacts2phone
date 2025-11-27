/*
 * Copyright 2021-2024 Johannes Brakensiek <letterus at devbeejohn.de>
 *
 * This software is licensed under the GNU General Public License
 * (version 2.0 or later). See the LICENSE file in this distribution.
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */
#include "EvolutionDataService.h"
#include <clocale>
#include <peel/GLib/functions.h>

using namespace peel;
namespace C2P {

RefPtr<Gio::ListStore>
EvolutionDataService::getAddressbookSources()
{
    setlocale(LC_ALL, "");
    UniquePtr<GLib::Error> error;

    auto registry = EDataServer::SourceRegistry::create_sync(/* cancellable */ nullptr, &error);
    if (G_UNLIKELY(error)) {
        GLib::printerr("Failed to create a source registry: %s\n", error->message);
        // throw exception?
    }

    auto sources = registry->list_sources("Address Book");

    RefPtr<Gio::ListStore> listStore = Gio::ListStore::create(Type::of<EDataServer::Source>());

    GLib::List::foreach (sources, [listStore] (gpointer data)
    {
        auto source = reinterpret_cast<EDataServer::Source *> (data);
        listStore->append(source);
    });

    GLib::List::free_full (std::move (sources).release_ref (), g_object_unref);
    return listStore;
}

UniquePtr<GLib::SList>
EvolutionDataService::retrieveContactsFromAddressbookSource(EDataServer::Source *addressbook)
{
    UniquePtr<GLib::SList> contacts;
    UniquePtr<GLib::Error> error;

    auto client = peel::EBook::BookClient::connect_sync (addressbook, /* timeout */ 1, /* cancellable */ nullptr, &error);
    if (G_UNLIKELY (error))
    {
            GLib::printerr ("Failed to connect to EBook: %s\n", error->message);
            // throw exception?
    }

    client->get_contacts_sync (/* sexp */ "", &contacts, /* cancellable */ nullptr, &error);
    if (G_UNLIKELY (error))
    {
            GLib::printerr ("Failed to get contacts: %s\n", error->message);
           // throw exception?
    }

    return contacts;
}
}  // namespace C2P
