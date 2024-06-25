--BASIC QUESTIONS
--Q1: senior most employee
select * from employee
order by levels desc
limit 1;

--Q2: countries with most invoices
select count(billing_country) as n_invoices, billing_country
from invoice
group by billing_country
order by n_invoices desc
limit 5;

--Q3: top 3 values of total invoices
select total from invoice
order by total desc
limit 3;

--Q4: city with the greatest sum total of invoices
select sum(total) as invoice_total, billing_city 
from invoice
group by billing_city
order by invoice_total desc
limit 1;

--Q5: customer who has spent the most 
select customer.customer_id, customer.first_name, customer.last_name, sum(total) as total 
from customer join invoice on 
customer.customer_id = invoice.customer_id
group by customer.customer_id
order by total desc
limit 1;
----------------------------------------------------------------------------------------------------

--Intermediate questions
--Q1: email, first name, last name of all rock music listeners
select distinct customer.email, customer.first_name, customer.last_name, genre.name from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
join track on invoice_line.track_id = track.track_id
join genre on track.genre_id = genre.genre_id
where genre.name like 'Rock'
order by customer.email asc;

--Q2: artist name and total track count of top 10 Rock bands
select artist.artist_id, artist.name, count(artist.artist_id) as total_songs from artist
join album on artist.artist_id = album.artist_id
join track on album.album_id = track.album_id
join genre on track.genre_id = genre.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by total_songs desc
limit 10;

--Q3: track names with length longer than the average song length
select name, milliseconds from track
where milliseconds > (
	select avg(milliseconds) from track
	)
order by milliseconds desc;
----------------------------------------------------------------------------------------------------

--Q1: artist with highest sales

select a.artist_id, a.name, sum(il.unit_price * il.quantity) as total_earning
from artist a
join album al on a.artist_id = al.artist_id
join track t on al.album_id = t.album_id
join invoice_line il on t.track_id = il.track_id
group by 1, 2
order by 3 desc
limit 1;

--Q2: amount spent by each customer on highest selling artist
with best_selling_artist as (
	select a.artist_id, a.name, sum(il.unit_price * il.quantity) as total_earning
	from artist a
	join album al on a.artist_id = al.artist_id
	join track t on al.album_id = t.album_id
	join invoice_line il on t.track_id = il.track_id
	group by 1, 2
	order by 3 desc
	limit 1
)

select c.customer_id, c.first_name, c.last_name, bsa.name, sum(il.unit_price * il.quantity)
from customer c
join invoice i on c.customer_id = i.customer_id
join invoice_line il on i.invoice_id = il.invoice_id
join track t on il.track_id = t.track_id
join album al on t.album_id = al.album_id
join best_selling_artist bsa on al.artist_id = bsa.artist_id
group by 1,2,3,4
order by 5 desc;

--Q3: customers that have spent most on music in each country
with customer_by_country as(
	select c.customer_id, c.first_name, c.last_name, i.billing_country, sum(total) as total_spend,
	row_number() over(partition by billing_country order by sum(total) desc) as rowno
	from  customer c
	join invoice i on c.customer_id = i.customer_id
	group by 1,2,3,4
	order by 4 asc, 5 desc
	)
select * from customer_by_country where rowno <= 1