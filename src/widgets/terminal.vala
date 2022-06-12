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
    public class TerminalWidget : Vte.Terminal {    
        GLib.Pid child_pid;

        public TerminalWidget () {
            this.set_hexpand (true);
            this.set_vexpand (true);
        }

        private void terminal_callback (Vte.Terminal terminal, GLib.Pid pid, Error? error) {
            if (pid != -1) {
                child_pid = pid;
            } else {
                print ("%s\n", error.message);
            }
        }

        public void set_active_shell (string dir = GLib.Environment.get_current_dir ()) {
            string shell = Vte.get_user_shell ();
            string?[] envv = null;

            envv = {
                // Set environment variables
            };

            this.spawn_async (Vte.PtyFlags.DEFAULT, dir, { shell }, envv, SpawnFlags.SEARCH_PATH, null, -1, null, terminal_callback);
        }
    }
}
