create database hotel_reservation;
use hotel_reservation;
-- 1. hotels
create table hotels (
    hotel_id varchar(20) primary key,
    hotel_name varchar(100),
    city varchar(50),
    star_rating int,
    total_rooms int,
    opened_date date
);

-- 2. guests
create table guests (
    guest_id varchar(20) primary key,
    guest_name varchar(100),
    city varchar(50),
    guest_type varchar(20),
    preferred_room_type varchar(20),
    loyalty_tier varchar(20),
    account_since varchar(20)
);

-- 3. staff
create table staff (
    staff_id varchar(20) primary key,
    staff_name varchar(100),
    hire_date date,
    rating decimal(3,2),
    department varchar(30),
    is_active varchar(3)
);

-- 4. rooms
create table rooms (
    room_id varchar(20) primary key,
    hotel_id varchar(20),
    room_type varchar(20),
    floor_number int,
    max_occupancy int,
    price_per_night decimal(10,2),
    is_active varchar(3),
    foreign key (hotel_id) references hotels(hotel_id)
);

-- 5. bookings
create table bookings (
    booking_id varchar(20) primary key,
    guest_id varchar(20),
    hotel_id varchar(20),
    booking_date varchar(20),
    room_type_requested varchar(20),
    booking_channel varchar(30),
    nights_booked int,
    total_amount decimal(12,2),
    foreign key (guest_id) references guests(guest_id),
    foreign key (hotel_id) references hotels(hotel_id)
);

-- 6. stays (last)
create table stays (
    stay_id varchar(20) primary key,
    booking_id varchar(20),
    room_id varchar(20),
    staff_id varchar(20),
    check_in_date date,
    check_out_date date,
    status varchar(20),
    nights_stayed int,
    service_requests int,
    stay_duration_hrs int,
    foreign key (booking_id) references bookings(booking_id),
    foreign key (room_id) references rooms(room_id),
    foreign key (staff_id) references staff(staff_id)
);

select * from hotels;
select * from guests;
select * from staff;
select * from rooms;
select * from stays;
select * from bookings;
show tables;

-- 1.4 1.Management wants to find guests who have made multiple bookings. What information would you need to identify them?
select guest_id,count(*) from bookings group by guest_id order by count(*) desc;

-- 2.The Operations team wants to identify stays that were checked in but later marked as no-show or cancelled. Where would you find the information needed to investigate this?
select * from Bookings b
join stays s on s.booking_id = b.booking_id
jOIN guests g on b.guest_id = g.guest_id
where s.status IN ('No-show', 'Cancelled');

-- 3.The Guest Experience team wants to compare Individual and Corporate guests based on their booking activity. Which tables and columns would you need?
SELECT 
    g.guest_type,
    COUNT(b.booking_id) AS total_bookings,
    AVG(b.nights_booked) AS avg_nights,
    AVG(b.total_amount) AS avg_spend,
    SUM(b.total_amount) AS total_revenue
FROM Guests g
JOIN Bookings b ON g.guest_id = b.guest_id
GROUP BY g.guest_type;

-- 4.The Operations team wants to compare different booking channels based on how many nights guests stay and how much they spend. 
-- Which tables would you need to connect?
select booking_channel,count(*) as total_count,sum(nights_booked) as total_nights,sum(total_amount) as total_spent from bookings group by booking_channel;

-- 5.The team wants to identify which staff members have handled stays and examine their recorded ratings.
-- What information would you need?
select staff_name,s.staff_id,s.department,count(*),sum(rating) from staff s
join stays t on   s.staff_id=t.staff_id
group by staff_name,s.staff_id,s.department;

-- 6. Operations wants to understand whether different room types are being booked for different stay durations.
-- Which tables and columns would you need?
select room_type_requested,count(*),sum(stay_duration_hrs) as sum_stay_duration from stays s
join bookings b on s.booking_id=b.booking_id
group by room_type_requested order by  sum_stay_duration desc;

-- 7.Management wants to compare booking performance across different hotels.
-- What information would you need from the database?
select h.hotel_id,city,hotel_name,count(*) as total_bookings,sum(nights_booked) as total_nights_stay, sum(stay_duration_hrs) as total_hrs_stay from bookings b
join hotels h on h.hotel_id=b.hotel_id
join stays s on s.booking_id=b.booking_id
group by h.hotel_id,city,hotel_name;

-- 8.The Operations team wants to investigate whether larger room capacities are associated with higher service requests during a stay. 
-- Which information would you need, and where would you find it?
select max_occupancy,avg(service_requests) as service from stays s
join rooms r on r.room_id=s.room_id
group by max_occupancy order by service desc;

-- 9.Management wants to understand whether stay outcomes differ across booking channels. 
-- What tables and information would you bring together?
select guest_name,b.guest_id,count(nights_booked) as total_bookings,
sum(stay_duration_hrs) as total_duration_hrs,
sum(nights_stayed) as total_nights_stay,
sum(service_requests) as total_requests,
sum(total_amount) as total_amount from bookings b
join guests g on g.guest_id=b.guest_id
join stays s on b.booking_id=s.booking_id
group by b.guest_id,g.guest_name order by total_bookings desc;

-- 10.The Operations team wants to understand which guests have made bookings and how their stays are being handled. 
-- What information would you need to connect a guest with their bookings and stays?
select guest_name,b.guest_id,count(nights_booked) as total_bookings,
sum(stay_duration_hrs) as total_duration_hrs,
sum(nights_stayed) as total_nights_stay,
sum(service_requests) as total_requests,
sum(total_amount) as total_amount from bookings b
join guests g on g.guest_id=b.guest_id
join stays s on b.booking_id=s.booking_id
group by b.guest_id,g.guest_name order by total_bookings desc;

-- Sprint 3
-- 1.What is the total number of guests?
select count(*) from guests;
-- 2.What is the total number of bookings?
select count(*) from bookings;
-- 3.What is the total number of stays?
select count(*) from stays;
-- 4. What are the different room types available?
select distinct room_type from rooms;
-- 5. How many staff members are currently active?
select count(*) from staff where is_active="Yes";
-- 6.What are the different booking channels?
select distinct booking_channel from bookings;
-- 7.What is the total booking amount across all bookings?
select sum(total_amount) from bookings;
-- 8. What is the average nights booked per booking?
select avg(nights_booked) from bookings;

-- Sprint 4
-- 4.1
-- 1.Compare the number of bookings across hotels.
select hotel_id,count(*) from bookings group by hotel_id;
-- 2.Compare bookings across different booking channels.
select booking_channel,count(*) from bookings group by booking_channel;
-- 3.Compare bookings based on room type requested.
select room_type_requested,count(*) from bookings group by room_type_requested;
-- 4.Examine how booking volume changes over time.
SELECT booking_date,COUNT(*)
FROM bookings b GROUP BY booking_date;
-- 5.Look at the booking amount across different groups.
select room_type_requested,sum(total_amount) from bookings group by room_type_requested;
-- 4.3 Evaluate Stay Performance
-- 1.Compare stay outcomes across different hotels (hotel information is on the bookings table, so you will need to connect bookings and stays).
select h.hotel_id,h.hotel_name,h.city,count(s.stay_id) as total_bookings,h.opened_date,sum(b.total_amount) as total_revenue,round(avg(h.total_rooms)) as total_rooms,round(avg(h.star_rating) ,1) as avg_rating,
round((avg(s.service_requests)*10),2) avg_service_requested,sum(b.nights_booked) as total_nights_booked,
sum(s.nights_stayed) as  total_nightstayed,sum(s.stay_duration_hrs) as total_hrs_stay from stays s
join bookings b on b.booking_id=s.booking_id
join hotels h on h.hotel_id=b.hotel_id
group by h.hotel_name,h.hotel_id,city,h.opened_date;

-- 2.Examine stay duration.
SELECT 
    b.hotel_id,
    h.hotel_name,
    h.city,
    r.room_type,
    COUNT(b.booking_id) AS total_bookings,
    AVG(nights_stayed) AS avg_stay_duration,
    MAX(nights_stayed) AS longest_stay,
    sum(total_amount) as total_amount
FROM Bookings b
JOIN Stays s ON b.booking_id = s.booking_id
JOIN Rooms r ON s.room_id = r.room_id
join hotels h on b.hotel_id=h.hotel_id
GROUP BY b.hotel_id, r.room_type,h.hotel_name,h.city
ORDER BY b.hotel_id, avg_stay_duration DESC;

-- 3.Compare stay outcomes by status (Checked-out, No-show, Cancelled, In-progress) — these are not a simple success/failure split, so 
-- consider what each status actually represents.
select  s.status,count(*) as total_count,sum(b.total_amount) as total_revenue,sum(nights_stayed) as total_stayed,round(avg(nights_stayed),2) as avg_night_stayed,sum(stay_duration_hrs) as total_stayed_hrs from stays s
join bookings b on b.booking_id=s.booking_id
group by s.status;

-- 4.Identify hotels with higher booking activity or poorer outcomes.
select h.hotel_id,h.hotel_name,h.city,round(avg(h.total_rooms)) as total_rooms,count(*) as total_bookings,
round(avg(h.star_rating),1) as avg_hotel_rating,avg(s.service_requests)*10 as service_requests,sum(b.total_amount) as total_revenue from hotels h
join bookings b on b.hotel_id=h.hotel_id
join stays s on b.booking_id=s.booking_id
group by h.hotel_id order by total_bookings desc;

-- 5.Compare stay performance over time.
SELECT 
    YEAR(s.check_in_date) AS stay_year,
    MONTH(s.check_in_date) AS stay_month,
    COUNT(s.stay_id) AS total_stays,
    sum(s.nights_stayed) AS total_stay_duration,
    AVG(h.star_rating) AS avg_satisfaction,
    AVG(s.service_requests)*10 AS avg_requests,
    SUM(b.total_amount) AS total_revenue
FROM stays s
join bookings b on b.booking_id=s.booking_id
join hotels h on h.hotel_id=b.hotel_id
GROUP BY YEAR(s.check_in_date), MONTH(s.check_in_date)
ORDER BY stay_year, stay_month;

-- 4.4 Understand Staff and Room Performance
-- 1.Compare the number of stays handled by staff members.
select sf.staff_id,sf.staff_name,sum(service_requests) as total_handled from stays s 
join staff sf on s.staff_id=sf.staff_id
group by staff_id order by total_handled desc;

-- 2.Compare staff performance across stay outcomes.
-- Compare staff performance across stay outcomes.
select sf.staff_id,sf.staff_name,sf.department,sf.hire_date,sum(s.service_requests) as total_handled,
is_active from staff sf
join stays s on s.staff_id=sf.staff_id
group by sf.staff_id order by total_handled desc;

-- 3.Examine stay duration across staff members.
select s.stay_id,s.check_in_date,s.check_out_date,sum(s.nights_stayed) as total_nights, sum(s.stay_duration_hrs) as total_hrs,sf.staff_id,sf.staff_name,department,rating from staff sf
join stays s on s.staff_id=sf.staff_id
group by s.stay_id order by total_hrs desc;

-- 4.Compare room usage across different room types.
select room_type_requested,max_occupancy as room_capacity,count(*),sum(nights_booked)as total_booked,
sum(total_amount) as total_revenue from bookings b
join hotels h on h.hotel_id=b.hotel_id
join rooms r on r.hotel_id=h.hotel_id
group by room_type_requested,room_capacity order by total_booked desc;

-- 5.Look at stay performance across different rooms.
select r.room_type,
    COUNT(b.booking_id) as total_bookings,
    avg(nights_stayed) as avg_stay_duration,
    SUM(b.total_amount) as total_revenue,
    round(avg(b.total_amount / NULLIF(nights_stayed,0)),2) as avg_revenue_per_night from stays s
join rooms r on r.room_id=s.room_id
join bookings b on b.booking_id=s.booking_id
group by
    r.room_type
order by 
    total_revenue desc;

-- 4.5 Identify Booking and Stay Problems
-- 1.Examine which bookings resulted in cancellations or no-shows.
select 
    b.booking_id,
    b.guest_id,
    b.booking_date,
    s.room_id,
    s.stay_id,
    s.status,
    s.check_in_date,
    s.check_out_date
from Bookings b
join Stays s 
    on b.booking_id = s.booking_id
where s.status in ('Cancelled', 'No-Show')
order by b.booking_date;

-- 2.Identify common stay statuses and problem patterns.
select 
    s.status,
    COUNT(*) AS total_cases,
    ROUND(100.0 * COUNT(*) / (select COUNT(*) from Stays), 2) as percentage
from Stays s
group by s.status
order by total_cases desc;

-- 3.Compare stay performance for bookings with high service request counts.
select 
    b.booking_id,
    r.room_type,
    s.stay_id,
    s.service_requests,
    avg(nights_stayed) as avg_stay_duration,
    avg(b.total_amount) as avg_revenue
from Bookings b
join Stays s on b.booking_id = s.booking_id
join Rooms r on s.room_id = r.room_id
where s.service_requests >= 5   -- threshold for "high" requests
group by b.booking_id, r.room_type, s.stay_id, s.service_requests
order by s.service_requests desc;

-- 4 Examine whether certain hotels experience more booking problems.
select 
    h.hotel_id,
    h.hotel_name,
    COUNT(b.booking_id) as total_bookings,
    SUM(case when s.status = 'Cancelled' then 1 else 0 end) as cancellations,
    SUM(case when s.status = 'No-Show' then 1 else 0 end) as no_shows,
    ROUND(100.0 * SUM(case when s.status in ('Cancelled','No-Show') then 1 else 0 end) / COUNT(b.booking_id), 2) as problem_rate_percentage
from Bookings b
left join Stays s ON b.booking_id = s.booking_id
join hotels h on h.hotel_id=b.hotel_id
group by h.hotel_id, h.hotel_name
order by problem_rate_percentage desc;

-- Findings and business insights.

-- Revenue Optimization: Premium rooms yield strong nightly revenue; focus on upselling strategies.
-- Policy Adjustments: Reduce cancellations/no-shows with stricter booking guarantees and targeted interventions.
-- Operational Efficiency: Monitor service request handling—guest satisfaction hinges on responsiveness.
-- Hotel Benchmarking: Identify underperforming hotels and replicate success factors from top performers.
-- Data-Driven Strategy: Use dashboards to continuously track booking outcomes, service requests, and satisfaction trends.


-- Final conclusions and recommendations wherever appropriate.

-- Room Performance  
-- Premium rooms deliver higher nightly revenue, while standard rooms dominate in volume. Both segments are essential—profitability comes from premium, stability from standard.

-- Booking Problems  
-- Cancellations and no-shows are concentrated in certain hotels and booking channels. These patterns suggest operational or policy weaknesses rather than random guest behavior.

-- Stay Status Trends  
-- Most stays end successfully, but cancellations and no-shows form a significant minority. Tracking these trends by season and channel reveals recurring problem spikes.

-- Service Requests  
-- High-request stays often align with longer durations. Satisfaction dips when requests are not handled efficiently, but these guests can be high-value if well-served.

-- Hotel-Level Variability  
-- Some hotels consistently show higher problem rates, pointing to localized issues in management, pricing, or guest targeting.