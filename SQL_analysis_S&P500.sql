-- S&P 500 index share prices in 2014-2017
-- PostgreSQL analysis by Adrian Skowronski



-- Which day in the sample had the highest overall trading volume? 
-- Which two stocks were the most traded that day?

with BestDay as (
select sum(volume) as overall_trade_volume
, "date"
from sp group by "date" 
order by overall_trade_volume desc
limit 1
)
select symbol
, volume
, "date"
from sp s2 where date=(select date from BestDay)
order by volume desc 
limit 2;



-- On which day of the week is volume usually highest? And when is it lowest?

alter table	sp 
add column weekday varchar;
update sp 
set weekday= To_Char("date", 'day');

select weekday
, round(avg(volume), 2) as average_volume 
from sp group by weekday 
order by average_volume desc;



-- On which day did Amazon (AMZN) experience the highest volatility, 
-- measured by the difference between the highest and lowest price?

select high
, low
, round(cast(high-low as numeric),2) as volatility
, "date" 
from sp 
where symbol='AMZN' 
order by volatility desc
limit 10;



-- If you could go back in time and invest in one stock from 02/01/2014 to 29/12/2017,
-- which one would you choose? What % profit would you realize?

with buy as(
select symbol
, low 
from sp 
where "date"='2014-01-02'
),
	 sell as(
select symbol
, high 
from sp 
where "date" = '2017-12-29'
)
select sp.symbol as company
, round(cast(buy.low as numeric), 2) as buy
, round(cast(sell.high as numeric), 2) as sell
, round(cast(sell.high-buy.low as numeric), 2) as profit
, round(((sell.high::numeric / buy.low::numeric) - 1) * 100, 2) as percentage_profit
from sp
join buy on sp.symbol = buy.symbol
join sell on sp.symbol = sell.symbol
where sp."date" = '2014-01-02'
order by profit desc 
limit 10;



