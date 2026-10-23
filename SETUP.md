# Poker Night Shared

This folder contains a browser-based poker night companion. It keeps a blind timer, player buy-ins, payout estimates and cash-game settlement in sync for people in the same room.

The app is **not connected to a live backend until you configure Supabase**. It does not process or hold money.

## Connect a Supabase project

1. Create a Supabase project.
2. In the Supabase dashboard, enable **Anonymous Sign-Ins** under Authentication sign-in providers.
3. Open the SQL Editor and run the complete contents of `setup.sql`.
4. Publish `index.html` on a static HTTPS host (or serve this folder from a local web server for a private trial). The Supabase JavaScript client and fonts load from external CDNs, so the browser needs an internet connection.
5. Open the published app and choose **Connect**. The Cypress Poker project URL and **publishable key** are pre-filled; the app saves connection details on that device.
6. Create a room, then share the displayed eight-character code with players. Each person opens the same hosted app, connects with the same project details and joins with the code.

Never enter a Supabase `service_role` key in the browser. The app only needs the public anon/publishable key; database row-level security and anonymous user membership protect room data.

## Included behavior

- Real-time room state through Supabase Realtime.
- Blind timer and 12 levels, with 15-minute levels.
- Player names, $20 buy-ins/rebuys, prize pool and configurable top-five payout split.
- Cash-outs and suggested payments when the cash amounts balance the buy-ins.
- Room creation and joining through short invite codes.

Room changes are shared among room members. The current version uses last-write-wins updates to the shared game state, so avoid editing the same field from multiple devices at the same moment. For a public deployment, consider adding rate limits, room expiration, and a host/participant permission model.
