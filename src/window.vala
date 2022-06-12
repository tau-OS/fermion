/* window.vala
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

 namespace Terminal {
    [GtkTemplate (ui = "/co/tauos/Terminal/window.ui")]
    public class Window : He.ApplicationWindow {       
        [GtkChild]
        private unowned Gtk.Box box;
        
        public Window (He.Application app, string? command, string? working_directory = GLib.Environment.get_current_dir ()) {
            Object (application: app);

            var terminal = new TerminalWidget ();
            terminal.set_active_shell (working_directory);
            box.append (terminal);
            if (command != null) {
                terminal.run_program (command, working_directory);
            }
        }

        public Window.with_working_directory (He.Application app, string? location = GLib.Environment.get_current_dir ()) {
            Object (application: app);

            var terminal = new TerminalWidget ();
            terminal.set_active_shell (location);
            box.append (terminal);
        }
    }
}
