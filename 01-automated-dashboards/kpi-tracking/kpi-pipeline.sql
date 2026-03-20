-- KPI PIPELINE (Sales → Connected → Registered)

CREATE OR REPLACE TABLE Z_wbr.kpi_core AS
WITH base AS (
  SELECT CASE WHEN Product="Total_HA" THEN "H&A" ELSE Product END AS product, Date, Month, Week,
         IF(Month IS NULL,"Week","Month") AS date_type,
         SalesInc AS sales_inc, Connected_Inc AS conn_inc,
         SAFE_DIVIDE(Connected_Inc, SalesInc)*100 AS conn_rate
  FROM ConnectedDevices.connected_sales
  WHERE Product IN ("Total","TV","Total_HA")
),
sales AS (
  SELECT product, Date, Month, Week, date_type, sales_inc,
         SUM(sales_inc) OVER (PARTITION BY product, date_type ORDER BY Date) AS sales_accum,
         IFNULL(SAFE_DIVIDE(sales_inc, LAG(sales_inc) OVER (PARTITION BY product, date_type ORDER BY Date)) - 1,0) AS sales_change
  FROM base
),
connected AS (
  SELECT product, Date, Month, Week, date_type, conn_inc,
         SUM(conn_inc) OVER (PARTITION BY product, date_type ORDER BY Date) AS conn_accum,
         conn_rate,
         IFNULL(SAFE_DIVIDE(conn_inc, LAG(conn_inc) OVER (PARTITION BY product, date_type ORDER BY Date)) - 1,0) AS conn_change
  FROM base
),
reg AS (
  SELECT CASE WHEN device_type="TV" THEN "TV" ELSE "H&A" END AS product,
         DATE_TRUNC(DATE(SUBSTR(created_date,1,10)), MONTH) AS Date,
         COUNT(*) AS regist_cnt
  FROM `thinq-290413.ThinQ_app.product_regist_hash`
  WHERE hashed_device_id IS NOT NULL
  GROUP BY 1,2
),
reg_metrics AS (
  SELECT product, Date, regist_cnt,
         SUM(regist_cnt) OVER (PARTITION BY product ORDER BY Date) AS regist_accum
  FROM reg
),
final AS (
  SELECT s.product, s.Date, s.date_type,
         s.sales_inc, s.sales_accum,
         c.conn_inc, c.conn_accum, c.conn_rate,
         r.regist_cnt, r.regist_accum,
         SAFE_DIVIDE(r.regist_cnt, c.conn_inc)*100 AS regist_rate
  FROM sales s
  LEFT JOIN connected c USING (product, Date, date_type)
  LEFT JOIN reg_metrics r USING (product, Date)
)

SELECT * FROM final
ORDER BY Date, product;
