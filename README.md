# ticketmaster-data-collection
# Ticketmaster Music Events – Daily Snapshot

This repo snapshots **Ticketmaster _Music_ events** for the next 90 days, every day.
Each run appends to `data/events_history.parquet` and preserves a `snapshot_date`
so you can analyze how listings evolve over time.

## What gets collected?
- Event metadata: `id`, `name`, `url`, `date`, `time`, `status`
- Venue & location: `venue`, `city`, `state`, `country`, `venue_lat`, `venue_lon`
- Artist/attraction: `artist`, `artist_id`
- Classification: `segment`, `genre`, `subgenre`, `family`
- Price range (if present): `min_price`, `max_price`, `currency`
- `snapshot_date`: UTC date the snapshot was taken

> Scope: public Discovery API, filtered by `classificationName=Music`,
> month-by-month across the next 90 days.

---

## Quickstart (local)

1. Create a virtual env and install deps:
   ```bash
   python -m venv .venv && source .venv/bin/activate
   pip install -r requirements.txt
