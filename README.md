# js-library-usage
An analysis of http archive data, showing JS library usage over time.

See graph [here](https://tdresser.github.io/js-library-usage/).

BigQuery, based on queries [here](https://discuss.httparchive.org/t/javascript-library-detection/955/9).
Query can be found [here](https://bigquery.cloud.google.com/savedquery/820195827355:9e1b3b521a964fa4b7b3b944b7e48ddd).
```sql
#standardSQL
CREATE TEMPORARY FUNCTION getJsLibs(payload STRING)
RETURNS ARRAY<STRUCT<name STRING, version STRING>>
LANGUAGE js AS """
  try {
    const $ = JSON.parse(payload);
    const libs = JSON.parse($['_third-parties']);
    return Array.isArray(libs) ? libs : [];
  } catch (e) {
    return [];
  }
""";

SELECT
  date,
  client,
  lib.name AS library,
  COUNT(DISTINCT url) AS frequency
FROM (
  SELECT
    REPLACE(SUBSTR(_TABLE_SUFFIX, 0, 10), '_', '-') AS date,
    IF(ENDS_WITH(_TABLE_SUFFIX, 'desktop'), 'desktop', 'mobile') AS client,
    url,
    getJsLibs(payload) AS libs
  FROM
    `httparchive.pages.*`),
  UNNEST(libs) AS lib
GROUP BY
  date,
  client,
  library
ORDER BY
  date,
  client,
  library
  ```
