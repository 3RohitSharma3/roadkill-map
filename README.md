# Roadkill Map: Southlake & Grapevine

**Live at https://savelittlelife.org**

A phone-friendly web app where neighbors drop a pin on the exact spot they find a dead animal. Over a few weeks the pins show which two or three spots cause most of the deaths, which is the evidence a city or HOA needs.

## What it does

- Opens at street level where you are (green dot) when you allow location. If you say no, or you're outside the DFW area, it opens on Kimball Ave & Dove Rd
- **Map / Satellite** switch (top right): street map, or aerial photos with street names that show each lane, curb and median. The choice is remembered on that phone.
- **Report an animal**: tap "Use my location" or slide the map under the pin, then choose the animal, the time, and an optional note
- **Pins view**: every report, colored by day or night
- **Hotspots view**: reports grouped into blocks of about 90 m, with a count on each
- **Top spots**: the five worst locations, plus a CSV download to send to the city
- **Street View** button on every pin and in Top spots: Google's drive-by photos of that exact spot. Without a Google key it opens Google Maps; with a free key it opens inside the app (see below)
- Each phone can remove its own pins (tap the pin, then tap Remove twice)
- Nobody can tell which pins came from the same phone

## Files

| File | Purpose |
| --- | --- |
| `index.html` | The whole app |
| `setup.sql` | One-time database setup |

## Try it first

Open `index.html` in a browser. With no database connected it runs in try-out mode and saves pins on that device only.

## Go live (about 15 minutes, free)

### 1. Create the shared database

1. Sign up at https://supabase.com and create a project (pick a US region).
2. Open the project's SQL editor, paste in all of `setup.sql`, and run it.
3. In the project's API settings, copy the **Project URL** and the public **publishable** key (older projects call it the **anon** key). Never use the secret or service-role key.

### 2. Connect the app

Near the bottom of `index.html`, fill in the two blank values:

```js
const CONFIG = {
  SUPABASE_URL: "https://YOUR-PROJECT.supabase.co",
  SUPABASE_KEY: "YOUR-PUBLISHABLE-KEY",
```

### 3. Put it online

The app must be served over `https` for phone GPS to work. Either of these is free:

- **Netlify Drop**: go to https://app.netlify.com/drop and drag in the folder containing `index.html`.
- **GitHub Pages**: push the folder to a repository and turn on Pages for it.

Share the resulting link with neighbors. This project uses the custom domain savelittlelife.org (registered at Squarespace Domains; four GitHub Pages A records for `@` and a `www` CNAME to `3rohitsharma3.github.io`), set in the repo's Pages settings, which also creates the `CNAME` file. On a phone, "Add to Home Screen" makes it open like an app.

### 4. Optional: Street View inside the app (free)

Google's Maps Embed API shows Street View inside the app at no charge, with no usage limit, but Google requires an account with billing turned on.

1. Go to https://console.cloud.google.com, create a project (for example `roadkill-map`), and add a billing account when asked.
2. Open **APIs & Services → Library**, search for **Maps Embed API**, and click **Enable**. Don't enable any other Maps API.
3. Open **APIs & Services → Credentials → Create credentials → API key**. Then edit the key:
   - **Application restrictions:** Websites. Add `https://savelittlelife.org/*`, `https://www.savelittlelife.org/*`, `https://3rohitsharma3.github.io/*`, and `http://localhost:8791/*` for testing on your computer.
   - **API restrictions:** Restrict key → **Maps Embed API** only.
4. Optional peace of mind: in **Billing → Budgets & alerts**, set a $1 budget with email alerts.
5. Paste the key into `GOOGLE_EMBED_KEY` in `index.html`. This key is meant to be visible in the page; the restrictions above stop others from using it.

## Good to know

- **Anyone with the link can add pins.** That keeps reporting easy, but it means a stranger could add junk. You can delete any row from the `sightings` table in Supabase. If abuse becomes a problem, the next step is a shared passcode or sign-in.
- **Coverage area**: reports are accepted across roughly the DFW area. To change that, edit `BOUNDS` in `index.html` and the two `check` lines in `setup.sql`.
- **Night vs day**: a report counts as night if it was seen between 7 pm and 6 am Texas time.
- **Opening view**: change `HOME` and `HOME_ZOOM` in `index.html`.
- **Animal list**: edit `ANIMALS` in `index.html`.
- **Map tiles** come from OpenStreetMap's free tile server, and satellite photos from Esri's free World Imagery (credit is shown on the map). Both are fine for neighborhood-scale, non-commercial use. A very popular app should switch to a paid tile and imagery provider.
- **Free Supabase projects pause after about a week with no visits.** If nobody opens the map for a week, sign in to Supabase and click Restore. Regular use keeps it awake.
- **Tested so far**: try-out mode in a phone-sized browser, and `setup.sql` plus live mode against a local copy of the same database software Supabase runs (adding, reloading, removing, 2,500 reports, lost connection, and 15 checks that visitors can't edit, delete or see which phone added a pin). Also tested against the live Supabase project and the published site (same checks, plus adding, reloading and removing a pin). Not yet tested on a real phone.
