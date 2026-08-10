# NextTalent

NextTalent is a World of Warcraft addon for **Classic Era & Hardcore** and **WotLK 3.3.5** that helps you follow established talent builds while leveling. Based on your current level and unspent talent points, it shows which talents to learn next—so you can spend less time checking guides and more time playing.

> NextTalent is in early development, but it is ready to be used. Features are being worked on - feedback and contributions are welcome.

## Features

- Recommends the next talent to learn based on your selected build when leveling up
- Saves your selected build separately for each character

NextTalent only provides recommendations. It does not spend talent points for you.

## Supported versions

This repository ships one addon folder with two `.toc` files, one per client:

- `NextTalent_Vanilla.toc` — Classic Era / Hardcore, talent data in `data/vanilla/`
- `NextTalent_Wrath.toc` — WotLK 3.3.5, talent data in `data/wrath/`

Each client only loads the `.toc` matching its own interface version, so both can be installed from the same folder. WotLK talent data is not populated yet (see the `TODO` markers in `data/wrath/`).

## Installation

1. Download or clone this repository.
2. Place the `NextTalent` folder in your WoW addons directory:
   - Classic Era: `World of Warcraft/_classic_era_/Interface/AddOns`
   - WotLK 3.3.5: `Interface/AddOns` in your 3.3.5 client
3. Make sure the folder is named `NextTalent` and contains the `.toc` file(s) above.
4. Restart World of Warcraft or reload the user interface.
5. Enable **NextTalent** from the AddOns menu on the character-selection screen.

## Feedback and contributions

NextTalent is growing, and reports about incorrect talent orders, missing builds, or other problems are appreciated. Open a GitHub issue or submit a pull request if you would like to help.
