#pragma once

/*
 * Copyright 2021-2025 Johannes Brakensiek <letterus at devbeejohn.de>
 *
 * This software is licensed under the GNU General Public License
 * (version 2.0 or later). See the LICENSE file in this distribution.
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#include <peel/EBook/EBook.h>
#include <peel/EDataServer/EDataServer.h>
#include <peel/Gio/Gio.h>

namespace C2P {
class EvolutionDataService {
	peel::RefPtr<peel::EDataServer::SourceRegistry> registry;
	peel::RefPtr<peel::EDataServer::Source> defaultAddressbookSource;

      public:

	peel::RefPtr<peel::Gio::ListStore>
	getAddressbookSources();

	peel::UniquePtr<peel::GLib::SList>
	retrieveContactsFromAddressbookSource(peel::EDataServer::Source *addressbook);
};
}  // namespace C2P
