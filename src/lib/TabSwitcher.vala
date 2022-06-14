/**
 * TabBar widget designed for a variable number of tabs.
 */
public class He.TabSwitcher : He.Bin, Gtk.Buildable {
    /**
     * The internal Gtk.Notebook. This should only be accessed by a widget implementation
     */
    public Gtk.Notebook notebook;

    /**
     * The number of tabs in the TabSwitcher
     */
    public int n_tabs {
        get { return notebook.get_n_pages (); }
    }

    /**
     * The list of tabs in the TabSwitcher
     */
    public GLib.List<Tab> tabs {
        get {
            _tabs = new GLib.List<Tab> ();
            for (var i = 0; i < n_tabs; i++) {
                _tabs.append (notebook.get_tab_label (notebook.get_nth_page (i)) as Tab);
            }
            return _tabs;
        }
    }
    GLib.List<Tab> _tabs;

    public enum TabBarBehavior {
        ALWAYS = 0,
        SINGLE = 1,
        NEVER = 2
    }

    /**
     * The behavior of the tab bar and its visibility
     */
    public TabBarBehavior tab_bar_behavior {
        set {
            _tab_bar_behavior = value;
            update_tabs_visibility ();
        }

        get { return _tab_bar_behavior; }
    }
    private TabBarBehavior _tab_bar_behavior;


    /**
     * The current visible tab
     */
    public Tab current {
        get { return tabs.nth_data (notebook.get_current_page ()); }
        set { notebook.set_current_page (tabs.index (value)); }
    }

    /**
     * Insert a new tab into the TabSwitcher.
     *
     * To append a tab, you may use -1 as the index.
     */
    public uint insert_tab (Tab tab, int index) {
        index = this.notebook.insert_page (tab.page_container, tab, index <= -1 ? n_tabs : index);
        tab.set_size_request (tab_width, -1);
        this.recalc_size ();
        return index;
    }

    private Tab? old_tab; //stores a reference for tab_switched
    private const int MIN_TAB_WIDTH = 80;
    private const int MAX_TAB_WIDTH = 220;
    private int tab_width = MAX_TAB_WIDTH;

    public signal void tab_added (Tab tab);
    public signal void tab_removed (Tab tab);
    public signal void tab_switched (Tab? old_tab, Tab new_tab);
    public signal void new_tab_requested ();

    /**
     * Create a new TabSwitcher
     */
    public TabSwitcher () {}

    construct {
        notebook = new Gtk.Notebook ();
        notebook.set_can_focus (false);
        notebook.set_scrollable (true);
        notebook.set_show_border (false);
        _tab_bar_behavior = TabBarBehavior.ALWAYS;

        var add_button = new He.TintButton.from_icon ("list-add-symbolic");
        add_button.margin_top = 6;
        add_button.margin_bottom = 6;
        add_button.tooltip_text = _("New Tab");

        notebook.set_action_widget (add_button, Gtk.PackType.END);

        add_button.clicked.connect (() => {
            new_tab_requested ();
        });

        this.destroy.connect (() => {
            notebook.switch_page.disconnect (on_switch_page);
            notebook.page_added.disconnect (on_page_added);
            notebook.page_removed.disconnect (on_page_removed);
        });

        notebook.switch_page.connect (on_switch_page);
        notebook.page_added.connect (on_page_added);
        notebook.page_removed.connect (on_page_removed);

        notebook.set_parent (this);
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BoxLayout));
    }

    ~TabSwitcher () {
        notebook.unparent ();
    }

    void on_switch_page (Gtk.Widget page, uint pagenum) {
        var new_tab = (page as TabPage)?.tab;

        // update property accordingly for previous selected tab
        if (old_tab != null)
           old_tab.is_current_tab = false;

        // now set the new tab as current
        new_tab.is_current_tab = true;

        tab_switched (old_tab, new_tab);

        old_tab = new_tab;
    }

    void on_page_added (Gtk.Widget page, uint pagenum) {
        var t = (page as TabPage)?.tab;

        insert_callbacks (t);
        tab_added (t);
        update_tabs_visibility ();
    }

    void on_page_removed (Gtk.Widget page, uint pagenum) {
        var t = (page as TabPage)?.tab;

        remove_callbacks (t);
        tab_removed (t);
        update_tabs_visibility ();
    }

    private void insert_callbacks (Tab tab) {
        //  tab.closed.connect (on_tab_closed);
        tab.close_others.connect (on_close_others);
        tab.close_others_right.connect (on_close_others_right);
    }

    private void remove_callbacks (Tab tab) {
        //  tab.closed.disconnect (on_tab_closed);
        tab.close_others.disconnect (on_close_others);
        tab.close_others_right.disconnect (on_close_others_right);
    }

    private void on_close_others (Tab clicked_tab) {
        tabs.copy ().foreach ((tab) => {
            if (tab != clicked_tab) {
                tab.closed ();
            }
        });
    }

    private void on_close_others_right (Tab clicked_tab) {
        var is_to_the_right = false;

        tabs.copy ().foreach ((tab) => {
            if (is_to_the_right) {
                tab.closed ();
            }
            if (tab == clicked_tab) {
                is_to_the_right = true;
            }
        });
    }

    private void update_tabs_visibility () {
        if (_tab_bar_behavior == TabBarBehavior.SINGLE)
            notebook.show_tabs = n_tabs > 1;
        else if (_tab_bar_behavior == TabBarBehavior.NEVER)
            notebook.show_tabs = false;
        else if (_tab_bar_behavior == TabBarBehavior.ALWAYS)
            notebook.show_tabs = true;
    }

    private void recalc_size () {
        if (n_tabs == 0) {
            return;
        }

        var offset = 130;
        tab_width = (this.get_allocated_width () - offset) / n_tabs;

        if (tab_width < MAX_TAB_WIDTH) {
            tab_width = MAX_TAB_WIDTH;
        } else {
            tab_width = MIN_TAB_WIDTH;
        }

        foreach (var tab in tabs.copy ()) {
            tab.set_size_request (tab_width, -1);
            tab.queue_resize ();
        }
    }
}