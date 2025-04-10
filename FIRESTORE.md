# E-Commerce App Firestore Structure

## Collections

### users
Stores user information and permissions.

**Fields:**
- `uid` (string): User ID
- `email` (string): User email
- `display_name` (string): User display name
- `photo_url` (string): URL to user profile photo
- `role` (string): User role ("customer", "seller", or "admin") 
- `created_at` (timestamp): When the user was created
- `last_login` (timestamp): When the user last logged in
- `is_active` (boolean): Whether the user account is active

### products
Stores product information.

**Fields:**
- `id` (string): Product ID
- `name` (string): Product name
- `price` (number): Product price
- `description` (string): Product description
- `imageUrl` (string): URL to product image
- `category` (string): Product category
- `rating` (number): Product rating
- `isFavorite` (boolean): Whether the product is a favorite
- `stock` (number): Available stock
- `sellerId` (string): ID of the seller who owns the product

### orders
Stores order information.

**Fields:**
- `id` (string): Order ID
- `date` (timestamp): When the order was placed
- `status` (number): Order status (0: pending, 1: processing, 2: shipped, 3: delivered, 4: cancelled)
- `items` (number): Number of items in the order
- `total` (number): Total price of the order
- `customerId` (string): ID of the customer who placed the order
- `sellerIds` (array): Array of seller IDs involved in the order

## Indexes

### Orders Indexes

1. **Customer Orders Index**
   - Collection: `orders`
   - Fields:
     - `customerId` (Ascending)
     - `date` (Descending)
   - Purpose: Efficiently retrieve all orders for a specific customer, sorted by date

2. **Seller Orders Index**
   - Collection: `orders`
   - Fields:
     - `sellerIds` (Array contains)
     - `date` (Descending)
   - Purpose: Efficiently retrieve all orders that involve a specific seller, sorted by date

3. **Orders by Status Index**
   - Collection: `orders`
   - Fields:
     - `status` (Ascending)
     - `date` (Descending)
   - Purpose: Retrieve orders with a specific status, sorted by date

### Products Indexes

1. **Seller Products by Category Index**
   - Collection: `products`
   - Fields:
     - `sellerId` (Ascending)
     - `category` (Ascending)
   - Purpose: Efficiently retrieve products for a specific seller, filtered by category

2. **Products by Category and Price Index**
   - Collection: `products`
   - Fields:
     - `category` (Ascending)
     - `price` (Ascending)
   - Purpose: Retrieve products in a specific category, sorted by price

3. **Products by Category and Rating Index**
   - Collection: `products`
   - Fields:
     - `category` (Ascending)
     - `rating` (Descending)
   - Purpose: Retrieve products in a specific category, sorted by rating

## Deploying Indexes

To deploy these indexes to Firebase:

1. Make sure you have the Firebase CLI installed:
   ```
   npm install -g firebase-tools
   ```

2. Log in to Firebase:
   ```
   firebase login
   ```

3. Run the deployment script:
   ```
   deploy_firestore_indexes.bat
   ```

4. Or deploy manually:
   ```
   firebase deploy --only firestore:indexes
   ```

## Access Rules

The Firestore security rules should ensure that:

1. Customers can only access their own user data and orders
2. Sellers can access their own products and orders related to their products
3. Admins have full access to all collections

These rules should be defined in a `firestore.rules` file and deployed alongside the indexes. 