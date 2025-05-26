/*
 * Copyright 2025 Johannes Brakensiek <letterus at devbeejohn.de>
 *
 * This software is licensed under the GNU General Public License
 * (version 2.0 or later). See the LICENSE file in this distribution.
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "C2PAddressBookListBoxRow.h"

struct _C2PAddressBookListBoxRow {
	GtkListBoxRow parent_type;

	GtkLabel *labelWidget;
  char* label;
};

G_DEFINE_TYPE(C2PAddressBookListBoxRow, c2p_addressbook_list_box_row, GTK_TYPE_LIST_BOX_ROW)

static void c2p_addressbook_list_box_row_dispose(GObject *gobject)
{
	gtk_widget_dispose_template(GTK_WIDGET(gobject), C2P_ADDRESSBOOK_LIST_BOX_ROW_TYPE);

	G_OBJECT_CLASS(c2p_addressbook_list_box_row_parent_class)->dispose(gobject);
}

static void c2p_addressbook_list_box_row_class_init(C2PAddressBookListBoxRowClass *klass)
{
	G_OBJECT_CLASS(klass)->dispose = c2p_addressbook_list_box_row_dispose;

	GtkWidgetClass *widget_class = GTK_WIDGET_CLASS(klass);

	gtk_widget_class_set_template_from_resource(
	    widget_class, "/c2p/gtk/ui/AddressBookListBoxRow.ui");

	gtk_widget_class_bind_template_child(widget_class, C2PAddressBookListBoxRow, labelWidget);
}

static void c2p_addressbook_list_box_row_init(C2PAddressBookListBoxRow *self)
{
	gtk_widget_init_template(GTK_WIDGET(self));

	// It is now possible to access self->entry and self->button
}

C2PAddressBookListBoxRow *c2p_addressbook_list_box_row_new()
{
	return g_object_new(C2P_ADDRESSBOOK_LIST_BOX_ROW_TYPE, NULL);
}
