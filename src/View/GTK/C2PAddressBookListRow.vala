/*
 * Copyright 2025 Sergey Bugaev <bugaevc AT gmail DOT com>
 *
 * This software is licensed under the GNU General Public License
 * (version 2.0 or later). See the LICENSE file in this distribution.
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */
[CCode (lower_case_cprefix = "c2p_")]
namespace C2P {

	[GtkTemplate (ui = "/de/devbeejohn/c2p/AddressBookListRow.ui")]
	class AddressBookListRow : Gtk.ListBoxRow {
		[GtkChild]
		unowned Gtk.Label label_widget;

		public string label {
			get { return label_widget.label; }
			set { label_widget.label = value; }
		}

		public int num_contacts { get; set; }
	}
}