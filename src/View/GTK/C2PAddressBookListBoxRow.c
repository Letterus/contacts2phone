/*
 * Copyright 2025 Johannes Brakensiek <letterus at devbeejohn.de>
 *
 * This software is licensed under the GNU General Public License
 * (version 2.0 or later). See the LICENSE file in this distribution.
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "C2PAddressBookListBoxRow.h"

typedef enum {
	PROP_LABEL = 1,
	PROP_NUMBER_CONTACTS,
	N_PROPERTIES
} C2PAddressBookListBoxRowProperty;

static GParamSpec *obj_properties[N_PROPERTIES] = {
    NULL,
};

struct _C2PAddressBookListBoxRow {
	GtkListBoxRow parent_type;

	GtkLabel *labelWidget;
};

G_DEFINE_TYPE(C2PAddressBookListBoxRow, c2p_addressbook_list_box_row, GTK_TYPE_LIST_BOX_ROW)

static void c2p_addressbook_list_box_row_dispose(GObject *gobject)
{
	gtk_widget_dispose_template(GTK_WIDGET(gobject), C2P_ADDRESSBOOK_LIST_BOX_ROW_TYPE);

	G_OBJECT_CLASS(c2p_addressbook_list_box_row_parent_class)->dispose(gobject);
}

static void c2p_addressbook_list_box_row_finalize(GObject *gobject)
{
	C2PAddressBookListBoxRow *self = C2P_ADDRESSBOOK_LIST_BOX_ROW(gobject);

	g_object_unref(self->labelWidget);

	G_OBJECT_CLASS(c2p_addressbook_list_box_row_parent_class)->finalize(gobject);
}

static void c2p_addressbook_list_box_row_set_property(
    GObject *object, guint property_id, const GValue *value, GParamSpec *pspec)
{
	C2PAddressBookListBoxRow *self = C2P_ADDRESSBOOK_LIST_BOX_ROW(object);

	switch ((C2PAddressBookListBoxRowProperty)property_id) {
	case PROP_LABEL:
		gtk_label_set_label(GTK_LABEL(self->labelWidget), g_value_get_string(value));
		break;

	case PROP_NUMBER_CONTACTS:
		// Do nothing right now
		break;

	default:
		/* We don't have any other property... */
		G_OBJECT_WARN_INVALID_PROPERTY_ID(object, property_id, pspec);
		break;
	}
}

static void c2p_addressbook_list_box_row_get_property(
    GObject *object, guint property_id, GValue *value, GParamSpec *pspec)
{
	C2PAddressBookListBoxRow *self = C2P_ADDRESSBOOK_LIST_BOX_ROW(object);

	switch ((C2PAddressBookListBoxRowProperty)property_id) {
	case PROP_LABEL:
		g_value_set_string(value, gtk_label_get_label(self->labelWidget));
		break;

	case PROP_NUMBER_CONTACTS:
		// Do nothing right now
		break;

	default:
		/* We don't have any other property... */
		G_OBJECT_WARN_INVALID_PROPERTY_ID(object, property_id, pspec);
		break;
	}
}

static void c2p_addressbook_list_box_row_class_init(C2PAddressBookListBoxRowClass *klass)
{
	G_OBJECT_CLASS(klass)->dispose = c2p_addressbook_list_box_row_dispose;

	GObjectClass *gobject_class = G_OBJECT_CLASS(klass);

	obj_properties[PROP_NUMBER_CONTACTS] =
	    g_param_spec_uint("number-contacts", "Number of contacts",
	        "Number of contacts the addressbook contains", 0, G_MAXINT, 0, G_PARAM_READWRITE);

	obj_properties[PROP_LABEL] = g_param_spec_string("label", "Label",
	    "Label of the address book", NULL, G_PARAM_READWRITE | G_PARAM_STATIC_STRINGS);

	gobject_class->set_property = c2p_addressbook_list_box_row_set_property;
	gobject_class->get_property = c2p_addressbook_list_box_row_get_property;
	g_object_class_install_properties(
	    gobject_class, G_N_ELEMENTS(obj_properties), obj_properties);

	GtkWidgetClass *widget_class = GTK_WIDGET_CLASS(klass);

	gtk_widget_class_set_template_from_resource(
	    widget_class, "/de/devbeejohn/c2p/res/GTK/UI/AddressBookListBoxRow.ui");

	gtk_widget_class_bind_template_child(widget_class, C2PAddressBookListBoxRow, labelWidget);
}

static void c2p_addressbook_list_box_row_init(C2PAddressBookListBoxRow *self)
{
	gtk_widget_init_template(GTK_WIDGET(self));
}

C2PAddressBookListBoxRow *c2p_addressbook_list_box_row_new()
{
	return g_object_new(C2P_ADDRESSBOOK_LIST_BOX_ROW_TYPE, NULL);
}
