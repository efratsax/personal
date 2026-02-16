This is the master **Product Design Document (PDD)** for your application. It is structured to serve as the "Source of Truth" for your development team and can be fed directly into **Claude Code** or **GitHub Copilot** to generate the codebase.

---

# Product Design Document: [Project Name Pending]

**Version:** 1.0

**Status:** Final Specification

**Concept:** High-Intent, Ephemeral, Staked Dating Utility

---

## 1. Executive Summary

A "Quiet Luxury" dating utility that replaces endless swiping with scheduled real-world meetings. Users pin their availability on a map, stake a $10 commitment token, and verify their physical presence via Bluetooth. The app is stateless, ephemeral, and emphasizes intelligent, face-to-face interaction over digital hoarding.

---

## 2. Core Interaction Model: "Asymmetric Reveal"

To prioritize safety and reduce noise, the app uses a tiered disclosure system:

1. **The Pin (Initiator):** User A sets a time, location, and category (Coffee, Culture, Drinks). They choose a privacy level: **Public, Blurred, or Hidden.**
2. **The Knock (Joiner):** User B sees a "Fuzzy" neighborhood pin. To interact, they send a "Knock" (revealing their full profile + Reliability Score).
3. **The Reveal:** If User A accepts, their full profile is revealed to User B.
4. **The Stake:** Both users must commit 1 Token ($10).
5. **The Match:** Upon mutual staking, the **Exact Venue** is revealed, and a 50-message chat window opens.

---

## 3. Technical Architecture & Verification

### 3.1. The Reliability Engine (BLE)

The "Soul" of the app is the automated verification of the date.

* **Mechanism:** Bluetooth Low Energy (BLE) proximity detection.
* **Logic:** Once a match is "Live," both apps scan for the other’s unique `HandshakeID`.
* **Success Condition:** Both devices must be within 5-8 meters for a cumulative 15 minutes during the scheduled window.
* **Outcome:** $10 is refunded to both. Reliability scores increase.

### 3.2. Data Ephemerality

* **Stateless UI:** No "Saved Profiles," no "Likes" list, and no "History."
* **Hard Delete:** All match data, chat logs, and map pins are purged from the database 24 hours after the scheduled meeting time.

### 3.3. Tech Stack Recommendation

* **Frontend:** React Native (Expo) + Mapbox GL + `react-native-ble-manager`.
* **Backend:** Node.js (Fastify) + PostgreSQL (PostGIS extension for location queries).
* **Auth/Storage:** Supabase.

---

## 4. UI/UX Design Philosophy: "Quiet Luxury"

The interface must be clean, sophisticated, and devoid of "gamified" triggers.

### 4.1. Visual Identity

* **Palette:** Charcoal, Stone, Deep Sage, and muted Gold for the tokens.
* **Typography:** Minimalist sans-serif (Inter or Manrope).
* **Navigation:** A horizontal "Time Scrubber" at the top; a minimalist Map in the center.

### 4.2. Profile Charms (Personality Perks)

Instead of long bios, users select up to 3 "Charms" (minimalist 3D icons):

* *Examples:* Vinyl Record, Espresso Cup, Passport, Chess Piece.
* *Interaction:* Charms have a subtle "floating" animation and provide haptic feedback when tapped.

---

## 5. Feature Breakdown

| Feature | Description |
| --- | --- |
| **The Scrubber** | A horizontal day-selector (Next 7 days). Updates map pins in real-time. |
| **Fuzzy Pins** | Neighborhood-level circles that protect the Initiator's exact location until a match. |
| **Token Vault** | A simple wallet to buy/hold $10 "Commitment Tokens." |
| **Mission Control** | A countdown-based match screen with a "Radar" pulse for BLE discovery. |
| **Withdraw/Stay** | A prompt at  minutes allowing unmatched users to pull their pin or stay live. |

---

## 6. Business Logic & Success Metrics

### 6.1. Token Economics

* **The Barrier:** $10 fee to confirm a match.
* **The Reward:** High-rated users (4.5+) earn 1 "Loyalty Token" per month.
* **Revenue:** A small percentage of forfeited tokens (No-Shows) or a "Platform Fee" on token purchases.

### 6.2. Success KPIs

* **Match-to-Meet Rate:** Target > 50% (Industry average is < 10%).
* **No-Show Rate:** Target < 5%.
* **Gender Balance:** Target 50/50 through safety-first "Request to Reveal" features.

---

## 7. Claude Code Implementation Master Prompt

> "Act as a Senior Lead Engineer. Build the core of an app called 'Overlap.'
> 1. Create a PostGIS database schema for `AvailabilityPins` (Start, End, Location, Vibe).
> 2. Implement the 'Asymmetric Reveal' logic: Joiner knocks -> Initiator accepts -> User B stakes $10 -> Exact location revealed.
> 3. Develop a BLE background service using `react-native-ble-manager` that emits a 'Verified_Meeting' event when two specific user IDs are in proximity for 15 minutes.
> 4. Design a 'Quiet Luxury' UI in React Native: Charcoal/Stone palette, zero noise, horizontal time-scrubber, and frosted-glass bottom sheets."
> 
> 

---

### Final Next Step

This document is now ready to be used. You can copy this into a file named `PRD.md` and keep it as your primary reference.

**Would you like me to generate the first set of "System Prompts" for Claude Code to help it set up the Database schema specifically?**
