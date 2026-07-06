import pandas as pd
from faker import Faker
import random
from datetime import datetime, timedelta
import os

# Initialize Faker and seed for reproducibility
fake = Faker()
Faker.seed(42)
random.seed(42)

# Configuration Variables
NUM_USERS = 2500
START_DATE = datetime(2023, 1, 1)
END_DATE = datetime(2023, 12, 31)
OUTPUT_DIR = "mock_data"

# Ensure output directory exists
if not os.path.exists(OUTPUT_DIR):
    os.makedirs(OUTPUT_DIR)

# ---------------------------------------------------------
# 1. Generate dim_users
# ---------------------------------------------------------
print("Generating dim_users...")
users = []
for i in range(1, NUM_USERS + 1):
    users.append({
        'user_id': f"usr_{i}",
        'name': fake.name(),
        'email': fake.email(),
        'acquisition_source': random.choice(['Organic', 'Paid Social', 'Search', 'Referral']),
        'created_at': fake.date_time_between(start_date=START_DATE, end_date=END_DATE).strftime('%Y-%m-%d %H:%M:%S')
    })
dim_users = pd.DataFrame(users)

# ---------------------------------------------------------
# 2. Generate fct_orders, fct_order_items, and fct_payments
# ---------------------------------------------------------
print("Generating transactions...")
orders = []
order_items = []
payments = []

order_counter = 1
item_counter = 1
payment_counter = 1

def random_date(start, end):
    """Generate a random datetime between two datetime objects."""
    delta = end - start
    random_seconds = random.randint(0, int(delta.total_seconds()))
    return start + timedelta(seconds=random_seconds)

for user in users:
    # Business Logic: Simulate different customer retention tiers
    # 40% bounce after 1 order, 35% buy 2-3 times, 25% are loyalists (4-12 times)
    user_type = random.random()
    if user_type < 0.40:
        num_orders = 1
    elif user_type < 0.75:
        num_orders = random.randint(2, 3)
    else:
        num_orders = random.randint(4, 12)
        
    current_date = random_date(START_DATE, END_DATE - timedelta(days=30))
    
    for _ in range(num_orders):
        if current_date > END_DATE:
            break
            
        order_id = f"ord_{order_counter}"
        status = random.choices(
            ['Complete', 'Shipped', 'Processing', 'Cancelled', 'Returned'],
            weights=[0.60, 0.25, 0.05, 0.05, 0.05],
            k=1
        )[0]
        
        orders.append({
            'order_id': order_id,
            'user_id': user['user_id'],
            'created_at': current_date.strftime('%Y-%m-%d %H:%M:%S'),
            'status': status
        })
        
        num_items = random.randint(1, 4)
        order_total = 0
        
        for _ in range(num_items):
            sale_price = round(random.uniform(15.0, 250.0), 2)
            order_total += sale_price
            
            order_items.append({
                'order_item_id': f"item_{item_counter}",
                'order_id': order_id,
                'product_id': f"prod_{random.randint(1, 150)}",
                'sale_price': sale_price
            })
            item_counter += 1
            
        if status in ['Complete', 'Shipped', 'Processing']:
            payment_status = 'Success'
        else:
            payment_status = random.choice(['Failed', 'Refunded'])
            
        payments.append({
            'payment_id': f"pay_{payment_counter}",
            'order_id': order_id,
            'status': payment_status,
            'amount': round(order_total, 2),
            'payment_method': random.choice(['Credit Card', 'PayPal', 'Apple Pay'])
        })
        
        order_counter += 1
        payment_counter += 1
        current_date += timedelta(days=random.randint(15, 90))

fct_orders = pd.DataFrame(orders)
fct_order_items = pd.DataFrame(order_items)
fct_payments = pd.DataFrame(payments)

# ---------------------------------------------------------
# 3. Export to CSV
# ---------------------------------------------------------
print("Exporting to CSV...")
dim_users.to_csv(f'{OUTPUT_DIR}/dim_users.csv', index=False)
fct_orders.to_csv(f'{OUTPUT_DIR}/fct_orders.csv', index=False)
fct_order_items.to_csv(f'{OUTPUT_DIR}/fct_order_items.csv', index=False)
fct_payments.to_csv(f'{OUTPUT_DIR}/fct_payments.csv', index=False)

print(f"\n✅ Generation Complete! Files saved in '{OUTPUT_DIR}/' folder.")
