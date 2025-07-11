-- Create Database
CREATE DATABASE OnlineBookstore;

-- Create Tables
DROP TABLE IF EXISTS Books;
CREATE TABLE Books (
    Book_ID SERIAL PRIMARY KEY,
    Title VARCHAR(100),
    Author VARCHAR(100),
    Genre VARCHAR(50),
    Published_Year INT,
    Price NUMERIC(10, 2),
    Stock INT
);

DROP TABLE IF EXISTS customers;
CREATE TABLE Customers (
    Customer_ID SERIAL PRIMARY KEY,
    Name VARCHAR(100),
    Email VARCHAR(100),
    Phone VARCHAR(15),
    City VARCHAR(50),
    Country VARCHAR(150)
);

DROP TABLE IF EXISTS orders;
CREATE TABLE Orders (
    Order_ID SERIAL PRIMARY KEY,
    Customer_ID INT REFERENCES Customers(Customer_ID),
    Book_ID INT REFERENCES Books(Book_ID),
    Order_Date DATE,
    Quantity INT,
    Total_Amount NUMERIC(10, 2)
);

SELECT * FROM orders;
SELECT * FROM books;
SELECT * FROM customers;

-- Que & Ans

-- Basic Ques

-- Q1: Retrieve all books in the "Fiction" genre
SELECT * FROM books
WHERE genre = 'Fiction';

-- Q2: Find books published after the year 1950
SELECT * FROM books 
WHERE published_year > '1950'
ORDER BY published_year ASC;

-- Q3: List all customers from the Canada
SELECT * FROM customers
WHERE country = 'Canada';

-- Q4: Show orders placed in November 2023
SELECT * FROM
        (SELECT *, EXTRACT(MONTH FROM order_date) 
		   AS order_month
           FROM orders)
WHERE order_month = '11';

-- Q5: Retrieve the total stock of books available
SELECT SUM(stock) AS total_stock
FROM books;

-- Q6: Find the details of the most expensive book
SELECT * FROM books
ORDER BY price DESC
LIMIT 1;

-- Q7: Show all customers who ordered more than 1 quantity of a book
SELECT * FROM orders
WHERE quantity > 1
ORDER BY quantity DESC;

-- Q8: Retrieve all orders where the total amount exceeds $20
SELECT * FROM orders
WHERE total_amount > 20
ORDER BY total_amount DESC;

-- Q9: Find the book with the lowest stock
SELECT * FROM books
WHERE stock = 0;

-- Q10: Calculate the total revenue generated from all orders
SELECT SUM(total_amount) AS total_revenue
FROM orders;

-- Q11: Find total number of books in stock grouped by genre
SELECT genre, SUM(stock) AS stock
FROM books
GROUP BY genre;


-- Advance Ques
-- Q12: List top 5 customers who ordered the most books
SELECT 
    c.Name, 
    SUM(o.Quantity) AS Total_Books_Ordered
FROM Orders o
JOIN Customers c ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID, c.Name
ORDER BY Total_Books_Ordered DESC
LIMIT 5;

-- Q13: Create a view to show best-selling books (more than 50 units sold)
CREATE VIEW BestSellers AS
SELECT B.Title, SUM(O.Quantity) AS Total_Sold
FROM Orders O
JOIN Books B ON O.Book_ID = B.Book_ID
GROUP BY B.Title
HAVING SUM(O.Quantity) > 50;

-- Q14: Retrieve the total number of books sold for each genre

SELECT b.Genre, SUM(o.Quantity) AS Total_Sold_Books
FROM Orders o
JOIN Books b ON o.Book_ID = b.Book_ID
GROUP BY b.Genre
ORDER BY b.Genre;

-- Q15: Find the average price of books in the "Fantasy" genre
SELECT genre,AVG(price) FROM books
WHERE genre = 'Fantasy'
GROUP BY genre;

-- Q16: List customers who have placed at least 2 orders
SELECT c.name, o.quantity
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE quantity BETWEEN 2 AND 6
ORDER BY quantity; 

-- Q17: Find the most frequently ordered book
SELECT o.book_id, b.title, SUM(o.order_id) AS order_count
FROM orders o
JOIN books b ON o.book_id = b.book_id
GROUP BY o.book_id, b.title
ORDER BY order_count DESC;

-- Q18: Show the top 3 most expensive books of 'Fantasy' Genre
SELECT * FROM books
WHERE genre='Fantasy'
ORDER BY price DESC LIMIT 3;

-- Q19: Retrieve the total quantity of books sold by each author
SELECT b.author, SUM(o.quantity) AS books_sold
FROM books b
JOIN orders o ON b.book_id=o.book_id
GROUP BY b.author;

-- Q20: List the cities where customers who spent over $200 are located
SELECT c.city, SUM(o.total_amount) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id=o.customer_id
GROUP BY c.city
HAVING SUM(o.total_amount) > 200;

-- Q21: Find top 5 customers who spent the most on orders
SELECT DISTINCT c.name, total_amount
FROM orders o
JOIN customers c ON o.customer_id=c.customer_id
ORDER BY total_amount DESC LIMIT 5;

-- Q22: Calculate the stock remaining after fulfilling all orders
SELECT 
   b.book_id, 
   b.title, 
   b.stock - COALESCE(SUM(o.quantity),0) AS stocks_left
FROM books b
LEFT JOIN orders o ON b.book_id=o.book_id
GROUP BY b.book_id, b.title, b.stock
HAVING (b.Stock - COALESCE(SUM(o.Quantity), 0))>0
ORDER BY stocks_left;

-- Q23: List books that have never been ordered
SELECT b.book_id, b.title
FROM books b
JOIN orders o ON b.book_id=o.book_id
WHERE o.order_id IS NULL;

-- Q24: Retrieve the most recent order placed for each customer
SELECT c.customer_id, c.name, MAX(o.order_date) AS last_order_date
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name;

-- Q25: Find the total revenue generated by each genre
SELECT b.genre, SUM(o.total_amount) AS total_revenue
FROM orders o
JOIN books b ON o.book_id = b.book_id
GROUP BY b.genre
ORDER BY total_revenue DESC;

-- Q26: List customers who ordered books from more than 1 genre
SELECT c.customer_id, c.name, COUNT(DISTINCT b.genre) AS genre_count
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN books b ON o.book_id = b.book_id
GROUP BY c.customer_id, c.name
HAVING COUNT(DISTINCT b.genre) > 1;

-- Q27: Find the average quantity ordered per book title
SELECT b.title, ROUND(AVG(o.quantity),1) AS avg_quantity
FROM books b
JOIN orders o ON b.book_id = o.book_id
GROUP BY b.title;

-- Q28: Get the month-wise total orders placed
SELECT DATE_TRUNC('month', o.order_date) AS order_month,
       COUNT(*) AS total_orders
FROM orders o
GROUP BY order_month
ORDER BY order_month;

-- Q29: Which books are low in stock (less than 5 units left after orders)?
SELECT 
    b.title,
    b.stock - COALESCE(SUM(o.quantity), 0) AS stock_left
FROM books b
LEFT JOIN orders o ON b.book_id = o.book_id
GROUP BY b.book_id, b.title, b.stock
HAVING (b.stock - COALESCE(SUM(o.quantity), 0)) < 5;

-- Q30: For each customer, show total books ordered and total amount spent
SELECT 
    c.name,
    SUM(o.quantity) AS total_books_ordered,
    SUM(o.total_amount) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.name;

-- Q31: Show genres where more than 100 books have been sold
SELECT b.genre, SUM(o.quantity) AS total_sold
FROM orders o
JOIN books b ON o.book_ID = b.book_id
GROUP BY b.genre
HAVING SUM(o.quantity) > 100;

-- Q32: Rank customers based on total spending using RANK()
SELECT 
    c.name,
    SUM(o.total_amount) AS total_spent,
    RANK() OVER (ORDER BY SUM(o.total_amount) DESC) AS spending_rank
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name;






