CREATE TABLE feedback (
    id SERIAL PRIMARY KEY,
    order_id INT UNIQUE NOT NULL,
    feedback_comment TEXT,
    rating INT,
    CONSTRAINT fk_feedback_order
        FOREIGN KEY (order_id)
        REFERENCES orders(id)
);
