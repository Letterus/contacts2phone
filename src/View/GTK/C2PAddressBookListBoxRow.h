/*
 * Copyright 2025 Johannes Brakensiek <letterus at devbeejohn.de>
 *
 * This software is licensed under the GNU General Public License
 * (version 2.0 or later). See the LICENSE file in this distribution.
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

#include <gtk/gtk.h>

#define C2P_ADDRESSBOOK_LIST_BOX_ROW_TYPE (c2p_addressbook_list_box_row_get_type())

G_DECLARE_FINAL_TYPE(C2PAddressBookListBoxRow, c2p_addressbook_list_box_row, C2P,
    ADDRESSBOOK_LIST_BOX_ROW, GtkListBoxRow)

C2PAddressBookListBoxRow *c2p_addressbook_list_box_row_new(void);
