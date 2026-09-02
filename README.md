# CC Web Browser v26

CC Web Browser is a web browser for CC: Tweaked. 

## What's different from the original CC Web Browser?

Version 26 is a complete rewrite of the original CC Web Browser. It throws out buggy HTML parsing and replaces it with a custom JSON based language CWML (CC Web Markup Language).

CWML is a simple JSON based markup language that allows for easy creation of web pages that can be rendered in the CC Web Browser. There is also CWSS (CC Web Style Sheets) which allows for easy styling of CWML pages. However, you could write a proxy to translate HTML to CWML and CWSS.

## Features

- Markup (CWML) **[*In progress*]**
- Theming (CWSS) **[*Not yet implemented*]**
- HTTP and HTTPS support **[*Complete*]**
- Local file support **[*Complete*]**
- Rednet hosting support **[*Not yet implemented*]**
- Interactive elements such as buttons, text inputs, and checkboxes **[*Not yet implemented*]**
- Hyperlinks and navigation **[*Not yet implemented*]**
- Tabbed browsing **[*Not yet implemented*]**

## License

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/ or see [LICENSE](LICENSE). v2.001-alpha is excluded from this license.

## Legacy versions

Legacy versions have be republished to this repository for archival purposes. They are not recommended for use. The license status is unknown.

- [v1.0.0](legacy/v1.0.0-browser.lua) - The first version of the CC Web Browser, released on July 11, 2020. [forum post](https://forums.computercraft.cc/index.php?topic=197) License: MPL-2.0
- [v2.001-alpha](legacy/v2.001-alpha-browser.lua) - An alpha version of a remade CC Web Browser, released on January 20, 2021. This version was never completed and is not recommended for use. [forum post](https://forums.computercraft.cc/index.php?topic=281) License: Unknown
