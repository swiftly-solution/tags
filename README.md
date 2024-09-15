<p align="center">
  <a href="https://github.com/swiftly-solution/weapon_restrictor">
    <img src="https://cdn.swiftlycs2.net/swiftly-logo.png" alt="SwiftlyLogo" width="80" height="80">
  </a>

  <h3 align="center">[Swiftly] Tags</h3>

  <p align="center">
    A simple plugin for Swiftly that implements tags on chat/scoreboard.
    <br/>
  </p>
</p>

<p align="center">
  <img src="https://img.shields.io/github/downloads/m3ntorsky/tags/total" alt="Downloads"> 
  <img src="https://img.shields.io/github/contributors/m3ntorsky/tags?color=dark-green" alt="Contributors">
  <img src="https://img.shields.io/github/issues/m3ntorsky/tags" alt="Issues">
  <img src="https://img.shields.io/github/license/m3ntorsky/tags" alt="License">
</p>



## Installation 👀
1. Download the newest [release](https://github.com/m3ntorsky/tags/releases)
2. Everything is drag & drop, so I think you can do it!

### Configuring the plugin 🧐
- After installing the plugin, you can change the prefix and the database settings from `addons/swiftly/configs/plugins/tags.json`

## Supported identifiers 🤝
 - `everyone`
 - `team:tt` 
 - `team:ct` 
 - `team:spec` 
 - `steamid:(steamid64)` Example: `steamid:7571572137123713`
 -  `vip:(group_name)` Example: `vip:group_1` [VIPCore](https://github.com/swiftly-solution/vip-core/releases) required
 -  `admin:group:(group_name)` Example: `admin:group:root` [Admins](https://github.com/swiftly-solution/admins/releases) required
 -  `admin:flags:(flags_string)` Example: `admin:flags:abc` [Admins](https://github.com/swiftly-solution/admins/releases) required

## Supported colors 🎨
`default`, `white`, `darkred`,  `lightpurple`, `green`, `olive`, `lime`, `red`, `gray`, `grey`, `lightyellow`, `yellow`, `silver`, `bluegrey`, `lightblue`, `blue`, `darkblue`, `purple`, `magenta`, `lightred`, `gold`, `orange`,`teamcolor`

## Available Commands  📋
- `sw_tags add <identifier> <tag> <color> <name_color> <msg_color> <scoreboard (0/1)>`
  - Adds a new tag with the specified properties. The scoreboard value should be 0 or 1.

- `sw_tags edit <identifier> <tag/color/name_color/msg_color/scoreboard> <value>`
  - Edits the specified property of an existing tag.

- `sw_tags remove <identifier>`
  - Removes the tag with the given identifier.

- `sw_tags list`
  - Lists all the tags currently in the system.

- `sw_tags reload`
  - Reloads the tags configuration from the database.


### Creating A Pull Request 😃

1. Fork the Project
2. Create your Feature Branch
3. Commit your Changes
4. Push to the Branch
5. Open a Pull Request

### Have ideas/Found bugs? 💡

Join [Swiftly Discord Server](https://swiftlycs2.net/discord) and send a message in the topic from `📕╎plugins-sharing` of this plugin!

---
