# Supabase Realtime: a tic-tac-toe room and a live order board (English demo)

Two small, runnable pages to try Supabase Realtime. **Tic-tac-toe** uses **Broadcast** (tell everyone what just happened) and **Presence** (who is here right now). The **live order board** keeps its state in a Postgres table and uses Realtime only to say "something changed", so late joiners and dropped connections can recover.

> This is a **personal learning project**, not official Supabase material, and not a sound design for a multiplayer game or production use.

The walkthrough is the Dev.to article that goes with this repo (link added when published).

## Files
| Path | What it is |
|---|---|
| `index.html` | The tic-tac-toe page (one file; supabase-js from a CDN, `esm.sh`) |
| `config.example.js` | Config template: copy to `config.js` (git-ignored) |
| `app/index.html`, `app/config.example.js` | The live order board |
| `sql/app/01_orders.sql` | `orders` table, demo policies, Realtime publication, 4 sample orders |
| `sql/app/02_reset_seed.sql` | Put the orders back to the starting state |
| `sql/app/99_cleanup.sql` | Drop the table |

## Prerequisites
- A Supabase project (Free plan is enough). The tic-tac-toe needs no tables.
- A browser and Python 3 (to serve the files locally).
- Your **publishable** key (Project Settings, API Keys). It is meant to be public, but keep it out of screenshots. Never put a `service_role` / secret key in `config.js`.

## Tic-tac-toe
```bash
cp config.example.js config.js      # fill in the URL and the publishable key
python3 -m http.server 8765 --bind 127.0.0.1
```
Open several tabs with different names:
- `http://127.0.0.1:8765/index.html?name=Alice&mark=X`
- `http://127.0.0.1:8765/index.html?name=Bob&mark=O`
- `http://127.0.0.1:8765/index.html?name=Carol` (spectator)
- add `&resync=1` for a tab that joins midway: it asks the players for the current board.

## Live order board
```bash
# 1. Run sql/app/01_orders.sql in the SQL Editor
cd app
cp config.example.js config.js
python3 -m http.server 8765 --bind 127.0.0.1
# open http://127.0.0.1:8765/index.html?name=Alice and ?name=Bob (a different name per tab)
```
With `?debug=1` you can drop the connection on purpose from the browser console with `window.__rt.disconnect()`.

## What I measured (2026-10-22, tabs on one computer, one region)
- Tic-tac-toe, Broadcast: a move was visible in another tab after about 111 ms (one sample).
- Late joiner without `resync=1`: an **empty board** that even said "X's turn" while the game was waiting for O. With `resync=1`: the correct board and turn.
- Leaving: after I closed Bob's tab, he disappeared from Alice's roster in about 0.1 s (one sample).
- Order board, change through the database: 497, 739, 754, 764, 859 and 1,265 ms from a click in one tab to the card appearing in another (6 samples).
- The "Bob is looking" badge appeared on Alice's screen within about 1.5 s of Bob clicking a card (it was not there at 0.5 s).
- A late joiner (Carol) saw every order straight away, because the page reads the table on arrival.
- **A silent network stall** (traffic blocked, no close event): with the default 25 s heartbeat the page said "Connected" over stale data for **46 s**; with a 10 s heartbeat it flagged it after **16 s**. After traffic returned, it reconnected and reloaded the table in about 3 s.

## Cost
From the Supabase docs, checked 2026-10-22 (Free / Pro): Realtime messages 2 million / 5 million included, then USD 2.50 per million; peak concurrent connections 200 / 500 included, then USD 10 per 1,000. This demo fits comfortably in Free. I did not check how messages are counted, so I have no per-action estimate; something like streaming cursor movements to everyone would, I think, approach the limit quickly (not tried).

## Security (demo setup)
- The tic-tac-toe channel is **public**: anyone who knows how it works can join and send fake messages. I did not try private channels.
- Win/draw detection runs only in the browser, so it cannot stop cheating. If money or points are involved, decide results on the server.
- `orders` has demo policies that let **anyone** (no login) read, add and update rows. In a real app, restrict to logged-in users and narrow the rows and columns that can be updated.
- supabase-js is loaded with `@2` (major version only). Pin the version and serve it yourself for anything real.

## Not verified
- Other devices or networks (I used tabs on one computer).
- A tab that is really in the background: Playwright keeps its tabs "visible", so I could not reproduce background throttling.
- Many users, private channels, and how messages are counted for billing.
- Whether the 10 s heartbeat has a cost for many clients.

## Cleanup
Run `sql/app/99_cleanup.sql` (it also removes the table from the Realtime publication).

## License
MIT. See `LICENSE`.
