#!/bin/zsh

echo "Creating a extension for gnome\n"
echo "Give name of extension"
read name
echo "Give description of extension"
read desc
echo "Give UUID of extension ( for e.g test@test.com )"
read uuid
echo "Give version of you gnome"
read gnomever

cd $HOME/.local/share/gnome-shell/extensions/
mkdir -p $uuid
cd $uuid
echo "Createing files\n"
echo "
const { GObject, St } = imports.gi;

const ExtensionUtils = imports.misc.extensionUtils;
const Me = ExtensionUtils.getCurrentExtension();
const PanelMenu = imports.ui.panelMenu;
const Mainloop = imports.mainloop;
const Main = imports.ui.main;
const GLib = imports.gi.GLib;
const Gio = imports.gi.Gio;

//my imports
const Functions = Me.imports.functions.Functions;

const prefix = '[MyExtension]'
let gschema
var settings

var HelloWorldButton = GObject.registerClass(
class HelloWorldButton extends PanelMenu.Button {
    _init() {
        super._init(0.0, 'Hello World');

        log(prefix, 'INIT')

        gschema = Gio.SettingsSchemaSource.new_from_directory(
            Me.dir.get_child('schemas').get_path(),
            Gio.SettingsSchemaSource.get_default(),
            false
        );

        settings = new Gio.Settings({
            settings_schema: gschema.lookup('org.gnome.shell.extensions."$name"', true)
        });

        let icon
        try {
            icon = new St.Icon({
                gicon: Gio.icon_new_for_string(Me.dir.get_path() + '/Images/sonic.png'),
                style_class: 'system-status-icon'
            });
        } catch (error) {
            log(`${prefix}: ${error}`)
        }

        this.connect('button_press_event', () => {
            log(prefix, 'clicked')
        });

        this.add_child(icon);
    }
});

class Extension {
    constructor() {
        this.intervalID = null;
    }

    enable() {
        this._indicator = new HelloWorldButton();
        Main.panel.addToStatusArea('hello-world', this._indicator);
    }

    disable() {
        this._indicator.destroy();
        this._indicator = null;
    }
}

function init() {
    return new Extension();
}" > extension.js

echo '
{
    "name": "'$name'",
    "description": "'$desc'",
    "uuid": "'$uuid'",
    "shell-version": [
        "'$gnomever'"
    ],
    "schemas": [
        "org.gnome.shell.extensions.'$name'"
    ]
}
' > metadata.json

echo '
// Class of external file with for e.g functions
var Functions = class {
    constructor() {
        log("[MyExtension] Function class created")
    }

    Test() {
        log("[MyExtension] Function class test")
    }
};' > functions.js

echo "
const Gio = imports.gi.Gio;
const Gtk = imports.gi.Gtk;

const ExtensionUtils = imports.misc.extensionUtils;
const Me = ExtensionUtils.getCurrentExtension();

function init() {
    // ExtensionUtils.initTranslations();
}

function buildPrefsWidget() {
    let gschema = Gio.SettingsSchemaSource.new_from_directory(
        Me.dir.get_child('schemas').get_path(),
        Gio.SettingsSchemaSource.get_default(),
        false
    );

    this.settings = new Gio.Settings({
        settings_schema: gschema.lookup('org.gnome.shell.extensions."$name"', true)
    });

    let frame = new Gtk.Box({
        orientation: Gtk.Orientation.VERTICAL,
    });

    let vbox = new Gtk.Box({
        orientation: Gtk.Orientation.VERTICAL,
    });
    vbox.set_margin_top(15);

    let stringSetting = createStringSetting();
    vbox.append(stringSetting);

    frame.append(vbox);

    frame.show();

    return frame;
}

function createStringSetting() {
    let hbox = new Gtk.Box({
        orientation: Gtk.Orientation.HORIZONTAL,
    });
    hbox.set_margin_top(5);

    let settingLabel = new Gtk.Label({
        label: 'Example String',
        halign: Gtk.Align.START
    });

    let settingEntry = new Gtk.Entry({
        text: this.settings.get_string('test')
    });
    settingEntry.connect('notify::text', (entry) => {
        this.settings.set_string('test', entry.text);
    });

    hbox.append(settingLabel);
    hbox.append(settingEntry);

    return hbox;
}
" > prefs.js

echo "" > stylesheet.css

mkdir schemas
echo '
<?xml version="1.0" encoding="UTF-8"?>
<schemalist gettext-domain="gnome-shell-extensions">
  <schema id="org.gnome.shell.extensions.'$name'" path="/org/gnome/shell/extensions/'$name'/">
    <key name="test" type="s">
      <default>&apos;x&apos;</default>
      <summary>string</summary>
      <description>x</description>
    </key>
    <key name="time" type="i">
      <default>5</default>
      <summary>string</summary>
      <description>int</description>
    </key>
  </schema>
</schemalist>
' > schemas/org.gnome.shell.extensions.$name.gschema.xml
glib-compile-schemas schemas/

mkdir images