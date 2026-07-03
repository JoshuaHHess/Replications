# Raw data folder

Place student-collected data here. These files are ignored by git by default.

## Required replication file

`walker_cds_applicants.csv`

Required columns:

```text
institution,state,year,female_applicants,male_applicants,us_news_rank,pct_out_state,source_url
```

## Optional literal Title IX religious exemption file

`ocr_title_ix_religious_exemptions.csv`

Suggested columns:

```text
institution,state,exemption_requested_date,exemption_granted,exemption_topic,source_url,notes
```

Use this only if the class extension is literal religious exemptions rather than The Pregnant Scholar policy-directory indicators.

