# Ticketmaster Event Data Pipeline
This project is an end-to-end data engineering pipeline that collects real-time event data from the Ticketmaster API, processes and stores it in a database for long-term access, and enables downstream exploratory data analysis (EDA) to uncover key insights.

## Overview
- Read data from the Ticketmaster API
- Normalize and structure the data into relational tables
- Load and persist the data in a SQL database
- Orchestrate extraction → transform → load using a pipeline script
- Perform EDA to derive insights from a prepared dataset

## Structure
```
.
├── ticketmaster_snapshot.py      # Extract: API → Parquet (daily snapshots)
├── src/
│   ├── Transform.py              # Normalize raw event data → CSVs
│   ├── db/Load.py                # Load normalized tables into SQLite
│   └── main.py                   # End-to-end transform + load pipeline
├── data/
│   └── events_history.parquet    # Daily snapshots (auto-generated)
├── .github/workflows/
│   └── tm_snapshot.yml           # Optional automated snapshot workflow
└── requirements.txt

```


## Ticketmaster Music Events – Daily Snapshot

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


## Usage

### 1. Extract Raw Ticketmaster Data
This pipeline uses the Ticketmaster Discovery API: https://app.ticketmaster.com/discovery/v2/events.json. See the official docs for request parameters and authentication.

Ticketmaster's API has strict rate limits and only returns a rolling ~90-day window of future events. It provides no historical data or versioning. Pulling data daily preserves changing event details, stays within API limits, and builds the dataset required for downstream analytics.

#### Run Extractor Locally
**Install dependencies**
```bash
pip install -r requirements.txt
```

**Set Environment Variables**

Create a `.env` file at root and set the following variables.
```bash
TICKETMASTER_API_KEY="YOUR_REAL_KEY"
```

**Run the Extract Script**
```bash
python ticketmaster_snapshot.py
```
This will fetch the latest 90-day “Music” events and append them to ```data/events_history.parquet```.


#### Automated Extractor via Github Actions
1. Fork/clone this repo into your own GitHub account
2. Add your API key at Settings → Secrets and variables → Actions → New secret ```TICKETMASTER_API_KEY```
3. To run **daily**, edit ```.github/workflows/tm_snapshot.yml``` and uncomment
    ```
    schedule:
    - cron: "0 7 * * *"
    ```
    The workflow does not run on push by default (disabled).
4. To run **manually**, go to GitHub → Actions → Ticketmaster Daily Snapshot → Run workflow.
    - This will fetch the next-90-days of “Music” events and appends to ```data/events_history.parquet```. It will create the parquet file if not exist.

### 2. Transform and Load

#### Install dependencies
```bash
pip install -r requirements.txt
```

#### Set Environment Variables
Create a `.env` file and set the API Key:
```bash
TICKETMASTER_API_KEY="YOUR_REAL_KEY"
```

#### Run Data Pipeline
```bash
python src/main.py --data ./data/events_history.parquet --db events.db
```
| Flag | Description |
|------|-------------|
| `--data <path>` | Input raw events parquet file |
| `--db <path>` | Output SQLite database. Will be created if not present. Recommended at project root. |
| `--clean` | Optional. Remove intermediate normalized CSVs after successful load. |
