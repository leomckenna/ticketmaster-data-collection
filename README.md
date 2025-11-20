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

## Usage

### 1. Extract Raw Ticketmaster Data
This pipeline uses the Ticketmaster Discovery API, filtered by `classificationName=Music`, to pull data: https://app.ticketmaster.com/discovery/v2/events.json. See the official docs for request parameters and authentication.

**Important**: Ticketmaster's API has strict rate limits per day/hour and only returns a rolling ~90-day window of future events. It provides no historical data or versioning.
- Running the extractor once either locally or manually via Github Actions will only fetch one snapshot of the next ~90 days of events. 
- Running the extractor daily is the only way to accumulate a historical dataset that captures changes in event details (new events, cancellations, price updates, venue/time updates, etc.).

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
This will fetch the latest 90-day “Music” events and append them to ```data/events_history.parquet``` with a `snapshot_date`. If the file does not exist, it will be created. Multiple manual runs on the same day will not pull more data.


#### Automated Extractor via Github Actions
1. Fork/clone this repo into your own GitHub account
2. Add your API key under Settings → Secrets and variables → Actions → New secret ```TICKETMASTER_API_KEY```
3. To run **daily**, edit ```.github/workflows/tm_snapshot.yml``` and uncomment
    ```
    schedule:
    - cron: "0 7 * * *"
    ```
    Then push the edited workflow file. GitHub will automatically run the extractor every day at 7:00 UTC. (Extracting on push is disabled by default.)
    
    To disable daily run, keep all triggers (```schedule:```, ```push:```) commented out, and push the changes. 
4. To run **manually**, go to GitHub → Actions → Ticketmaster Daily Snapshot → Run workflow.
    - This will fetch the latest 90-day “Music” events and append them to ```data/events_history.parquet``` with a `snapshot_date`. If the file does not exist, it will be created. Multiple manual runs on the same day will not pull more data.

### 2. Transform and Load

#### Run Data Pipeline Locally
```bash
python src/main.py --data ./data/events_history.parquet --db events.db
```
| Flag | Description |
|------|-------------|
| `--data <path>` | Input raw events parquet file |
| `--db <path>` | Output SQLite database. Will be created if not present. Recommended at project root. |
| `--clean` | Optional. Remove intermediate normalized CSVs after successful load. |
