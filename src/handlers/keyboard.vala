/* handlers/keyboard.vala
 *
 * Copyright 2022 Fyra Labs
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

namespace Fermion {
    private void action_select_all_handler (TerminalWidget terminal) {
        terminal.select_all ();
    }
    
    private void action_copy_handler (TerminalWidget terminal) {
        var clipboard = ((Window) ((Gtk.Application) GLib.Application.get_default ()).active_window).clipboard;
        clipboard.set_text (terminal.get_text_selected (Vte.Format.TEXT));
    }

    private void action_paste_handler (TerminalWidget terminal) {
        // idk, this works
        var clipboard = ((Window) ((Gtk.Application) GLib.Application.get_default ()).active_window).clipboard;
        clipboard.read_text_async.begin (null, (obj, res) => {
            try {
                on_get_text (clipboard.read_text_async.end (res), terminal);
            } catch (Error e) {
                print ("%s\n", e.message);
            }
        });
    }

    private void on_get_text (string? intext, TerminalWidget terminal) {
        if (intext == null) {
            return;
        }

        if (!intext.validate ()) {
            warning ("Dropping invalid UTF-8 paste");
            return;
        }

        var text = intext.strip ();

        string? unsafe_warning = null;

        if (((text.index_of ("sudo") > -1) || (text.index_of ("doas") > -1)) && (text.index_of ("\n") != 0)) {
            unsafe_warning = "The pasted text may be trying to gain administrative access";
        } else if (text.index_of ("\n") != -1 || text.index_of ("&&") != -1) {
            unsafe_warning = "The pasted text may contain multiple commands";
        }

        if (unsafe_warning != null) {
            var unsafe_paste_dialog = new UnsafePasteDialog (
                (Window) ((Gtk.Application) GLib.Application.get_default ()).active_window,
                unsafe_warning,
                text
            );

            unsafe_paste_dialog.returned.connect (() => {    
                unsafe_paste_dialog.destroy ();

                terminal.paste_text (text);
            });
        } else {
            terminal.paste_text (text);
        }
    }
}
