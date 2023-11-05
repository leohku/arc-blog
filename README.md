# Arc Blog (Beta)
Turn an Arc space into your personal website. I'm still actively developing this so any feedback would be welcome! Right now the pages on a website is just an `iframe` to the underlying Arc Note / Easel but I plan to write a parser to convert it to static markup soon.

## Installation
Here's the general steps:
1. Pull the project locally
2. Deploy `/server` on Vercel (it's a Next.js project)
3. Create a Vercel KV store in the project (whatever name is fine)
4. In the KV console, run `set secret_key <your_super_secret_key>`
5. Connect your personal domain to the Vercel project
6. Open the Xcode project in `/client`
7. Build it into an app
8. Type in your server URL (`https://...`), secret key, and select the space you want to sync
9. Press connect, and enjoy your new website!
