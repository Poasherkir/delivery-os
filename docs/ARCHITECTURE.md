# Delivery OS — Architecture & Implementation Plan

**Prepared for:** Malik (Poasherkir)
**Date:** 27 August 2026
**Status:** Pre-implementation architecture. No production code yet.

---

## 0. Bottom line up front

Six decisions define this product. Everything else follows from them.

| # | Decision | Why |
|---|---|---|
| 1 | **No backend in the MVP.** Local-first Flutter + Drift (SQLite). One tiny stateless optimizer endpoint. | You already require offline-first. A backend plus offline-first means building the data model twice and writing a sync engine in between. Local-first makes the device the source of truth and turns sync into an additive V2 feature. Saves 2–3 months. |
| 2 | **Order ingestion is the real problem, not route optimization.** | Your 46-section spec never says how orders get into the app. If a driver types 15 orders every morning, the app is dead in week one. This must be solved before anything else. |
| 3 | **The customer database is your geocoder.** | Algerian addresses do not geocode. No provider will resolve "Cité 500 Logements, Bt 12, Draria". Learned GPS pins keyed by phone number are the only accurate source, and they compound in value. |
| 4 | **Mapbox for matrices and tiles. Deep-link to Google Maps/Waze for navigation.** | Mapbox Matrix bills by element with a generous free tier and returns a 25×25 matrix in one request, which exactly matches a 5–20 order day. Building turn-by-turn is a three-month rabbit hole with zero differentiation. |
| 5 | **Skip OR-Tools for MVP.** Nearest-neighbour + 2-opt in pure Dart, on-device, offline. | For n ≤ 25 stops with one vehicle, local search lands within a few percent of optimal in under 50 ms. OR-Tools becomes necessary only when you add time windows and multiple vehicles (V2/V3). Keep the interface so you can swap it. |
| 6 | **Drift, not Isar.** | Isar's official releases stalled (3.1.0 is three years old, 4.0 never shipped stable). Only community forks are maintained. You are not putting a driver's money ledger on an abandoned engine. Drift is SQLite, actively maintained, transactional, and uses the same relational schema you would later run on Postgres. |

**Scope reality:** the full spec is 12–18 months of solo work. A version a real driver uses every day is 8–10 weeks part-time. This document plans for the second and preserves the road to the first.

---

## 1. Critical analysis: what is missing, wrong, or over-built

You asked me to find hidden problems and unnecessary complexity. This section is the most valuable part of the document.

### 1.1 Missing: how orders enter the app

This is the single biggest gap. The spec assumes orders exist. In reality a driver receives his batch as:

- a printed manifest (bordereau) from the agency, with barcodes
- a WhatsApp message or a photo of a list
- an Excel/CSV file
- the company's own driver app, which he must read from and re-enter

There is no legitimate API path for a driver. The carrier APIs that exist in Algeria (Yalidine's developer portal, and aggregators covering ZR Express, Maystro, NOEST, and the Ecotrack carriers) are **merchant-scoped**. They are credentials issued to the e-commerce seller who ships the parcel, not to the courier who delivers it. A driver will not have them.

**Ingestion ladder, in the order you should build it:**

| Stage | Method | Time per order | When |
|---|---|---|---|
| 1 | Barcode/QR scan of parcel label + phone entry | ~4 s | MVP |
| 2 | Fast form with phone-first customer autocomplete | ~15 s | MVP |
| 3 | Paste-a-list parser (WhatsApp/Excel text → parsed rows, driver confirms) | ~2 min for 15 | V1.5 |
| 4 | Photo of manifest → on-device OCR (ML Kit) → parsed rows | ~2 min for 15 | V1.5 |
| 5 | Carrier API import, if a company ever partners with you | instant | V3 |

Design the whole ingestion layer as `OrderSource` implementations feeding one `ImportedOrderDraft` model with a mandatory human confirmation step. Never write directly from a parser into the orders table.

### 1.2 Missing: returns, and they are 15–25% of the business

Your spec has `Failed` and stops there. Algerian COD reality is richer:

- first attempt fails, customer asks to reschedule → the parcel stays with the driver
- customer refuses at the door, the merchant is called, a discount is negotiated → the COD amount changes mid-delivery
- parcel goes back to the agency as a *retour* → some companies pay a partial fee, some pay nothing
- multiple delivery attempts across different days for the same parcel

Model this properly or the money will never balance. An order needs `attempt_count`, a `delivery_attempts` child table, and statuses covering `rescheduled`, `returned_to_agency`, and `cancelled_by_merchant`. The COD amount must be mutable with an audit trail, not a fixed number.

### 1.3 Missing: cash-on-hand and remittance

Your money model assumes the driver settles with the company at the end of every day. He often does not. He may hold cash for two or three days, then make a *versement* at the agency covering several batches at once.

This means:

- `daily_settlement` (what the day produced) and `remittance` (money physically handed over) are **different entities**
- the driver needs a running **cash on hand** figure, which is a genuine daily anxiety and a security concern when it reaches several hundred thousand dinars
- a remittance can cover a partial amount, or span multiple companies and multiple days

This is a real feature no generic delivery app offers. It is also a correctness requirement.

### 1.4 Missing: stop-desk versus home delivery

Roughly half of Algerian COD volume is *stop desk* (customer collects at the agency) rather than *à domicile*. Stop-desk parcels do not belong on the optimized route at all, but they do belong in the batch and in the money. If you route them, the driver's route is wrong on day one.

Add `delivery_type: home | stopdesk` and exclude stop-desk from route optimization while keeping it in the financial totals.

### 1.5 Missing: address structure

Algeria has **69 wilayas** and roughly 1,541 communes, and every carrier's pricing and routing is organized around them. Free-text addresses are unusable. Your address model must be:

```
wilaya_code → commune_id → free_text_detail → coordinates + confidence
```

Ship the wilaya/commune reference list as a bundled asset in the app. It makes the address field a two-tap picker instead of a typing exercise.

**The count is not stable, so never hardcode it.** Algeria went from 48 wilayas to 58 in 2019, and to 69 on 16 November 2025 with the creation of Aflou, Barika, Ksar Chellala, Messaad, Aïn Oussera, Boussaâda, El Abiodh Sidi Cheikh, El Kantara, Bir El Ater, Ksar El Boukhari and El Aricha. It will change again. Therefore:

- no `1..58` (or `1..69`) range constraint anywhere, in the schema or in validation
- no test asserting a row count or a contiguous code range
- a wilaya code is valid if and only if it exists in the bundled `wilayas` table

**Open question, to resolve before M4:** carriers often lag administrative reform, so a delivery company may still price and zone by the 58-wilaya structure while the state uses 69. If a `tiered_by_wilaya` rule from a real company does not line up with the bundled dataset, that is this problem surfacing — do not silently remap it.

### 1.6 Missing: Arabic and RTL

You listed dark mode and responsive layouts under UI/UX but not localization. Your users are Algerian drivers. The app needs Arabic (RTL) and French, with Darija-flavoured wording. Almost every local app does RTL badly. Doing it well is a visible quality signal. Retrofitting RTL after 40 screens is painful; do it from screen one.

### 1.7 Over-built: geofencing (cut it)

Section 16 proposes background geolocation to auto-mark arrival. Against this:

- the payoff is saving one tap
- Android background location on the OEMs that dominate the Algerian market (Xiaomi, Oppo, Infinix, Huawei) is killed aggressively by vendor battery managers, so it will work inconsistently and you will be debugging per-device behaviour forever
- it costs battery on a phone that must survive a ten-hour shift
- it needs a persistent notification and a scary permission prompt

**Recommendation:** foreground-only location while a route is active. One-tap "Arrived". Revisit in V3 with a proper foreground service if drivers ask for it. They will not.

### 1.8 Over-built: dispatcher dashboard, live tracking, auto-assignment, AI, heatmaps

Sections 26–30 describe a B2B SaaS with a customer that does not exist. Building them speculatively is the classic solo-developer failure. Everything there is V3, gated behind one condition: **a real delivery company signs a paid pilot.** Until then the only obligation is architectural, and that obligation is cheap (see §14).

### 1.9 Over-built: NestJS from scratch

You already know Supabase from BP Go and Bac DZ. When you do need a server, Supabase gives you Postgres, PostGIS, auth, storage, row-level security and realtime out of the box, which is most of your §31–§33 requirements. A hand-rolled NestJS API is more portable and more work. Given a solo timeline, use Supabase for the platform and add one small service only for optimization. Revisit NestJS if and when you have a paying B2B customer whose requirements outgrow it.

### 1.10 Correctness risk: floating-point money

Nowhere in the spec do you say how money is stored. If any dinar amount is ever a `double`, the driver's settlement will eventually be off by one and he will stop trusting the app permanently. **Store every monetary value as a signed integer in centimes.** Format only at the display layer.

---

## 2. Product architecture

### 2.1 Domain model

```
User (driver)
 └── DriverCompany (membership, active payment rule version)
      └── Company
           └── PaymentRule (versioned, immutable once used)

Batch (driver + company + service_date)
 └── Order
      ├── Customer ──┬── CustomerAddress (with learned pin + confidence)
      │              └── CustomerPhone (identity key)
      ├── DeliveryAttempt[]        (each attempt: outcome, time, geo, note)
      ├── ProofOfDelivery          (photo, geo, timestamp)
      └── OrderFinancials          (value, COD, fees, commission, collected)

Route (per driver, per day)
 └── RouteStop[]  (ordered, ETA, status) → Order

Ledger
 ├── DailySettlement   (immutable snapshot per batch/day)
 ├── Remittance        (cash physically handed to a company)
 ├── Expense           (fuel, parking, food, maintenance, other)
 └── CashPosition      (derived: collected − remitted − expenses)
```

**Key relationships:**

- Customer is permanent, identified by normalized phone. Orders are transient. A customer accumulates addresses, pins, and history across companies.
- Batch is the unit of daily work and the unit of settlement. One driver + one company + one date = one batch. A driver working two companies in one day has two batches and one route.
- Route spans batches. The driver drives one route per day even if the orders come from three companies. This is important and easy to get wrong.
- PaymentRule is versioned. Each order pins the rule version used at creation, so editing a company's rule never rewrites history.

### 2.2 System context (MVP)

```
┌──────────────────────────────────────────────┐
│  Flutter app (source of truth)               │
│                                              │
│  UI ── Riverpod ── Repositories ── Drift/SQLite
│                        │                     │
│              ┌─────────┴─────────┐           │
│              │ RoutingProvider   │ (interface)
│              │ RouteOptimizer    │ (interface)
│              └─────────┬─────────┘           │
└────────────────────────┼─────────────────────┘
                         │ (online only, cached)
              ┌──────────┴──────────┐
              │  Mapbox Matrix API  │  durations/distances
              │  Mapbox Tiles       │  map display
              └─────────────────────┘
                         │
              ┌──────────┴──────────┐
              │ Google Maps / Waze  │  turn-by-turn (deep link)
              └─────────────────────┘
```

Nothing else. No server, no auth, no account. The driver opens the app and it works.

### 2.3 System context (V2, when sync arrives)

```
Flutter app ──(outbox sync)── Supabase
                                ├── Postgres + PostGIS  (RLS per driver/company)
                                ├── Auth
                                ├── Storage (POD photos, signed URLs)
                                └── Realtime (dispatcher, V3)
                                        │
                             Optimizer service (Python/FastAPI + OR-Tools)
                                        │
                             OSRM (self-hosted, Algeria extract) — cost escape hatch
```

---

## 3. Complete feature map

| Domain | Feature | Tier |
|---|---|---|
| **Ingestion** | Barcode/QR scan → order draft | MVP |
| | Fast manual entry, phone-first | MVP |
| | Duplicate detection by phone | MVP |
| | Paste-list parser | V1.5 |
| | Manifest photo OCR | V1.5 |
| | CSV/Excel import | V1.5 |
| | Carrier API import | V3 |
| **Batches** | Create daily batch per company | MVP |
| | Batch progress counters | MVP |
| | Close/confirm batch | MVP |
| | Multi-company day | MVP |
| **Orders** | Full CRUD, status machine | MVP |
| | Home vs stop-desk | MVP |
| | Delivery attempts history | MVP |
| | Reschedule / return to agency | MVP |
| | Negotiated COD change with audit | V1.5 |
| | Priority & time windows | V2 |
| **Customers** | Persistent DB keyed by phone | MVP |
| | Multiple addresses per customer | MVP |
| | Learned GPS pin + confidence | MVP |
| | Order history, success rate | MVP |
| | Call / WhatsApp / navigate | MVP |
| | Problem-customer flag | V1.5 |
| **Companies** | CRUD, logo, contacts | MVP |
| | Versioned payment rules | MVP |
| | Per-company stats | MVP |
| | Per-wilaya fee tables | V2 |
| **Route** | Matrix fetch + cache | MVP |
| | NN + 2-opt optimizer (on-device) | MVP |
| | Manual reorder (drag) | MVP |
| | Route map with stops | MVP |
| | ETA per stop | MVP |
| | Re-optimize on failure/skip | MVP |
| | Time windows (OR-Tools) | V2 |
| | Live traffic-aware re-route | V2 |
| | Multi-driver VRP | V3 |
| **Delivery** | Next-stop card, one-tap actions | MVP |
| | Mark arrived / delivered / failed | MVP |
| | Failure reason taxonomy | MVP |
| | Photo POD + GPS + timestamp | MVP |
| | Signature capture | V2 |
| | OTP confirmation | V2 |
| | Geofence auto-arrive | V3 (probably never) |
| **Money** | Integer-centime ledger | MVP |
| | Rule engine evaluation | MVP |
| | Daily settlement snapshot | MVP |
| | Expenses | MVP |
| | Cash on hand | MVP |
| | Remittance (versement) tracking | MVP |
| | Per-km / per-hour earnings | V1.5 |
| | Shareable end-of-day PDF | V1.5 |
| **History** | Day list, drill-down | MVP |
| | Search across all orders | V1.5 |
| | Export CSV | V1.5 |
| **Analytics** | Core KPIs (success rate, orders/hr) | V1.5 |
| | Charts, trends | V2 |
| | Zone heatmaps | V3 |
| | AI performance analysis | V3 |
| **Platform** | Offline-first, no account | MVP |
| | AR/FR localization, RTL | MVP |
| | Dark/light theme | MVP |
| | Local encrypted backup/restore | V1.5 |
| | Cloud sync, multi-device | V2 |
| | Push notifications | V2 |
| | Dispatcher web app | V3 |
| | Live tracking | V3 |
| | Auto driver assignment | V3 |

---

## 4. MVP / V2 / V3 separation

**MVP (ship in 8–10 weeks).** One driver, one phone, no account, no internet required except for map tiles and the matrix call. Success criterion: a real driver uses it for a full week instead of his notebook.

Batches, orders, customers with learned pins, companies with payment rules, on-device route optimization, next-stop workflow, photo POD, complete money ledger with settlement and remittance, history, AR/FR, offline everything.

**V1.5 (weeks 11–16).** The quality-of-life layer that makes it stick: paste/OCR ingestion, end-of-day PDF for WhatsApp, encrypted backup/restore, negotiated-COD flow, basic analytics, CSV export.

**V2 (only after 20+ real daily users).** Cloud sync and multi-device, Supabase backend, OR-Tools optimizer service with time windows, signature and OTP proof, push notifications, richer analytics, dynamic re-routing with traffic.

**V3 (only after a paid company pilot).** Dispatcher web app, live tracking, auto-assignment, multi-driver VRP, heatmaps, AI assistants, billing and subscriptions.

---

## 5. Recommended tech stack

| Layer | Choice | Notes |
|---|---|---|
| Mobile | Flutter 3.x / Dart 3.x | Your existing strength |
| State | Riverpod | See §8.2 |
| Navigation | go_router | Same as BP Go |
| Local DB | **Drift** (SQLite) | See §6 |
| Map rendering | **`mapbox_maps_flutter`** (official SDK) | Mapbox's terms restrict tile consumption to their own SDKs, so `flutter_map` + Mapbox tiles is not a licensable route. Fallback if binary size or SDK complexity bites at M4: MapLibre with a ToS-clean tile source. |
| Matrix / routing | **Mapbox Matrix API** | See §5.2 |
| Turn-by-turn | Deep link: Google Maps → Waze → Yandex fallback | Do not build |
| Optimizer (MVP) | Pure Dart NN + 2-opt / Or-opt | On-device, offline |
| Optimizer (V2) | Python + FastAPI + OR-Tools | Behind the same interface |
| Barcode | `mobile_scanner` | |
| OCR (V1.5) | Google ML Kit on-device | Works offline, free |
| Backend (V2) | Supabase (Postgres 15 + PostGIS + Auth + Storage + Realtime) | |
| Routing fallback | Self-hosted OSRM, Geofabrik Algeria extract | Cost escape hatch |
| Dispatcher web (V3) | Next.js + TypeScript | As you proposed |
| CI | GitHub Actions | Analyze, test, build APK |

### 5.1 Local database comparison

| | Drift | Isar | ObjectBox | sqflite | Hive |
|---|---|---|---|---|---|
| Maintenance (2026) | **Active** | Official stalled at 3.1.0; forks only | Active | Active | Legacy |
| Model | Relational SQL | NoSQL | NoSQL | Raw SQL | K/V |
| Migrations | First-class | Weak | Manual | Manual | None |
| Transactions | Full ACID | Partial | Yes | Yes | No |
| Reactive queries | Yes (streams) | Yes | Yes | No | Limited |
| Built-in sync | No | No | Yes (paid) | No | No |
| Schema portability to Postgres | **Direct** | None | None | Direct | None |

**Choice: Drift.** Three reasons that matter here. First, financial data needs transactions and foreign keys; that is a SQL strength. Second, your local schema becomes your Postgres schema almost unchanged when V2 arrives, so you write the model once. Third, maintenance risk: a money ledger cannot sit on an engine whose official releases stopped three years ago.

ObjectBox is the one alternative worth a second look because it bundles sync, but it locks the sync layer behind a commercial license and its data model does not translate to Postgres.

### 5.2 Map and routing comparison

| | Mapbox | Google Maps Platform | OSRM (self-host) | GraphHopper | Valhalla |
|---|---|---|---|---|---|
| Algeria road coverage | OSM-based; good in cities, thin rurally | Best overall; strongest traffic | OSM-based (same as Mapbox) | OSM-based | OSM-based |
| Matrix limits | 25 coords/request (10 with traffic), 625 elements max | 625 elements max, billed **per element** | Unlimited, one request | Configurable | Configurable |
| Matrix billing | Per element, generous monthly free allowance | Per element; the $200 monthly credit was replaced in 2025/26 by usage caps + paid tiers | Free (your server) | Free (self-host) | Free (self-host) |
| Live traffic | Yes (`driving-traffic`, 10 coords) | Yes, best in class | No | No | No |
| Ops burden | None | None | You run and update a server | Medium | Medium |
| Offline | No | No | Possible on LAN | Possible | Possible |

**Choice for MVP: Mapbox.** A 20-order day means 21 coordinates including the driver's origin, which is one request of 441 elements, comfortably inside the free allowance even re-optimizing several times a day. Google's move away from the flat monthly credit toward capped tiers makes it the wrong economics for a bootstrapped Algerian product, and its Route Optimization API bills per shipment on an enterprise SKU.

**Escape hatch: OSRM.** The Geofabrik Algeria extract on a small VPS gives you unlimited free matrices with the same underlying OSM data. Do this only when Mapbox costs actually bite. Because everything sits behind a `RoutingProvider` interface, the swap is a configuration change, not a refactor.

**Navigation: do not build it.** Deep-link out. Drivers already have Google Maps or Waze installed, already trust them, and already have the best available Algeria traffic data in them. A native turn-by-turn SDK adds months, a large binary, high battery cost, and no differentiation.

### 5.3 Optimizer comparison

| | Dart NN + 2-opt | OR-Tools | Mapbox Optimization API | Google Route Optimization |
|---|---|---|---|---|
| Runs offline | **Yes** | No (server) | No | No |
| Cost | Free | Free (your compute) | Per request | Per shipment, enterprise SKU |
| Quality at n ≤ 25 | ~2–5% above optimal | Optimal-ish | Good | Best |
| Time windows | No | **Yes** | Limited | Yes |
| Multi-vehicle | No | **Yes** | No | Yes |
| Effort | ~200 lines | Separate service | Integration only | Integration only |

**Choice: pure Dart for MVP.** Nearest-neighbour construction plus 2-opt and Or-opt local search on the cached duration matrix. For 25 nodes this converges in well under 50 ms on a mid-range phone and, critically, **it works with no internet** once the matrix is cached. Move to an OR-Tools service when time windows and multi-vehicle become real requirements, which is V2 at the earliest.

---

## 6. Database schema

Written as Postgres + PostGIS (the V2 target). The Drift schema for MVP is the same tables minus PostGIS, with `lat`/`lng` as `REAL` columns and a `geohash` text column for proximity queries.

### 6.1 Conventions

- Primary keys are **UUIDv7**, generated client-side. This is non-negotiable: offline creation needs stable IDs and UUIDv7 keeps them time-sortable for index locality.
- **Which audit columns a table carries depends on its category** — owned mutable entity, append-only record, bundled reference data, purgeable cache, or local machinery. The five categories and the two deliberate exceptions (`route_stops`, `users`) are the table in `CONTRIBUTING.md` invariant 3. Not every table carries all five.
- **`outbox` is local machinery, not an append-only record.** It mutates: `attempts`, `last_error` and `synced_at` are all written during a sync pass. But it is not an owned entity either — it never syncs, it has no `version`, and tombstoning a queue row is meaningless. Synced rows are hard-deleted or trimmed by age.
- `version` increments on **every** write, including a soft delete. It is never left to a DAO to remember: `EntityStamper` produces the stamp and a guard fails the build on a write that bypasses it.
- All money is `BIGINT` in **centimes**. Never numeric, never float.
- Timestamps are `TIMESTAMPTZ`, always UTC. Business day is a separate `DATE` column (`service_date`) because a delivery at 00:30 belongs to the previous working day. Algeria is UTC+1 year-round with no DST, so that is a fixed offset rather than a timezone-database problem; only the cutoff hour is open.

#### SQLite specifics

The MVP runs this schema on SQLite, so four conventions are fixed here and every
query written from now on follows them.

- **Timestamps are stored as `INTEGER` milliseconds since the Unix epoch, UTC.**
  Not Drift's `dateTime()`, which stores Unix *seconds* — too coarse for
  `delivery_attempts` and `outbox`, where three parcels marked delivered in the
  same lift would come back in an arbitrary order.
- **Ordering is always `ORDER BY created_at, id`.** Milliseconds still collide.
  UUIDv7 is time-sortable and its canonical text form sorts lexicographically in
  chronological order, so the id breaks the tie deterministically rather than
  arbitrarily. A query that orders by `created_at` alone is a bug waiting for a
  busy morning.
- **Enums are stored as `TEXT`, by name.** Never as an ordinal: inserting a
  status into the middle of an enum would silently reassign every existing row,
  turning delivered orders into something else with no error anywhere. Decoding
  an unrecognised name **throws** and never falls back to a default — an unknown
  status is corrupt data, and defaulting to `pending` would resurrect a
  delivered order along with the money attached to it.
- **Business dates are stored as `TEXT` in `YYYY-MM-DD` form**, not as
  timestamps. `service_date`, `effective_from` and `covers_from`/`covers_to`
  are calendar dates, not instants: they have no time and no timezone, and
  giving them one invites exactly the 00:30 confusion §6.1 warns about. ISO
  text sorts correctly, is unambiguous, and is readable in a database browser.
  No converter yet — a `ServiceDate` value object arrives in M2 with the batch
  work and the cutoff-hour decision, and TEXT is the storage shape either way,
  so it needs no migration.
- **The SQLite build is bundled, and it is SQLCipher.** `package:sqlite3` 3.x
  ships its own binary through Dart hooks on every platform, including the test
  host, so there is no `sqlite3_flutter_libs` plugin and no `sqlite3.dll` to
  locate on Windows. The build is selected in `pubspec.yaml`:

  ```yaml
  hooks:
    user_defines:
      sqlite3:
        source: sqlcipher
  ```

  Chosen from the first schema commit rather than at M0-19 so the engine never
  changes underneath the data — M0-19 adds the key, it does not swap the binary.
  `sqlcipher_flutter_libs` is obsolete; its final release is an empty package.

### 6.2 Core DDL

```sql
CREATE EXTENSION IF NOT EXISTS postgis;

-- ============ IDENTITY ============
CREATE TABLE users (
  id            UUID PRIMARY KEY,
  phone         TEXT UNIQUE,           -- null until an account exists (V2)
  display_name  TEXT,                  -- null until the driver is asked; no
                                       -- signup, and a placeholder in a display
                                       -- field eventually gets shown to someone
  -- Nullable, and null means "follow the device". This stores the driver's
  -- *preference*, not its resolved value on one handset, because the preference
  -- is what syncs at V2: someone set to "follow the device" who moves to a
  -- French phone wants French, and storing the old phone's resolved `ar` would
  -- hand them Arabic with no way to understand why. No default, for the same
  -- reason — `ar` would record a choice nobody made.
  locale        TEXT,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at    TIMESTAMPTZ
);

-- ============ COMPANIES & RULES ============
CREATE TABLE companies (
  id            UUID PRIMARY KEY,
  owner_id      UUID NOT NULL REFERENCES users(id),
  name          TEXT NOT NULL,
  logo_path     TEXT,
  contact_phone TEXT,
  notes         TEXT,
  is_active     BOOLEAN NOT NULL DEFAULT true,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at    TIMESTAMPTZ,
  version       INT NOT NULL DEFAULT 1
);

-- Versioned and immutable once referenced by an order.
-- Append-only (invariant 3, category 2). A new rule is a new row at
-- rule_version + 1; there is no update path, ever.
CREATE TABLE payment_rules (
  id            UUID PRIMARY KEY,
  owner_id      UUID NOT NULL REFERENCES users(id),
  company_id    UUID NOT NULL REFERENCES companies(id),
  -- Business data, NOT the audit column from invariant 3. This is the number
  -- orders.payment_rule_version pins. Named rule_version so nobody "fixes" the
  -- collision later by attaching a stamper to it.
  rule_version  INT  NOT NULL,
  -- Raw JSON. Deliberately NOT deserialized through a typed model: rule specs
  -- are pinned per order and §12.2 requires that editing a company's rule never
  -- changes a historical settlement. A typed column would make every stored
  -- rule unreadable, or silently reinterpreted, the day the spec gains a field.
  -- The spec's own `version` field tells a version-aware parser which shape to
  -- expect. The database stores bytes; the domain decides meaning.
  spec          TEXT NOT NULL,       -- see §12 for the document schema
  effective_from DATE NOT NULL,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (company_id, rule_version)
);

-- ============ GEOGRAPHY REFERENCE (bundled asset) ============
CREATE TABLE wilayas (
  code       SMALLINT PRIMARY KEY,     -- no range constraint: see §1.5
  name_fr    TEXT NOT NULL,
  name_ar    TEXT NOT NULL,
  centroid   GEOGRAPHY(POINT,4326),    -- nullable: a dataset may omit it
  -- The loader NEVER deletes. Reform merges and renames wilayas, and
  -- customer_addresses holds foreign keys here, so a delete would orphan a real
  -- address — and a loader deciding which rows are safe to delete carries a
  -- partial-delete policy nobody can hold in their head. A row absent from an
  -- incoming dataset is retired instead. Pickers and search filter on
  -- is_retired = false; lookups by id ignore it, so an address pointing at a
  -- merged wilaya still resolves and still renders its name.
  is_retired BOOLEAN NOT NULL DEFAULT false
);

CREATE TABLE communes (
  id          INT PRIMARY KEY,
  wilaya_code SMALLINT NOT NULL REFERENCES wilayas(code),
  name_fr     TEXT NOT NULL,
  name_ar     TEXT NOT NULL,
  centroid    GEOGRAPHY(POINT,4326),   -- nullable: a dataset may omit it
  -- GeoJSON polygon, nullable. Point-in-polygon is the correct commune gate
  -- for promoting a captured pin (§10.5 gate 2); a radius from a centroid is
  -- not, because an Algiers commune is a few square kilometres and a Saharan
  -- one is thousands. Unused in M0. If the bundled dataset carries boundaries
  -- the column is already here; if not, gate 2 degrades as documented.
  boundary    TEXT,
  -- See wilayas.is_retired. Communes are where it earns its keep: the eleven
  -- wilayas created in November 2025 were carved out of existing ones, so
  -- commune shapes did not move but their parent did. A pre-reform dataset
  -- assigns them to a wilaya that no longer exists, and retiring rather than
  -- deleting absorbs that without breaking a single stored address.
  is_retired  BOOLEAN NOT NULL DEFAULT false
);

-- ============ CUSTOMERS ============
CREATE TABLE customers (
  id             UUID PRIMARY KEY,
  owner_id       UUID NOT NULL REFERENCES users(id),
  phone_e164     TEXT NOT NULL,            -- normalized: +213XXXXXXXXX
  phone_alt      TEXT,
  display_name   TEXT NOT NULL,
  notes          TEXT,
  risk_flag      TEXT NOT NULL DEFAULT 'none', -- none|watch|problem
  total_orders   INT NOT NULL DEFAULT 0,
  total_delivered INT NOT NULL DEFAULT 0,
  total_failed   INT NOT NULL DEFAULT 0,
  last_delivered_at TIMESTAMPTZ,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at     TIMESTAMPTZ,
  version        INT NOT NULL DEFAULT 1,
  UNIQUE (owner_id, phone_e164)
);

-- The learned-pin geocoder lives here.
-- On SQLite every GEOGRAPHY(POINT) below becomes latitude REAL, longitude REAL
-- and geohash TEXT (precision 9, prefix-queried). PostGIS and a GIST index are
-- the V2 equivalent; the geohash column is what replaces them until then.
CREATE TABLE customer_addresses (
  id             UUID PRIMARY KEY,
  owner_id       UUID NOT NULL REFERENCES users(id),
  customer_id    UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
  wilaya_code    SMALLINT NOT NULL REFERENCES wilayas(code),
  commune_id     INT NOT NULL REFERENCES communes(id),
  detail         TEXT,                       -- free text: cité, bloc, étage
  geo            GEOGRAPHY(POINT,4326),
  accuracy_m     INT,                        -- radius reported with the fix
  geo_confidence SMALLINT NOT NULL DEFAULT 0,
  -- 0 = none, 1 = commune centroid, 2 = geocoded string,
  -- 3 = driver-pinned on map, 4 = GPS-confirmed at delivery
  geo_source     TEXT,
  confirmed_deliveries INT NOT NULL DEFAULT 0,
  label          TEXT,                       -- "maison", "travail"
  is_primary     BOOLEAN NOT NULL DEFAULT false,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at     TIMESTAMPTZ,
  version        INT NOT NULL DEFAULT 1
);

-- ============ BATCHES & ORDERS ============
CREATE TABLE batches (
  id            UUID PRIMARY KEY,
  owner_id      UUID NOT NULL REFERENCES users(id),
  company_id    UUID NOT NULL REFERENCES companies(id),
  service_date  DATE NOT NULL,
  status        TEXT NOT NULL DEFAULT 'open',  -- open|closed|settled
  closed_at     TIMESTAMPTZ,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at    TIMESTAMPTZ,
  version       INT NOT NULL DEFAULT 1,
  UNIQUE (owner_id, company_id, service_date)
);

CREATE TABLE orders (
  id                UUID PRIMARY KEY,
  owner_id          UUID NOT NULL REFERENCES users(id),
  batch_id          UUID NOT NULL REFERENCES batches(id),
  company_id        UUID NOT NULL REFERENCES companies(id),
  customer_id       UUID REFERENCES customers(id),
  address_id        UUID REFERENCES customer_addresses(id),

  tracking_number   TEXT NOT NULL,
  delivery_type     TEXT NOT NULL DEFAULT 'home',   -- home|stopdesk
  status            TEXT NOT NULL DEFAULT 'pending',
  priority          SMALLINT NOT NULL DEFAULT 0,
  window_start      TIME,
  window_end        TIME,
  notes             TEXT,

  -- money, all BIGINT centimes
  product_value     BIGINT NOT NULL DEFAULT 0,
  cod_amount        BIGINT NOT NULL DEFAULT 0,
  delivery_fee      BIGINT NOT NULL DEFAULT 0,
  company_amount    BIGINT NOT NULL DEFAULT 0,
  driver_commission BIGINT NOT NULL DEFAULT 0,
  other_fees        BIGINT NOT NULL DEFAULT 0,
  collected_amount  BIGINT NOT NULL DEFAULT 0,
  payment_method    TEXT,                            -- cash|card|transfer|other
  payment_rule_version INT,                          -- pinned at creation

  attempt_count     SMALLINT NOT NULL DEFAULT 0,
  delivered_at      TIMESTAMPTZ,
  -- Cache of the most recent delivery_attempts row for this order, whatever
  -- its outcome; null means never attempted. delivery_attempts is the record.
  -- Written only by the transaction that inserts the attempt, never set on its
  -- own: a cache maintained by convention drifts, one maintained by a single
  -- write path does not. Populated on success too — a field that is only
  -- sometimes maintained is worse than one always maintained.
  last_attempt_outcome TEXT,

  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at        TIMESTAMPTZ,
  version           INT NOT NULL DEFAULT 1,
  UNIQUE (owner_id, company_id, tracking_number)
);

CREATE TABLE delivery_attempts (
  id           UUID PRIMARY KEY,
  owner_id     UUID NOT NULL REFERENCES users(id),
  order_id     UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  attempt_no   SMALLINT NOT NULL,
  -- Provisional, and a different axis from orders.status: an attempt records
  -- what happened at the door, the status records where the parcel now stands.
  -- Collapsed from eight — `absent` overlapped `no_answer` and `rescheduled`
  -- overlapped `postponed`. Additions come from observed field failures.
  outcome      TEXT NOT NULL,   -- delivered|no_answer|refused|wrong_address|
                                -- postponed|cancelled
  outcome_note TEXT,
  geo          GEOGRAPHY(POINT,4326),
  accuracy_m   INT,             -- radius reported with the fix; see §10.5
  occurred_at  TIMESTAMPTZ NOT NULL,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE proof_of_delivery (
  id            UUID PRIMARY KEY,
  owner_id      UUID NOT NULL REFERENCES users(id),
  order_id      UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  photo_path    TEXT,          -- local path in MVP; object key in V2
  signature_path TEXT,
  geo           GEOGRAPHY(POINT,4326),
  captured_at   TIMESTAMPTZ NOT NULL,
  driver_note   TEXT,
  uploaded      BOOLEAN NOT NULL DEFAULT false
);

-- ============ ROUTES ============
CREATE TABLE routes (
  id              UUID PRIMARY KEY,
  owner_id        UUID NOT NULL REFERENCES users(id),
  service_date    DATE NOT NULL,
  status          TEXT NOT NULL DEFAULT 'draft', -- draft|active|completed
  origin_geo      GEOGRAPHY(POINT,4326),
  total_distance_m INT,
  total_duration_s INT,
  optimized_at    TIMESTAMPTZ,
  started_at      TIMESTAMPTZ,
  completed_at    TIMESTAMPTZ,
  algorithm       TEXT,             -- 'dart-2opt-v1' | 'ortools-v1'
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  version         INT NOT NULL DEFAULT 1
);

CREATE TABLE route_stops (
  id             UUID PRIMARY KEY,
  route_id       UUID NOT NULL REFERENCES routes(id) ON DELETE CASCADE,
  order_id       UUID NOT NULL REFERENCES orders(id),
  sequence       SMALLINT NOT NULL,
  leg_distance_m INT,
  leg_duration_s INT,
  eta            TIMESTAMPTZ,
  arrived_at     TIMESTAMPTZ,
  departed_at    TIMESTAMPTZ,
  -- No status column, deliberately. A stop is a plan; what happened at it
  -- belongs to the order, which already holds it, and two copies of one fact
  -- drift. done = the order reached a batch-closing state; current = arrived_at
  -- set and departed_at not; pending = neither. "Skipped" is not persistent:
  -- skipping triggers re-optimization, which replaces the stops wholesale.
  is_locked      BOOLEAN NOT NULL DEFAULT false,  -- manual reorder pins it
  UNIQUE (route_id, sequence)
);

-- Cached matrix so re-optimization works offline.
CREATE TABLE matrix_cache (
  id           UUID PRIMARY KEY,
  point_hash   TEXT NOT NULL,      -- hash of the ordered coordinate set
  durations    JSONB NOT NULL,
  distances    JSONB NOT NULL,
  provider     TEXT NOT NULL,
  fetched_at   TIMESTAMPTZ NOT NULL,
  UNIQUE (point_hash, provider)
);

-- ============ LEDGER ============
CREATE TABLE expenses (
  id           UUID PRIMARY KEY,
  owner_id     UUID NOT NULL REFERENCES users(id),
  service_date DATE NOT NULL,
  category     TEXT NOT NULL,   -- fuel|parking|maintenance|food|other
  amount       BIGINT NOT NULL,
  note         TEXT,
  receipt_path TEXT,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at   TIMESTAMPTZ,
  version      INT NOT NULL DEFAULT 1
);

-- Immutable snapshot. Never updated after confirmation.
CREATE TABLE daily_settlements (
  id                 UUID PRIMARY KEY,
  owner_id           UUID NOT NULL REFERENCES users(id),
  batch_id           UUID NOT NULL REFERENCES batches(id),
  service_date       DATE NOT NULL,
  orders_total       INT NOT NULL,
  orders_delivered   INT NOT NULL,
  orders_failed      INT NOT NULL,
  orders_pending     INT NOT NULL,
  expected_collection BIGINT NOT NULL,
  actual_collection  BIGINT NOT NULL,
  company_amount     BIGINT NOT NULL,
  driver_gross       BIGINT NOT NULL,
  expenses_allocated BIGINT NOT NULL,
  driver_net         BIGINT NOT NULL,
  rule_version       INT NOT NULL,
  snapshot           JSONB NOT NULL,   -- per-order breakdown, frozen
  content_hash       TEXT NOT NULL,    -- sha256 of snapshot
  confirmed_at       TIMESTAMPTZ NOT NULL,
  UNIQUE (batch_id)
);

-- Corrections after confirmation become new rows, never edits.
CREATE TABLE settlement_adjustments (
  id             UUID PRIMARY KEY,
  settlement_id  UUID NOT NULL REFERENCES daily_settlements(id),
  amount         BIGINT NOT NULL,   -- signed
  reason         TEXT NOT NULL,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Cash physically handed to a company (versement).
CREATE TABLE remittances (
  id            UUID PRIMARY KEY,
  owner_id      UUID NOT NULL REFERENCES users(id),
  company_id    UUID NOT NULL REFERENCES companies(id),
  amount        BIGINT NOT NULL,
  method        TEXT NOT NULL,   -- cash|bank|ccp|baridimob
  reference     TEXT,
  receipt_path  TEXT,
  covers_from   DATE,
  covers_to     DATE,
  remitted_at   TIMESTAMPTZ NOT NULL,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  version       INT NOT NULL DEFAULT 1
);

-- ============ SYNC (dormant in MVP, present from day 1) ============
CREATE TABLE outbox (
  id            UUID PRIMARY KEY,       -- also the idempotency key
  entity_type   TEXT NOT NULL,
  entity_id     UUID NOT NULL,
  operation     TEXT NOT NULL,          -- create|update|delete|command
  payload       JSONB NOT NULL,
  device_id     TEXT NOT NULL,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  attempts      SMALLINT NOT NULL DEFAULT 0,
  last_error    TEXT,
  synced_at     TIMESTAMPTZ
);

CREATE TABLE audit_logs (
  id           UUID PRIMARY KEY,
  owner_id     UUID NOT NULL,
  entity_type  TEXT NOT NULL,
  entity_id    UUID NOT NULL,
  action       TEXT NOT NULL,
  before       JSONB,
  after        JSONB,
  occurred_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### 6.3 Indexes

```sql
-- Hot path: today's work
CREATE INDEX idx_orders_owner_status ON orders(owner_id, status)
  WHERE deleted_at IS NULL;
CREATE INDEX idx_orders_batch ON orders(batch_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_batches_owner_date ON batches(owner_id, service_date DESC);

-- Customer lookup by phone: the identity path, must be instant
CREATE UNIQUE INDEX idx_customers_owner_phone ON customers(owner_id, phone_e164)
  WHERE deleted_at IS NULL;
CREATE INDEX idx_customers_name_trgm ON customers USING gin (display_name gin_trgm_ops);

-- Duplicate detection on import
CREATE INDEX idx_orders_tracking ON orders(owner_id, tracking_number);

-- Geospatial: nearest customers, zone analytics
CREATE INDEX idx_addr_geo ON customer_addresses USING GIST (geo);
CREATE INDEX idx_attempts_geo ON delivery_attempts USING GIST (geo);
CREATE INDEX idx_addr_commune ON customer_addresses(commune_id);

-- Ledger
CREATE INDEX idx_expenses_owner_date ON expenses(owner_id, service_date DESC);
CREATE INDEX idx_settlements_owner_date ON daily_settlements(owner_id, service_date DESC);
CREATE INDEX idx_remit_owner_company ON remittances(owner_id, company_id, remitted_at DESC);

-- Sync
CREATE INDEX idx_outbox_pending ON outbox(created_at) WHERE synced_at IS NULL;
```

### 6.4 Order state machine

Eight states. `settled` is **not** one of them — see below.

```
                    ┌──────────┐
                    │ pending  │  in a batch, not yet on a route
                    └────┬─────┘
                         │ assign to route
                    ┌────▼─────┐
              ┌─────┤ on_route │◄──────────────┐
              │     └────┬─────┘               │
              │          │ mark arrived        │ re-attempt, same day
              │     ┌────▼─────┐               │
              │     │ arrived  │               │
              │     └──┬────┬──┘               │
     skip ────┘        │    │                  │
                  ┌────▼┐  ┌▼─────────┐        │
                  │deliv│  │  failed  ├────────┘
                  │ered │  └────┬─────┘
                  └─────┘       │ resolved at end of day
                       ▲        │
                       │   ┌────┴──────────────┬─────────────────┐
                       │   │                   │                 │
                       │ ┌─▼───────────────┐ ┌─▼──────────────┐  │
                       │ │ rescheduled     │ │ returned_to_   │  │
                       │ │ (future date,   │ │ agency         │  │
                       │ │  leaves today)  │ └────────────────┘  │
                       │ └─┬───────────────┘                     │
                       │   │ new batch, new day                  │
                       └───┴─── pending ──────────────────────┐  │
                                                              │  │
  cancelled (by merchant, any time before delivered) ─────────┴──┘
```

**Terminal states** — the order is finished forever: `delivered`,
`returned_to_agency`, `cancelled`.

**`failed` is deliberately not terminal.** It means *attempt failed, disposition
pending*. At the end of the day the driver resolves every `failed` order into
either `rescheduled` or `returned_to_agency`, and that distinction is financial
rather than cosmetic: a rescheduled parcel is still in the driver's possession
and has earned nothing yet, while a returned one triggers the retour fee in the
rule spec.

**A batch cannot be settled while any of its orders is in an open state.** The
closed states are the terminal three plus `rescheduled`; `pending`, `on_route`,
`arrived` and `failed` are open. This is a settlement precondition (§12.3) and
the reason every `failed` order must be resolved before the day closes.

**`settled` is not an order state.** Settlement is a fact about the *batch*, held
in `batches.status`. Modelling it as an order status would destroy information:
an order that is both `delivered` and inside a settled batch would lose its
delivery outcome, and with it the ability to reproduce the settlement that was
computed from it. Order immutability after settlement follows from the batch's
status, not from overwriting the order's.

**`assigned` and `optimizing` do not exist.** There is one driver in the MVP, so
assignment is meaningless; `optimizing` is a UI state with no business being
persisted.

Enforce transitions in a single pure function, `OrderStateMachine.transitionTo`
(invariant 6). Every transition writes a `delivery_attempts` row where
applicable. That function is what makes offline conflict resolution tractable
(see §11).

---

## 7. API architecture

Nothing here ships in MVP. It exists so the local repositories are shaped correctly from day one.

### 7.1 Principles

- Resource REST for CRUD, plus a small set of **commands** for state changes. `POST /orders/{id}/deliver` rather than `PATCH /orders/{id} {status: delivered}`. Commands carry intent, which is what makes offline replay safe.
- Every mutating request carries `Idempotency-Key` (the outbox row id).
- Every response carries `version`. Clients send `If-Match: <version>` on updates.
- Pagination is cursor-based on `(updated_at, id)`.

### 7.2 Surface

```
POST   /auth/otp/request                 { phone }
POST   /auth/otp/verify                  { phone, code } → tokens

GET    /sync/changes?since=<cursor>      → changed entities for this driver
POST   /sync/push                        → batch of outbox operations

GET    /companies
POST   /companies
GET    /companies/{id}/payment-rules
POST   /companies/{id}/payment-rules     → creates new version

GET    /customers?phone=&q=&cursor=
POST   /customers
POST   /customers/{id}/addresses
PATCH  /customers/{id}/addresses/{aid}/pin   { lat, lng, confidence, source }

GET    /batches?date=&company_id=
POST   /batches
POST   /batches/{id}/close
POST   /batches/{id}/settle              { expenses[], confirm: true }

GET    /orders?batch_id=&status=&cursor=
POST   /orders
POST   /orders/import                    { source, rows[] }  → drafts
POST   /orders/{id}/arrive               { geo, at }
POST   /orders/{id}/deliver              { collected, method, geo, at, pod }
POST   /orders/{id}/fail                 { reason, geo, at }
POST   /orders/{id}/reschedule           { new_date, note }

POST   /routes/optimize                  { origin, stops[], constraints } → sequence
GET    /routes/{id}

POST   /expenses
POST   /remittances

GET    /analytics/summary?from=&to=&company_id=

# V3, dispatcher scope
GET    /dispatch/drivers/live
POST   /dispatch/orders/{id}/assign
WS     /ws/dispatch                      driver.location, order.status, route.updated
```

### 7.3 Optimization endpoint contract

This is the one server call the MVP could use, though the MVP does it on-device.

```jsonc
// POST /routes/optimize
{
  "origin": { "lat": 36.75, "lng": 3.06 },
  "return_to_origin": false,
  "stops": [
    { "order_id": "…", "lat": 36.71, "lng": 3.18,
      "service_time_s": 240, "priority": 1,
      "window": { "start": "09:00", "end": "12:00" } }
  ],
  "constraints": { "start_at": "2026-08-27T07:30:00Z", "max_duration_s": 32400 },
  "provider": "auto"
}
// → 200
{
  "sequence": ["order_id_3", "order_id_1", "order_id_7"],
  "legs": [{ "distance_m": 3200, "duration_s": 420, "eta": "…" }],
  "total_distance_m": 76400,
  "total_duration_s": 10080,
  "algorithm": "dart-2opt-v1",
  "unassigned": []
}
```

Keep this contract identical between the on-device optimizer and the future OR-Tools service. That is what makes the swap a one-line change.

---

## 8. Flutter architecture

### 8.1 Layers

```
presentation/   widgets, screens, controllers (Riverpod Notifiers)
      │  depends on ↓
domain/         entities, value objects, pure use-cases, rule engine,
                optimizer, state machine.  ZERO Flutter imports.
      │  depends on ↑ (interfaces only)
data/           Drift DAOs, DTOs, mappers, RoutingProvider impls,
                OrderSource impls, outbox writer
```

The rule that matters: `domain/` imports nothing from Flutter, Drift, or HTTP. It is pure Dart. That makes the money engine, the state machine and the optimizer unit-testable at millisecond speed with no device, and it makes them portable to a Dart server later.

### 8.2 State management

**Riverpod**, not the hand-rolled `AppScope` pattern you use in BP Go. Three concrete reasons:

1. Drift emits reactive query streams. `StreamProvider` consumes them directly, so "today's orders" is a single declarative line and every widget watching it updates when the DB changes. With `ChangeNotifier` you hand-wire that invalidation.
2. `ProviderScope` overrides let you inject a fake `RoutingProvider` and a fixed clock in widget tests without any DI framework.
3. `family` + `autoDispose` matches this app's shape well (per-order controllers, per-batch summaries) and prevents the leak-prone manual disposal you get with scoped notifiers.

This is a recommendation, not a blocker. Your existing pattern works; the cost is more manual wiring in an app with far more reactive surface than BP Go.

### 8.3 Offline repository pattern

Every repository method follows the same shape:

```dart
Future<void> markDelivered(OrderId id, DeliveryPayload p) async {
  await db.transaction(() async {
    final order = await dao.getOrder(id);
    final next  = order.status.transitionTo(OrderStatus.delivered); // throws if illegal
    final money = ruleEngine.evaluate(order, p, rulePinnedAt: order.paymentRuleVersion);

    await dao.updateOrder(order.applyDelivery(p, money, next));
    await dao.insertAttempt(DeliveryAttempt.from(p));
    await dao.insertOutbox(Outbox.command('order.deliver', id, p));  // dormant in MVP
  });
}
```

Three properties fall out of this: the UI never waits on the network, the write is atomic, and the outbox row is already there when sync ships in V2. Writing outbox rows from day one costs you almost nothing and saves a full-app refactor later.

### 8.4 Folder structure

```
lib/
├── main.dart
├── app/
│   ├── app.dart                 router, theme, locale
│   ├── router.dart              go_router config
│   └── di.dart                  root providers
├── core/
│   ├── theme/                   tokens, typography, dark/light
│   ├── l10n/                    ar.arb, fr.arb, en.arb
│   ├── money/                   Centimes value type, formatters
│   ├── result/                  Result<T,E>, failures
│   ├── time/                    Clock, service-day logic
│   └── utils/
├── domain/
│   ├── entities/                Order, Batch, Customer, Company, Route…
│   ├── value_objects/           PhoneE164, Centimes, GeoPoint, Confidence
│   ├── rules/
│   │   ├── payment_rule.dart    spec model
│   │   └── rule_engine.dart     pure evaluator
│   ├── routing/
│   │   ├── optimizer.dart       RouteOptimizer interface
│   │   ├── two_opt.dart         NN + 2-opt + Or-opt
│   │   └── routing_provider.dart  matrix interface
│   ├── state/
│   │   └── order_state_machine.dart
│   └── usecases/
├── data/
│   ├── db/
│   │   ├── database.dart        Drift @DriftDatabase
│   │   ├── tables/
│   │   ├── daos/
│   │   └── migrations/
│   ├── routing/
│   │   ├── mapbox_routing_provider.dart
│   │   └── osrm_routing_provider.dart
│   ├── ingestion/
│   │   ├── barcode_source.dart
│   │   ├── paste_parser_source.dart
│   │   └── ocr_source.dart
│   ├── sync/                    outbox writer, (V2) sync engine
│   └── repositories/            concrete impls of domain interfaces
├── features/
│   ├── home/                    dashboard
│   ├── batches/
│   ├── orders/
│   ├── ingestion/
│   ├── customers/
│   ├── companies/
│   ├── route/
│   ├── delivery/                next-stop flow, POD
│   ├── money/                   settlement, expenses, remittance
│   ├── history/
│   ├── analytics/
│   └── settings/
└── shared/
    └── widgets/                 design system components

test/
├── domain/                      pure, fast, the majority
├── data/                        DAO tests on in-memory SQLite
└── widget/

integration_test/               on-device scenarios (§16). NOT test/integration/:
                                the integration_test package only discovers
                                tests in this directory at the repo root.

assets/
├── geo/wilayas.json             all wilayas (69 as of Nov 2025; never hardcode the count)
└── geo/communes.json            ~1541 communes
```

Each `features/<x>/` folder holds `presentation/` (screens, widgets) and `controllers/`. Domain and data stay centralized so the layering rule is visible in the tree.

---

## 9. Backend architecture (V2)

When sync arrives, the shape is:

**Supabase as the platform.** Postgres 15 with PostGIS, Auth (phone OTP, which is the right method for Algerian drivers), Storage for POD photos behind signed URLs, Realtime for V3 dispatcher, and Row Level Security as the multi-tenancy enforcement point.

**Edge Functions (Deno/TypeScript)** for the logic that must not run on the client: settlement verification, rule evaluation cross-check, import de-duplication, and webhook handling.

**One separate optimizer service** (Python + FastAPI + OR-Tools) deployed as a container. Stateless, no database access, takes the §7.3 contract and returns a sequence. Deployed on Fly.io or a small VPS. Kept separate because OR-Tools is a heavy native dependency that has no business inside your API process, and because it lets you scale or replace it independently.

If you later outgrow Supabase, the NestJS modular structure you proposed (Auth, Drivers, Companies, Customers, Orders, Batches, Routes, Optimization, Deliveries, Payments, Earnings, Expenses, Notifications, Tracking, Analytics) is the correct decomposition. Migrating is realistic because the Postgres schema is already yours.

**Background jobs (V2+):** Redis + BullMQ as you proposed, or Supabase's `pg_cron` + queue table if you stay on Supabase. Jobs: matrix pre-fetch, POD photo upload retry, analytics rollups, settlement reminders. The rule from your spec stands: never block an HTTP request on an optimization run.

---

## 10. Route optimization architecture

### 10.1 Pipeline

```
1. SELECT stops
   orders where status ∈ {pending, on_route} AND delivery_type = 'home'
   AND geo_confidence >= 1

2. RESOLVE coordinates
   confidence 4 (GPS-confirmed) → use directly
   confidence 3 (driver pin)    → use directly
   confidence 2 (geocoded)      → use, flag as approximate
   confidence 1 (centroid)      → cluster into a "zone stop", warn driver
   confidence 0                 → exclude, surface in "needs location" list

3. FETCH matrix
   key = sha256(sorted coordinate list, rounded to 5 decimals)
   hit  → matrix_cache
   miss → Mapbox Matrix (≤25 coords per request)
   >25 stops → geographic clustering (k-means on coordinates), solve
               per-cluster, then order clusters by centroid

4. SOLVE
   nearest-neighbour construction from origin
   → 2-opt improvement until no gain
   → Or-opt (relocate segments of 1–3 stops)
   → apply hard pins (driver-locked stops keep their index)
   → apply priority as a cost penalty, not a hard constraint

5. PERSIST
   routes + route_stops with computed ETAs
   (start_time + cumulative leg durations + service_time per stop)

6. RE-OPTIMIZE triggers
   delivery failed / stop skipped / new order added / driver >20 min behind ETA
   → re-solve remaining stops only, reusing the cached matrix (offline-capable)
```

### 10.2 Why 2-opt is enough for MVP

For a symmetric TSP with n ≤ 25, nearest-neighbour typically lands 20–25% above optimal, and 2-opt plus Or-opt pulls that down to roughly 2–5%. On a 76 km day that is a difference of a few kilometres against the theoretical best, which is far smaller than the error introduced by imprecise Algerian coordinates. Spending weeks on an exact solver optimizes the wrong term.

### 10.3 Provider abstraction

```dart
abstract interface class RoutingProvider {
  Future<TravelMatrix> matrix(List<GeoPoint> points, {bool withTraffic = false});
  Future<RouteGeometry> geometry(List<GeoPoint> ordered);
}

abstract interface class RouteOptimizer {
  Future<OptimizationResult> solve(OptimizationRequest request);
}
```

Implementations: `MapboxRoutingProvider`, `OsrmRoutingProvider`, `HaversineFallbackProvider` (offline, straight-line with a 1.35 detour factor — imprecise but never fails). Optimizers: `TwoOptOptimizer` (MVP), `OrToolsOptimizer` (V2, HTTP client to the service).

The `HaversineFallbackProvider` matters more than it sounds. It guarantees the driver always gets *some* route even with no internet and no cached matrix. Degraded is better than broken.

### 10.4 Traffic

Mapbox's traffic-aware profile caps at 10 coordinates, so you cannot get a traffic-aware 20×20 matrix in one call. Practical approach: use the plain `driving` profile for the matrix and sequencing, then request a traffic-aware leg only for the current leg to the next stop, which is the only ETA the driver actually acts on. This is cheap and gives 90% of the perceived benefit.

---

### 10.5 Pin accuracy, and not poisoning the learned-pin database

`customer_addresses.accuracy_m` and `delivery_attempts.accuracy_m` hold the
radius the platform reports alongside a GPS fix.

The learned-pin geocoder (§1.3, §20.1) is the single most valuable asset this
product builds, and it compounds: every delivery improves it. That also means
every bad pin written into it degrades every future route through that
neighbourhood, and nothing in the app will ever tell you it happened.

A fix taken indoors, in a stairwell, or in a dense-block courtyard can come back
with a 300-metre radius. Promoting that to confidence 4 and routing future
deliveries from it is how the asset gets poisoned. So:

- capture `accuracy_m` with every fix, at the moment of capture — it is not
  recoverable later
- a fix worse than the threshold is stored but **not** promoted to confidence 4
- the threshold is an M2 decision, set after looking at real fixes in Algiers,
  not guessed at now

The column has to exist before M2 can make that decision, which is why it is in
the schema from v1.

**Promotion ladder.** A captured fix reaches confidence 4 only by clearing three
gates, each catching something the one before it cannot:

1. **Inside the Algeria rectangle.** Catches a transposed latitude and
   longitude, a zeroed fix, a European address. `GeoPoint.isPlausiblyAlgerian`.
   Weak by construction — the rectangle also contains Casablanca and Tunis.
2. **Inside or near the order's declared commune.** Catches a *real* GPS fix
   taken in the wrong place, which gate 1 cannot see at all. This is the sharp
   one: a driver two streets away is still comfortably inside the country.
3. **`accuracy_m` under threshold.** Catches an indoor fix with a 300-metre
   radius, which can be in the right commune and still useless.

All three thresholds are M2 decisions, set against real fixes in Algiers.

**Gate 2 constrains the geography dataset, and that decision lands earlier.**
Point-in-polygon against the commune boundary is the correct test; a fixed
radius from a centroid is not. An Algiers commune is a few square kilometres and
a Saharan one can be thousands, so no single radius serves both, and the
centroid of a large desert commune can be tens of kilometres from every address
in it.

So prefer a commune dataset carrying **boundary polygons**, not just names and
centroids. If only centroids are available, gate 2 degrades to a wilaya-scaled
radius — weaker, but weakest in the sparse southern wilayas where it matters
least. The M0 loader treats a boundary field as **optional**: present, it is
stored; absent, the dataset still loads and the gate degrades. Nothing in M0
blocks on it.

`GeoPoint` in `domain/` stays pure latitude and longitude. Accuracy is a property
of a *measurement*, not of a coordinate, and putting it on the value object would
contaminate every use site — route stops, commune centroids and map taps have no
accuracy radius.

---

## 11. Offline synchronization strategy

### 11.1 Model

The device is authoritative for anything the driver did. The server is authoritative for anything a company or dispatcher did. This split resolves most conflicts before they happen.

### 11.2 Mechanism

**Outbox with commands, not state diffs.** Recording `order.deliver { collected: 640000, at: T }` replays correctly regardless of what else changed. Recording `{ status: 'delivered' }` does not.

```
Local write ──► entity table + outbox row (same transaction)
                       │
             connectivity restored
                       │
              POST /sync/push  (batched, ordered by created_at)
              Idempotency-Key = outbox.id
                       │
              server applies each command idempotently
              (dedupe table on idempotency key, 30-day retention)
                       │
              GET /sync/changes?since=<cursor>
                       │
              merge server changes into local
```

### 11.3 Conflict rules

| Conflict | Resolution |
|---|---|
| Same order delivered on two devices | Idempotency key dedupes; first wins, second returns the same result |
| Local `delivered`, server `cancelled_by_merchant` | **Server wins** on cancellation, but the local delivery is preserved as a `settlement_adjustment` and surfaced to the driver. Never silently discard collected money. |
| Local edit vs server edit on the same field | Illegal-transition check first via the state machine; if both legal, last-writer-wins by `occurred_at`, with the loser written to `audit_logs` |
| Customer pin updated on two devices | Highest `geo_confidence` wins; ties broken by most recent |
| Settlement confirmed locally, server has different totals | Server recomputes from orders; if the hash differs, flag for driver review. Never auto-overwrite a confirmed settlement. |

### 11.4 What does not sync

POD photos sync separately and lazily, on Wi-Fi by default, compressed to roughly 1200px / 200 KB. They are large, they are not needed for correctness, and uploading them over a metered Algerian mobile connection during a shift is hostile to the user.

### 11.5 MVP obligation

In MVP the sync engine does not exist. What must exist:

- UUIDv7 primary keys everywhere
- `updated_at`, `deleted_at`, `version` on every table
- outbox rows written on every mutation (never sent, just accumulated and trimmed)
- the state machine as a pure function
- a `device_id` persisted at first launch

That is roughly one day of work now and it saves a rewrite later.

---

## 12. Money engine and payment rules

This is the part of the product that must never be wrong, and the part with the most commercial value.

### 12.1 Rule specification

A declarative, versioned JSON document evaluated by a pure function. No scripting, no `eval`, no arbitrary expressions.

```jsonc
{
  "version": 3,
  "currency": "DZD",
  "delivered": {
    "driver_commission": {
      "type": "tiered_by_wilaya",
      "default": { "type": "fixed", "amount": 30000 },   // 300.00 DA
      "tiers": [
        { "wilaya_in": [16], "value": { "type": "fixed", "amount": 25000 } },
        { "wilaya_in": [42, 9], "value": { "type": "fixed", "amount": 40000 } }
      ]
    },
    "company_amount": {
      "type": "expression",
      "formula": "cod_amount - driver_commission"
    }
  },
  "failed": {
    "driver_commission": { "type": "fixed", "amount": 10000 },  // retour fee
    "company_amount":    { "type": "fixed", "amount": 0 }
  },
  "stopdesk": {
    "driver_commission": { "type": "fixed", "amount": 0 }
  },
  "bonuses": [
    { "when": "daily_delivered >= 20", "amount": 50000 }
  ]
}
```

Supported value types: `fixed`, `percent_of` (with a named base), `tiered_by_wilaya`, `tiered_by_count`, `expression` (restricted to `+ - * /` over a fixed set of named variables). That covers every Algerian commission structure I am aware of and stays statically analysable.

### 12.2 Evaluation guarantees

- Pure function: `(Order, PaymentRuleSpec, DeliveryContext) → MoneyBreakdown`
- Integer arithmetic only, in centimes; rounding is banker's rounding, applied once, at the final step
- Deterministic: same inputs always produce the same output, on device and on server
- `payment_rule_version` is stamped on the order at creation. Editing a company's rule creates version N+1 and never touches historical orders.

**One rounded value per order.** "Applied once, at the final step" is not
precise enough on its own, so state it as a hard rule: an evaluation produces
**at most one rounded monetary value per order**, and every other component is
derived from it by subtraction from `cod_amount`.

```
driver_commission = round(<rule expression>)          // the only rounding
company_amount    = cod_amount − driver_commission − other_fees
```

Rounding `driver_commission` and `company_amount` independently is how
`Σ company_amount + Σ driver_commission == Σ collected_amount` silently stops
holding: two half-centime roundings in the same direction, forty orders, and the
day is off by 20 centimes with no single order visibly wrong. Deriving the
residual by subtraction makes the sum exact by construction, not by luck.

Where a company's rule is naturally expressed the other way around — a fixed
company amount with the driver taking the remainder — the rule spec **designates
which field is computed and which is the residual**. It is a property of the
spec, not a convention in the evaluator. The evaluator reads it and never
guesses.

This is invariant 1 in `CONTRIBUTING.md`, and the property tests in §16 are what keep
it honest.

### 12.3 Settlement integrity

```
1. Driver reviews the day
2. App computes the breakdown for every order in the batch
3. Snapshot = { per-order breakdown, totals, rule_version, expense allocation }
4. content_hash = sha256(canonical_json(snapshot))
5. Row inserted into daily_settlements; batch.status = 'settled'
6. Orders in the batch become read-only
7. Any later correction inserts a settlement_adjustment. Never an UPDATE.
```

### 12.4 Cash position

```
cash_on_hand(company, as_of) =
    Σ collected_amount (delivered orders for that company, up to as_of)
  − Σ remittances.amount (to that company, up to as_of)
```

Surface this prominently. A driver holding 400,000 DA wants to see that number without doing arithmetic, and reconciling it against the agency's figure is the moment the app proves its worth.

---

## 13. Security model

| Concern | MVP | V2+ |
|---|---|---|
| App access | Device PIN / biometric lock (money data on a phone that gets left in a café) | Same, plus phone OTP account |
| Data at rest | SQLCipher-encrypted Drift database; key in platform keystore | Same |
| Customer PII | Never leaves the device | RLS scoped to `owner_id`; company sees only its own orders |
| POD photos | App-private storage, not the gallery, not `MediaStore` | Object storage, private bucket, short-lived signed URLs |
| Transport | TLS + certificate pinning on the matrix call | TLS + pinning throughout |
| Location | Foreground only, permission requested at first route start with a plain explanation | Same; background only if V3 tracking ships, with explicit opt-in |
| Authorization | N/A (single user) | RBAC: `driver`, `dispatcher`, `company_admin`, `platform_admin` |
| Input validation | Value objects reject invalid state at construction (`PhoneE164`, `Centimes`) | Same + server-side schema validation |
| Rate limiting | Client-side throttle on matrix calls | Per-user limits at the edge |
| Audit | `audit_logs` on all money and status mutations | Same, server-side, immutable |
| Secrets | Mapbox token via `--dart-define`, restricted by bundle id, never in the repo | Server-side proxy so no token ships in the app |

One point deserves emphasis: **customer phone numbers and home coordinates are the most sensitive data in this system.** A leaked database is a list of Algerian households, their addresses, and when they receive valuable cash-on-delivery parcels. Encrypt the local DB from day one and never sync more customer data to a company than the orders that company itself created.

---

## 14. Multi-tenancy

The cheap-now, impossible-later decisions:

1. `owner_id` on every row, even in MVP SQLite where nothing enforces it. This column becomes the RLS predicate later.
2. `company_id` on every order-scoped row. A company must never be able to read another company's orders even though they share a driver.
3. UUID keys. Sequential integers leak volume and make cross-tenant merges impossible.
4. No global uniqueness assumptions. Tracking numbers are unique per `(owner, company)`, not globally.
5. Settlement snapshots are per-batch and therefore per-company by construction.

The RLS policies write themselves once you are on Postgres:

```sql
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

CREATE POLICY driver_own_orders ON orders
  FOR ALL USING (owner_id = auth.uid());

CREATE POLICY company_scoped_orders ON orders
  FOR SELECT USING (
    company_id IN (
      SELECT company_id FROM company_members WHERE user_id = auth.uid()
    )
  );
```

---

## 15. Development milestones

Assumes roughly 15–20 hours per week alongside your L3 coursework.

| M | Weeks | Deliverable | Gate |
|---|---|---|---|
| **M0** | 1–2 | Project skeleton, theme + design tokens, AR/FR/RTL, go_router, Drift schema v1, wilaya/commune assets, `Centimes` + `PhoneE164` value objects, CI running analyze + test | App builds, switches AR↔FR with correct RTL, empty DB opens encrypted |
| **M1** | 2–3 | Ingestion + customers: barcode scan, fast entry form, phone normalization, duplicate detection, customer profile, addresses with commune picker | 15 orders entered in under 4 minutes, measured with a stopwatch |
| **M2** | 3–5 | Batches, order list, state machine, next-stop card, call/WhatsApp/navigate deep links, delivered/failed/reschedule flows, photo POD, attempt history | Full day simulated end to end, offline, airplane mode on |
| **M3** | 5–6 | Money engine: rule spec + evaluator, per-order breakdown, expenses, settlement snapshot with hash, remittance, cash on hand | Property tests pass; totals match a hand-computed spreadsheet to the centime |
| **M4** | 6–8 | Map + optimization: Mapbox tiles, matrix fetch + cache, NN/2-opt/Or-opt, route screen, drag reorder with pinning, ETAs, re-optimize on failure, Haversine fallback | 20-stop route solves in under 100 ms; works with the network off using the cached matrix |
| **M5** | 8–10 | Home dashboard, history with drill-down, settings, backup/restore, empty and error states, performance pass, signed release APK | Cold start under 1.5 s on a mid-range Android; a full day's data survives reinstall via backup |
| **Field** | 10–12 | Two or three real drivers use it daily. You ride along at least one full shift. | Nothing else matters until this happens |
| **V1.5** | 13–18 | Paste/OCR import, end-of-day PDF for WhatsApp, analytics, CSV export, fixes from field testing | |
| **V2** | 19+ | Supabase backend, sync engine, OR-Tools service, push | Gated on 20+ daily users |

**The Field milestone is the most important row in this table.** Ten weeks of building followed by one ride-along will teach you more than another ten weeks of building.

---

## 16. Testing strategy

| Layer | Tool | Coverage target | What is tested |
|---|---|---|---|
| Domain (pure) | `test` | **90%+, non-negotiable** | Rule engine, state machine, optimizer, `Centimes` arithmetic, settlement hashing |
| Property tests | `glados` or hand-rolled generators | Money invariants | `Σ company_amount + Σ driver_commission == Σ collected` for any generated batch; no rule spec ever produces a negative commission; optimizer output is always a valid permutation containing every input stop exactly once |
| Golden tests | `drift` in-memory + fixtures | Migrations | Every schema migration runs forward against a seeded DB from the previous version |
| Data | `drift/native` in-memory SQLite | 70% | DAO queries, transaction atomicity, outbox writes |
| Widget | `flutter_test` | Key flows | Next-stop card, delivery sheet, settlement confirmation |
| Integration | `integration_test` | 5 scenarios | Full offline day; import → route → deliver → settle; failure → re-optimize; reschedule across days; backup → wipe → restore |
| Encryption | `drift/native` on a temp file | Every path | The file has no `SQLite format 3` header; a wrong key throws rather than returning an empty database; an existing database is never re-keyed |
| Manual | Checklist | Every release | Airplane-mode day, low battery, Arabic RTL screenshots of every screen, a device with 2 GB RAM |

**Encryption is verified in CI, not only on a device.** This was not true when
§13 was written and is worth stating plainly, because the old assumption would
otherwise justify skipping the tests that matter most here: `package:sqlite3`
bundles the SQLCipher build on every platform including the Dart test host, so a
test can write a real encrypted file, read its raw bytes, and prove a wrong key
is rejected.

The only device-only part is the **keystore** itself. What the host cannot check
is whether Android actually persisted the key — so that layer is kept behind
`DatabaseKeyStore`, and every rule about *when* a key may be created is tested
against a fake. The plugin's own options are pinned by a test too, after
`flutter_secure_storage` 11 flipped `resetOnError` to `true`.

The property tests on the money engine matter most. A subtle rounding bug in a commission formula surfaces as a 3 DA discrepancy after 40 orders, and that is exactly the kind of error that destroys a driver's trust permanently.

---

## 17. Deployment architecture

**MVP.** No infrastructure. GitHub Actions runs `flutter analyze`, `flutter test`, and builds a signed APK on tag. Distribution via direct APK and Google Play internal testing. Reuse the signing pipeline you already built for BP Go. Sentry (or Firebase Crashlytics) for crash reporting, with PII scrubbing so no phone numbers or coordinates reach the crash payload.

**V1.5.** Play Store closed testing track. Staged rollout at 20%.

**V2.** Supabase project with separate `dev` and `prod` instances, migrations versioned in the repo and applied via CI. Optimizer service as a container on Fly.io or a small VPS, health-checked, stateless, autoscale to zero. Daily automated Postgres backups with a tested restore procedure. Feature flags via a remote config table so you can disable the sync engine remotely if it misbehaves in the field.

**V3.** Next.js dispatcher on Vercel. If costs demand it, self-hosted OSRM on a VPS with a monthly cron re-importing the Geofabrik Algeria extract.

---

## 18. Complexity estimates

| Module | Complexity | Est. effort | Risk |
|---|---|---|---|
| Theme, design system, RTL/i18n | Medium | 5 d | Low |
| Drift schema + migrations | Medium | 4 d | Medium (get it right early) |
| Ingestion (scan + form) | Medium | 6 d | **High** (UX must be fast) |
| Ingestion (paste/OCR) | High | 8 d | High (parsing is messy) |
| Customer DB + learned pins | Medium | 5 d | Medium |
| Companies + rule editor UI | High | 7 d | Medium |
| **Payment rule engine** | **High** | **8 d** | **Highest — correctness critical** |
| Order state machine + delivery flow | Medium | 7 d | Medium |
| Proof of delivery (photo) | Low | 2 d | Low |
| Map rendering + markers | Medium | 5 d | Medium |
| Matrix fetch + cache | Medium | 3 d | Low |
| **Optimizer (2-opt/Or-opt)** | **High** | **6 d** | Medium |
| Route screen + manual reorder | Medium | 5 d | Low |
| Settlement + ledger | High | 7 d | **High — correctness critical** |
| Expenses + remittance + cash | Medium | 4 d | Medium |
| History + drill-down | Low | 3 d | Low |
| Analytics + charts | Medium | 5 d | Low |
| Backup / restore | Medium | 3 d | Medium |
| **Sync engine (V2)** | **Very high** | **20 d** | **Highest** |
| Supabase backend + RLS | High | 10 d | Medium |
| OR-Tools service | High | 8 d | Medium |
| Dispatcher web app | Very high | 30 d+ | High |
| Live tracking | High | 12 d | High |

MVP total lands around 70–80 focused days, which matches 8–10 weeks part-time.

---

## 19. Risks and technical challenges

| # | Risk | Impact | Mitigation |
|---|---|---|---|
| 1 | **Order entry is too slow, driver abandons the app** | Fatal | Barcode-first. Measure entry time as a hard gate at M1. If 15 orders takes more than 4 minutes, stop and fix it before continuing. |
| 2 | **Coordinates are wrong, routes are nonsense** | Fatal | Confidence-tiered coordinates; learned pins from actual delivery GPS; never route a confidence-0 stop; show the driver which stops are approximate. |
| 3 | Money is off by a few dinars | Fatal to trust | Integer centimes, property tests, immutable settlements, rule version pinning. |
| 4 | Battery dies before the shift ends | Severe | No background location. Throttle GPS to 1 fix per 30 s while routing. Batch DB writes. Test on a 3-year-old device at 30% brightness. |
| 5 | Mapbox costs escalate with users | Medium | Cache matrices aggressively; keyed by rounded coordinates so re-optimizations are free. OSRM escape hatch behind the provider interface. |
| 6 | Scope creep into the dispatcher/AI features | High (project death) | Hard gate: no V3 work until a company pays for a pilot. |
| 7 | Sync engine bugs corrupt financial data | Severe | Commands not state diffs; idempotency keys; settlements immutable; server never overwrites a confirmed settlement. Ship sync only after MVP is stable. |
| 8 | Drift migration breaks a driver's live data | Severe | Every migration has a forward test from the prior schema; automatic pre-migration DB backup; never destructive in a single release. |
| 9 | Android OEM battery managers kill the app mid-shift | Medium | Foreground-only design avoids most of it; add a "keep screen on while routing" option; document per-OEM whitelisting in settings. |
| 10 | RTL layout breaks on 40 screens after the fact | Medium | Localize and mirror from screen one; RTL screenshot in the release checklist. |
| 11 | Companies change commission rules mid-month | Medium | Rule versioning with `effective_from`; historical orders keep their pinned version. |
| 12 | You burn out building alone while studying | Real | The milestone table is deliberately conservative. Ship M1–M3 and get it in a driver's hands before building the map. |

---

## 20. What would make this genuinely impressive

Ranked by how much they differentiate against everything else in this market.

1. **The learned-pin geocoder.** Every delivery permanently improves the map. After 300 deliveries the app knows where people actually live in a way no commercial geocoder does for Algeria. This is a compounding data asset, it is defensible, and it directly solves the problem that makes every generic route planner useless here.

2. **Sub-4-second order entry.** Scan, confirm, next. If a driver can process his morning manifest faster in your app than by reading the paper, you have won. Nothing else in the product matters as much.

3. **Money that reconciles to the dinar.** Cash on hand, per-company balances, remittance tracking, and an end-of-day summary he can send to the agency on WhatsApp as a PDF. Drivers currently do this in a notebook and argue about it. Being provably right is the feature.

4. **Genuinely usable with zero internet all day.** Not "degraded offline mode". The full workflow: route, deliver, collect, settle, all offline, with the cached matrix. Everything syncs later. Most competitors fail the moment signal drops.

5. **Returns handled as first-class.** Retours are 15–25% of volume and every generic app treats them as an error state. Multi-attempt tracking, reschedule flows, and correct retour compensation make the app match reality.

6. **Arabic done properly.** Real RTL, Darija-appropriate wording, Arabic numerals where the user expects them. Most local apps are French-only or have broken RTL. This alone reads as a serious product.

7. **A phone that survives the shift.** Publish your own battery number ("under 12% for a 10-hour day") and defend it in every release. Drivers notice.

8. **Restraint in the UI.** You already specified this well. High information density, real maps, clear status, no decoration. One more rule: **the next action is always the largest thing on screen.** The driver is holding a parcel in one hand.

---

## 21. Step-by-step implementation plan

### Before writing any application code

1. Ride along with a real driver for one full day. Photograph the manifest, time how long each stop takes, watch how he records money, note every time he uses his phone. This is one day and it will change three or four of the decisions in this document.
2. Collect two or three real manifests from different companies. They define your import parser.
3. Write down the exact commission formulas for two companies. They validate the rule spec in §12.
4. Decide the currency unit and never revisit it. Recommendation: `BIGINT` centimes.

### Week 1–2 (M0)

5. `flutter create`, set up the folder structure from §8.4.
6. Design tokens, typography scale, dark and light themes, spacing system.
7. Localization: `ar` + `fr` from the first screen. Build one screen in both and verify RTL mirroring.
8. Drift schema v1 mirroring §6.2. Enable SQLCipher. Write the migration test harness now, before there is anything to migrate.
9. Bundle `wilayas.json` and `communes.json`.
10. Value objects: `Centimes`, `PhoneE164`, `GeoPoint`, `Confidence`. Unit-test them.
11. GitHub Actions: analyze, test, build.

### Week 2–3 (M1)

**M1-00 — wire startup. This goes first, before any feature work.**

M0 built the bootstrap and the locale reconciliation and left them behind a
provider that nothing calls. That was deliberate: the missing piece is a
*screen*, and the screen needs copy, localized strings, a retry affordance and a
destructive-confirm flow — four UI decisions that belong with M1's real screens
rather than invented at the end of a foundations milestone.

What M1-00 owes:

- open the encrypted database at startup, after the first frame, so the UI
  exists before an open that can fail
- run `AppBootstrap.ensureUser`, then `LocaleController.reconcile`
- override `userSettingsProvider` once the database is up, so language changes
  reach the source of truth instead of preferences alone
- render the unreadable-database screen on `DatabaseUnreadableException` and
  `DatabaseKeyMissingError` — in a language the driver reads, which is the
  entire reason the preferences cache exists
- offer the destructive reset (delete the database, regenerate the key) behind
  an explicit confirmation, and never automatically

Until this lands, bootstrap never runs on a real device. It is named here so it
cannot fall between milestones.

12. Barcode scanner screen. Scan → order draft → confirm.
13. Order entry form, phone field first, live customer lookup by normalized phone.
14. Duplicate handling: show the existing customer with order count, one tap to reuse.
15. Customer profile: addresses, history, call and WhatsApp actions.
16. Commune picker with search.
17. **Gate:** stopwatch test of 15 orders. Fix until it is under 4 minutes.

**Two things settled in M0 that constrain this milestone.**

**A phone that fails to parse must not block order creation.** A driver standing
in an agency at 07:00 cannot be stopped from entering an order because our
validator disagrees with reality. The entry flow offers *save and fix later*:
the raw string is retained verbatim, the order is created, and the customer
record is flagged for correction. `PhoneE164` is the identity key when it
parses — it is not a gate on the driver's morning.

This matters most for landlines. `PhoneE164.nationalLength` assumes nine
significant digits for both mobiles and landlines; Algeria closed its numbering
plan in 2008 and older landline formats were shorter. Verify against a real
manifest before hardening ingestion, and until then let unparseable numbers
through rather than rejecting a real customer.

**Customers merge; they do not restore.** The unique index on
`(owner_id, phone_e164)` is partial — `WHERE deleted_at IS NULL` — so a
soft-deleted customer does not block re-adding the same number, which is what a
driver will do. The consequence is that restoring the old record could collide
with the new one, so restore is simply not offered: the newer record wins and
the older stays deleted.

The real need is a **merge** flow, and it is a genuine M1 feature rather than a
workaround. Two records for one human happens for ordinary reasons — a number
entered before normalization improved, the same customer arriving through two
companies. Merge moves orders and addresses onto the surviving record, unions
the learned pins keeping the highest confidence for each address, and
soft-deletes the loser. Losing a confidence-4 pin to a merge would waste exactly
the evidence §10.5 exists to protect.

**"Parses as a phone" is not a classifier.** `PhoneE164` accepts a bare
nine-digit national number, so a nine-digit tracking number beginning with 5, 6
or 7 parses cleanly as a mobile. The paste and OCR parsers (V1.5) must classify
by field position, column header and surrounding context — never by asking the
value object whether a token happens to be valid. The value object answers "is
this a well-formed Algerian number", which is a different question from "is this
field a phone number".

### Week 3–5 (M2)

18. `OrderStateMachine` as a pure function with exhaustive transition tests.
19. Batch creation and the batch list.
20. Next-stop card with call, WhatsApp, and navigate deep links.
21. Delivered / failed / rescheduled flows writing `delivery_attempts`.
22. Photo POD: capture, compress, store app-private, record GPS and timestamp.
23. **Pin capture on delivery.** At the moment of marking delivered, read the device GPS and write it to `customer_addresses` at confidence 4. This one step builds the whole geocoding asset.
24. **Gate:** simulate a full day in airplane mode.

### Week 5–6 (M3)

25. Payment rule spec model and JSON serialization.
26. `RuleEngine.evaluate()`, pure, integer-only.
27. Rule editor UI for the two real formulas you collected in step 3.
28. Expense entry.
29. Settlement screen: review, confirm, snapshot, hash, freeze.
30. Remittance entry and cash-on-hand calculation.
31. **Gate:** property tests plus a manual reconciliation against a spreadsheet.

### Week 6–8 (M4)

32. `RoutingProvider` interface, Mapbox implementation, Haversine fallback.
33. Matrix cache keyed by rounded coordinate hash.
34. `TwoOptOptimizer`: NN construction, 2-opt, Or-opt, pin support, priority penalty.
35. Map screen with stop markers colour-coded by confidence and status.
36. Route screen: ordered list, ETAs, drag to reorder, locked stops.
37. Re-optimization triggers on failure, skip, and new order.
38. **Gate:** 20 stops solve in under 100 ms; re-optimize works offline from cache.

### Week 8–10 (M5)

**Release APKs are split per ABI, and x86_64 does not ship.** SQLCipher adds
about 5 MB of native library per architecture, so a fat APK carries roughly
15 MB that no single device can use. A driver often receives this app as an APK
shared over WhatsApp or Telegram rather than from Play, so an App Bundle alone
does not solve it — the artifact handed around has to be small by itself.

- `arm64-v8a` — the primary, and what almost every device since 2017 runs
- `armeabi-v7a` — older hardware, which this market still has plenty of
- `x86_64` — emulator only. Not shipped.


39. Home dashboard assembling batch progress, next stop, money, and route summary.
40. History list and day drill-down.
41. Settings, backup and restore, about.
42. Empty states, error states, loading skeletons.
43. Performance pass: cold start, list scrolling, DB query profiling.
44. Signed release build, Crashlytics with PII scrubbing.

### Week 10–12 (Field)

45. Put it in two or three drivers' hands. Ride along again.
46. Instrument: time per order entry, optimize invocations per day, offline duration, crash-free rate.
47. Fix what they actually complain about, not what you assumed.

Only after that does V1.5 begin, and V2 only when there are enough daily users to justify a server.

---

## Appendix A — Open questions for you

1. Do the companies you know pay a fixed amount per delivered parcel, a percentage of COD, or a per-wilaya tariff? The answer determines how much of §12 you actually need in MVP.
2. Do drivers settle daily or hold cash for several days? This changes how prominent the remittance flow is.
3. What proportion of parcels are stop-desk versus home delivery in your target drivers' batches?
4. Does the driver receive the manifest on paper, in the company's own app, or on WhatsApp? This picks which ingestion method you build first.
5. Do you want the app usable by a driver with no account at all in MVP, or a phone-OTP account from day one? I recommend no account, because it removes every signup barrier and every backend dependency.
