select * from album;
select * from employee;

-- Q1: Who is the senior most employee based on birthdate?
select birthdate from employee;

SELECT 
concat(first_name , ' ' , last_name) AS "Full Name" ,
DATE_PART('year' ,AGE(birthdate)) AS Senior_Most_Employee_By_Age
FROM 
employee
order by DATE_PART('year' ,AGE(birthdate)) desc 
limit 1;

-- Q2: Who is the senior most employee based on job title? 

select concat(first_name , ' ' , last_name) as "Full Name" , levels 
from employee
order by levels desc limit 1;

-- Q3:Which countries have the most Invoices? 

select * from invoice;

select billing_country , count(*) from invoice
group by billing_country
order by count(*) desc ;

-- Q4:What are top 3 values of total invoice? 
select * from invoice;

select total from invoice
order by total desc limit 3;

/* Q5 : Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

select  billing_city , sum(total) as "Total Invoice" from invoice
group by billing_city
order by sum(total) desc ;

/* Q6 : Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

select * from customer;

select  customer.customer_id  , concat(trim(customer.first_name) , ' ' , trim(customer.last_name))  , 
sum(invoice.total) from customer
inner join
invoice 
on customer.customer_id = invoice.customer_id
group by customer.customer_id
order by sum(invoice.total) desc;

-- Moderate : 

/* Q7: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

select * from customer;
select * from invoice;
select * from invoice_line;
select * from track;
select * from genre;

select distinct email , trim(first_name) as "First Name" , trim(last_name) "Last Name"
from customer
inner join invoice on customer.customer_id = invoice.customer_id 
inner join invoice_line on invoice_line.invoice_id = invoice.invoice_id
where track_id in (
select track.track_id from Track
inner join 
Genre
on track.genre_id=Genre.genre_id 
where genre.name = 'Rock')
order by email;

/* Q8: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select  Artist.name  , count(*) from Artist
inner join Album on Artist.artist_id = Album.artist_id
inner join Track on Album.album_id = Track.album_id
inner join Genre on Track.genre_id = Genre.genre_id
where Genre.name = 'Rock'
group by Artist.artist_id
order by count(*) desc
limit 10;


/* Q9: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

select * from track;

select Name , milliseconds from Track where milliseconds > (
select avg(milliseconds) from track)
order by milliseconds desc;


-- Advance:

/* Q10: Find how much amount spent by each customer on artists? 
Write a query to return customer name, artist name and total spent */

with best_selling_artist as (
select Artist.artist_id ,Artist.name as "artist_name" ,sum(invoice_line.unit_price * invoice_line.quantity) as "total sales" 
from invoice_line
inner join Track on invoice_line.track_id = track.track_id
inner join Album on track.album_id = Album.album_id 
inner join Artist on Album.artist_id = Artist.artist_id
group by 1 ,2
order by 3 desc
limit 1)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist  bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4;


/* Q11: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */


WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1

/* Q12: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

with cte as (
select customer.customer_id , customer.first_name , customer.last_name , invoice.billing_country,  sum(invoice.total),
row_number() over(partition by billing_country order by sum(total) desc ) as RowNo
from invoice
join customer on customer.customer_id = invoice.customer_id
group by 1 , 2, 3 ,4
order by 4 asc , 5 desc)
select * from cte 
where rowno= 1 ;


