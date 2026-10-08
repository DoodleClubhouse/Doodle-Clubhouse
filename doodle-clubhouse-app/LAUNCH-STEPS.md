# Getting Doodle Clubhouse onto the App Store (no Mac needed)

You'll use your **computer's web browser** and your **iPhone**. A cloud Mac (Codemagic) does the building.
Do the steps in order. Anything in `code font` should be typed or copied exactly.

---

## 1. Join the Apple Developer Program  *(iPhone, ~10 min, then wait 1–2 days)*
1. Install Apple's **Developer** app from the App Store.
2. Open it → **Account** → **Enroll now**. Enroll as an **Individual**, with your own name. It costs $99 USD a year.
3. Wait for the "Welcome to the Apple Developer Program" email. You need it for steps 3–8.

## 2. Put the project on GitHub  *(computer)*
1. Unzip `doodle-clubhouse-app.zip` on your computer.
2. On github.com click **+ → New repository**. Name it `doodle-clubhouse`, choose **Private**, then **Create repository**.
3. Click **uploading an existing file**. Drag in **everything inside** the unzipped folder, including the `www`, `resources`, `store` and `docs` folders, and the files `codemagic.yaml`, `package.json` and `capacitor.config.json`.
4. Click **Commit changes**.

## 3. Register the app's ID  *(computer, after Apple approves you)*
1. Go to **developer.apple.com/account** → **Certificates, IDs & Profiles** → **Identifiers** → **+**.
2. Choose **App IDs → App**, set Description `Doodle Clubhouse` and Bundle ID **Explicit** `com.doodleclubhouse.app`, then **Continue → Register**.
   - In-App Purchase is switched on automatically.
   - If Apple says the ID is taken, pick another, such as `com.yourname.doodleclubhouse`. Then change it in `capacitor.config.json` and in **both** places in `codemagic.yaml`.

## 4. Set up App Store Connect  *(computer: appstoreconnect.apple.com)*
1. **Business** (or Agreements, Tax, and Banking): accept the **Paid Apps** agreement and fill in bank and tax details. Purchases don't work until this is done.
2. **Apps → + → New App**:
   - Platform iOS, Name `Doodle Clubhouse`, language English
   - Bundle ID `com.doodleclubhouse.app`, SKU `doodleclubhouse001`
3. Open the new app → **App Information**. Copy the **Apple ID** number (about 10 digits).
4. Back on GitHub, open `codemagic.yaml` → pencil icon → replace `0000000000` with that number → **Commit changes**.
5. **Users and Access → Integrations → App Store Connect API → Team Keys → +**.
   - Name it `Codemagic`, access **App Manager**.
   - Download the **.p8 key file**. You can only download it once, so keep it safe.
   - Note the **Issuer ID** and the **Key ID**.
6. Optional, but saves money: apply for the **App Store Small Business Program** at developer.apple.com/app-store/small-business-program. Apple then takes 15% instead of 30%.

## 5. Connect Codemagic  *(computer: codemagic.io)*
1. **Sign up with GitHub** and allow access to the `doodle-clubhouse` repository.
2. **Team settings → Team integrations → Developer Portal → Connect.**
   - Name: `Doodle Clubhouse` (must match `codemagic.yaml`).
   - Paste the Issuer ID and Key ID, and upload the .p8 file.
3. **Team settings → Code signing identities → iOS certificates → Generate certificate.** Choose type *Apple Distribution* and the key from step 2.
4. **Apps → Add application → GitHub → doodle-clubhouse → codemagic.yaml.**
5. **Start new build** → workflow **Doodle Clubhouse (iOS)**. It takes about 15–25 minutes. When it's green, the app has been sent to TestFlight.

## 6. Privacy policy page
Apple needs a public web address for your privacy policy and support. Private GitHub repositories can't host free pages, so:
1. Create a second repository, `doodle-clubhouse-site`, and make it **Public**.
2. Upload `docs/index.html` from this project, as `index.html`.
3. **Settings → Pages →** Branch `main`, folder `/ (root)` → **Save**.
4. After a minute your page is live at `https://YOUR-GITHUB-NAME.github.io/doodle-clubhouse-site/`.
5. **Before uploading, edit the email address in that file.**

## 7. Test on your iPhone  *(TestFlight)*
1. In App Store Connect → your app → **TestFlight**. Wait for the build to finish "Processing" (about 10–30 min).
2. Add yourself under **Internal Testing**, then install Apple's **TestFlight** app on your iPhone and open the invite.
3. To test buying without paying:
   - Create a tester under **Users and Access → Sandbox → Test Accounts**.
   - On your iPhone, sign in to it under **Settings → App Store → Sandbox Account**.
4. Check drawing, stickers, dynamite, animation, Save/Share (after the grown-up question), buying the Brush Pack and **Restore purchase**.
5. If you can, ask someone with an **iPad** to test too.

## 8. Fill in the store page and submit
1. **Monetization → In-App Purchases → +**: Non-Consumable, product ID **`brush_pack`**. Fill in the rest from `store/STORE-LISTING.md`, including price $2.99, Family Sharing on, and the review screenshot `store/screenshots/review-unlock.png`.
2. **App Privacy:** answer that you **do not collect data**.
3. **Pricing and Availability:** Free.
4. **Version 1.0 page:**
   - Paste the description, keywords, subtitle and promo text from `STORE-LISTING.md`.
   - Upload `iphone-6.9in-*.png` to the 6.9" iPhone slot and `ipad-13in-*.png` to the 13" iPad slot.
   - Add the Support and Privacy URLs from step 6.
   - Set Category to **Kids, 6–8**, and answer the age rating questions (all **None**).
   - Choose the TestFlight build and tick the **Brush Pack** in-app purchase so it's reviewed with the app.
   - Paste the review notes from `STORE-LISTING.md`.
5. **Add for Review → Submit.** Review usually takes 1–3 days.

---

## Making changes later
Ask Claude for the change, then upload the new `www/index.html` to GitHub, replacing the old one. Codemagic builds a new TestFlight version. In App Store Connect, create a new version (e.g. 1.1), pick the new build and submit.
