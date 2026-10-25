# Felt Poker Night Tracker

Felt is a dependency-free static web app. It can be hosted on any static HTTPS host; it does not need a server-side runtime, database, or user account to play. A hosting provider may require an account to publish the site. The app uses browser `localStorage` for game records, so history stays in the same browser on the same device and is not shared between players.

## Host it

Publish the contents of this folder as the root of a static site. For example:

- **GitHub Pages:** create or choose a repository, add these files, then enable Pages for the branch and folder containing `index.html`.
- **Netlify or Cloudflare Pages:** create a static site from this folder or repository. Leave the build command empty and set the publish directory to the folder containing `index.html`.

Use the resulting **HTTPS** URL on your iPhone. Do not open `index.html` in the Files preview; iOS may treat it as a document preview and disable the app's JavaScript or local storage.

## Add to iPhone Home Screen

Open the hosted HTTPS URL in Safari, tap **Share**, then choose **Add to Home Screen**. The app shell can then load offline after its first successful visit. Game history stays in Safari's local storage for that site; clearing Safari website data or using a different browser/device removes or separates that history. Export/share settlement summaries before changing devices.

## Files

- `index.html` — the complete poker tracker UI and game logic.
- `manifest.webmanifest` and `icon.svg` — install metadata and app icon.
- `sw.js` — caches the static app files for offline loading after the first visit.
