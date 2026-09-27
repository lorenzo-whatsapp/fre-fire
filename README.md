# Android Cloud Runner (Large APKs via Releases)

The repository contains only the workflow and scripts. Large APKs stay outside the normal Git repository as GitHub Release assets.

## Setup

1. Create a **Public** GitHub repository.
2. Upload the contents of this project to the repository and push to `main`.
3. Open **Releases** → **Create a new release**.
4. Create a tag, for example `v1`.
5. Under the release's **Assets**, upload your APK file(s), such as `app1.apk` and `app2.apk`.
6. Open **Actions** → **Android Cloud Runner** → **Run workflow**.
7. Choose 30, 60, 90, or 120 minutes.

The workflow downloads every `.apk` asset from the **latest release**, starts the Android Emulator, installs and launches those apps, then keeps the emulator running.

## Important

- Do not commit large APKs into the repository.
- GitHub documents a per-release-asset limit of under 2 GiB.
- The runner is temporary and is removed after the job ends.
- The emulator is headless (`-no-window`), so this workflow does not provide a remote Android screen or touch-control UI.
- Use APKs you are legally allowed to use.
