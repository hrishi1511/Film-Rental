SELECT SUM(amount) AS total_revenue
FROM payment;


SELECT 
    MONTHNAME(rental_date) AS month_name,
    COUNT(*) AS rental_count
FROM rental
GROUP BY MONTHNAME(rental_date), MONTH(rental_date)
ORDER BY MONTH(rental_date);



SELECT 
    title,
    rental_rate
FROM film
ORDER BY LENGTH(title) DESC
LIMIT 1;


SELECT 
    AVG(film.rental_rate) AS average_rental_rate
FROM rental
JOIN inventory ON rental.inventory_id = inventory.inventory_id
JOIN film ON inventory.film_id = film.film_id
WHERE rental.rental_date >= DATE_SUB('2005-05-05 22:04:30', INTERVAL 30 DAY);


SELECT 
    category.name AS category_name,
    COUNT(rental.rental_id) AS rental_count
FROM rental
JOIN inventory ON rental.inventory_id = inventory.inventory_id
JOIN film ON inventory.film_id = film.film_id
JOIN film_category ON film.film_id = film_category.film_id
JOIN category ON film_category.category_id = category.category_id
GROUP BY category.name
ORDER BY rental_count DESC
LIMIT 1;


SELECT 
    MAX(film.length) AS longest_duration
FROM film
LEFT JOIN inventory ON film.film_id = inventory.film_id
LEFT JOIN rental ON inventory.inventory_id = rental.inventory_id
WHERE rental.rental_id IS NULL;


SELECT 
    c.name AS category_name,
    AVG(f.rental_rate) AS average_rental_rate
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
GROUP BY c.name;


SELECT 
    a.actor_id,
    CONCAT(a.first_name, ' ', a.last_name) AS actor_name,
    SUM(p.amount) AS total_revenue
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film f ON fa.film_id = f.film_id
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN payment p ON r.rental_id = p.rental_id
GROUP BY a.actor_id, actor_name;



SELECT 
    DISTINCT CONCAT(a.first_name, ' ', a.last_name) AS actress_name
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film f ON fa.film_id = f.film_id
WHERE f.description LIKE '%Wrestler%' AND a.actor_id IN (
    SELECT actor_id
    FROM film_actor
    GROUP BY actor_id
    HAVING COUNT(DISTINCT film_id) = (
        SELECT COUNT(film_id)
        FROM film
        WHERE description LIKE '%Wrestler%'
    )
);



SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
WHERE r.rental_id IN (
    SELECT rental_id
    FROM rental
    GROUP BY rental_id
    HAVING COUNT(rental_id) > 1
);
SELECT 
    f.title,
    f.rental_rate,
    c.name AS category_name
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
WHERE c.name = 'Comedy' AND f.rental_rate > (
    SELECT AVG(rental_rate)
    FROM film
);



SELECT 
    c.city,
    f.title,
    COUNT(*) AS rentals_count
FROM city c
JOIN address a ON c.city_id = a.city_id
JOIN customer cu ON a.address_id = cu.address_id
JOIN rental r ON cu.customer_id = r.customer_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
GROUP BY c.city, f.title
ORDER BY c.city, rentals_count DESC;




SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    SUM(p.amount) AS total_amount_spent
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
WHERE p.amount > 200
GROUP BY c.customer_id, customer_name;



SELECT 
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_NAME = 'rental' AND TABLE_SCHEMA = 'film_rental';


CREATE VIEW staff_revenue_view AS
SELECT 
    s.staff_id,
    CONCAT(s.first_name, ' ', s.last_name) AS staff_name,
    c.city,
    co.country,
    SUM(p.amount) AS total_revenue
FROM staff s
JOIN store st ON s.store_id = st.store_id
JOIN address a ON st.address_id = a.address_id
JOIN city c ON a.city_id = c.city_id
JOIN country co ON c.country_id = co.country_id
JOIN payment p ON s.staff_id = p.staff_id
GROUP BY s.staff_id, staff_name, c.city, co.country;




CREATE VIEW rental_info_view AS
SELECT 
    r.rental_id,
    DATE(r.rental_date) AS visiting_day,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    f.title AS film_title,
    DATEDIFF(r.return_date, r.rental_date) AS no_of_rental_days,
    p.amount AS amount_paid,
    (p.amount / (DATEDIFF(r.return_date, r.rental_date) + 1)) * 100 AS percentage_spending
FROM rental r
JOIN customer c ON r.customer_id = c.customer_id
JOIN payment p ON r.rental_id = p.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id;




SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
JOIN payment p ON r.rental_id = p.rental_id
GROUP BY c.customer_id, customer_name
HAVING SUM(p.amount) >= 0.5 * (
    SELECT SUM(amount)
    FROM payment
    WHERE customer_id = c.customer_id
);






