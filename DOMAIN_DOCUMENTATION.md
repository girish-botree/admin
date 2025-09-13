# Domain Documentation

## Recipe Management

### Recipe Categories

The application supports the following recipe categories:

- **Breakfast**: Morning meals, typically lighter and higher in carbohydrates
- **Lunch**: Midday meals, balanced in macronutrients
- **Dinner**: Evening meals, typically protein-rich with moderate carbohydrates
- **Snacks**: Small portions meant for between-meal consumption
- **Desserts**: Sweet dishes, typically served after main meals
- **Beverages**: Drinks, both alcoholic and non-alcoholic

### Recipe Attributes

Each recipe includes the following attributes:

- **Name**: Unique identifier for the recipe
- **Description**: Brief explanation of the dish
- **Ingredients**: List of ingredients with quantities
- **Preparation Steps**: Detailed cooking instructions
- **Nutritional Information**: Calories, macronutrients, micronutrients
- **Cooking Time**: Time required for preparation and cooking
- **Difficulty Level**: Easy, Medium, Hard
- **Serving Size**: Number of servings the recipe yields
- **Images**: Visual representation of the prepared dish
- **Tags**: Keywords for recipe categorization and search

## Dietary Categories

The application classifies recipes into the following dietary categories:

### Main Dietary Types

- **Omnivore**: Contains all food groups, including meat, dairy, and plants
- **Vegetarian**: Excludes meat but may include dairy and eggs
- **Vegan**: Excludes all animal products
- **Pescatarian**: Includes fish but excludes other meats
- **Flexitarian**: Primarily plant-based with occasional meat consumption

### Specific Dietary Restrictions

- **Gluten-Free**: Excludes gluten-containing ingredients
- **Dairy-Free**: Excludes milk and milk products
- **Nut-Free**: Excludes nuts and nut derivatives
- **Low-Carb**: Limited carbohydrate content
- **Keto-Friendly**: High fat, moderate protein, very low carbohydrate
- **Paleo**: Based on foods presumed to be available to paleolithic humans

## Vegan Category Guidelines

Vegan recipes must adhere to the following guidelines:

1. **Exclusions**: No animal products whatsoever (meat, fish, dairy, eggs, honey)
2. **Substitutions**: Appropriate plant-based alternatives for traditional animal ingredients
3. **Nutrition**: Balanced protein sources to ensure complete amino acid profiles
4. **Labeling**: Clear identification of potentially ambiguous ingredients
5. **Cross-Contamination**: Instructions to avoid cross-contamination with animal products

### Vegan Substitution Guide

| Traditional Ingredient | Vegan Alternative                    |
|------------------------|--------------------------------------|
| Cow's Milk             | Almond, soy, oat, or coconut milk    |
| Butter                 | Plant-based margarine or coconut oil |
| Eggs (binding)         | Flaxseed or chia seed mixture        |
| Eggs (leavening)       | Baking powder, aquafaba              |
| Honey                  | Maple syrup or agave nectar          |
| Gelatin                | Agar-agar or carrageenan             |
| Meat                   | Tofu, tempeh, seitan, or legumes     |

## Notification System Business Rules

The application implements a comprehensive notification system with the following business rules:

### Notification Types

1. **Order Updates**: Alerts about order status changes
2. **Delivery Updates**: Information about delivery status and tracking
3. **Promotional Notifications**: Special offers and promotions
4. **System Notifications**: Technical updates and maintenance alerts
5. **Reminder Notifications**: Scheduled reminders for planned actions

### Notification Triggers

- **Event-Based**: Triggered by specific system events
- **Time-Based**: Sent at predetermined times
- **User Action-Based**: Triggered by user interactions
- **Location-Based**: Triggered when users enter specific geographic areas

### Notification Delivery Rules

1. **Frequency Limits**: Maximum of 5 promotional notifications per week
2. **Quiet Hours**: No non-critical notifications between 10 PM and 7 AM user local time
3. **Priority System**: Critical notifications bypass user preference settings
4. **Bundling**: Similar notifications are grouped to reduce interruptions
5. **Personalization**: Content tailored based on user preferences and behavior

### User Preferences

Users can customize their notification experience with the following options:

- Enable/disable specific notification types
- Set preferred notification channels (push, email, SMS)
- Configure quiet hours
- Set notification frequency limits

## Search Functionality Requirements

The application's search functionality implements the following requirements:

### Search Scopes

- **Global Search**: Searches across all application content
- **Recipe Search**: Limited to recipe-related content
- **Ingredient Search**: Focused on ingredients
- **User Search**: For administrator use to find specific users

### Search Features

1. **Keyword Search**: Basic text-based search
2. **Filters**: Refine results by category, dietary restrictions, cooking time, etc.
3. **Advanced Search**: Complex queries with multiple parameters
4. **Voice Search**: Input search terms via voice recognition
5. **Search History**: Record and suggest previous searches
6. **Autocomplete**: Suggest search terms as user types

### Search Algorithm Requirements

- **Fuzzy Matching**: Handle typos and spelling variations
- **Synonym Support**: Recognize equivalent terms
- **Relevance Ranking**: Sort results by relevance to query
- **Performance**: Return initial results in under 500ms
- **Scalability**: Handle increasing content without performance degradation

## Data Models and Relationships

### Core Entities

1. **User**: End-users of the application
2. **Recipe**: Cooking instructions and ingredients
3. **Ingredient**: Food items used in recipes
4. **MealPlan**: Scheduled arrangement of recipes
5. **Order**: User request for meal delivery
6. **DeliveryPerson**: Personnel responsible for order delivery
7. **Admin**: System administrators

### Entity Relationships

- **User-MealPlan**: One-to-many (a user can have multiple meal plans)
- **MealPlan-Recipe**: Many-to-many (a meal plan contains multiple recipes, a recipe can be in
  multiple meal plans)
- **Recipe-Ingredient**: Many-to-many (a recipe contains multiple ingredients, an ingredient can be
  in multiple recipes)
- **User-Order**: One-to-many (a user can place multiple orders)
- **Order-DeliveryPerson**: Many-to-one (multiple orders can be assigned to one delivery person)

### Data Validation Rules

- **Email**: Must follow standard email format
- **Phone Numbers**: Must follow E.164 format
- **Passwords**: Minimum 8 characters with at least one uppercase, one lowercase, one number, and
  one special character
- **Nutritional Values**: Must be non-negative numbers
- **Dates**: Must be valid calendar dates in ISO 8601 format

## Business Logic Specifications

### Recipe Management Logic

1. **Recipe Creation**: Admins can create and edit recipes
2. **Recipe Approval**: New recipes require approval before publication
3. **Duplicate Detection**: System identifies similar recipes to prevent duplicates
4. **Ingredient Substitution**: System suggests alternative ingredients based on dietary
   restrictions
5. **Scaling Logic**: Automatically adjust ingredient quantities based on serving size

### Meal Planning Logic

1. **Nutritional Balance**: Ensure daily meal plans meet nutritional guidelines
2. **Variety Enforcement**: Prevent repetition of the same recipe within 3 days
3. **Preference Matching**: Match meal plans to user dietary preferences
4. **Seasonal Adjustments**: Prioritize seasonal ingredients
5. **Budget Considerations**: Optimize ingredient cost while maintaining quality

### Delivery Management Logic

1. **Route Optimization**: Calculate efficient delivery routes
2. **Time Window Management**: Assign deliveries to specific time windows
3. **Capacity Planning**: Manage delivery personnel workload
4. **Exception Handling**: Protocols for delivery issues (delays, cancellations)
5. **Performance Tracking**: Monitor delivery metrics (on-time rate, customer satisfaction)

## User Workflows

### Admin User Workflows

1. **Recipe Management**:
    - Create new recipes
    - Edit existing recipes
    - Categorize recipes
    - Manage recipe images

2. **Delivery Management**:
    - Monitor delivery status
    - Assign deliveries to personnel
    - Handle delivery exceptions
    - Generate delivery reports

3. **User Management**:
    - View user accounts
    - Handle user issues
    - Manage user permissions

4. **Analytics and Reporting**:
    - Generate usage reports
    - Analyze user behavior
    - Monitor system performance

### Delivery Person Workflows

1. **Delivery Assignment**:
    - Receive delivery assignments
    - View delivery details and routes
    - Accept or request reassignment

2. **Delivery Execution**:
    - Navigate to delivery locations
    - Confirm deliveries
    - Document delivery exceptions

3. **Status Reporting**:
    - Update delivery status
    - Report issues or delays
    - Complete delivery documentation

## Feature Requirements

### Core Features

1. **Recipe Database**: Comprehensive collection of recipes with search and filtering
2. **Meal Planning**: Tools for creating and managing meal plans
3. **Delivery Management**: System for coordinating food deliveries
4. **User Management**: Administration of user accounts and permissions
5. **Reporting and Analytics**: Data analysis and report generation

### Feature Details

#### Recipe Database

- Support for at least 10,000 recipes
- Multiple high-resolution images per recipe
- Comprehensive nutritional information
- User ratings and reviews
- Recipe version history

#### Meal Planning

- Calendar-based meal scheduling
- Nutritional analysis of meal plans
- Automatic shopping list generation
- Dietary restriction accommodation
- Meal plan sharing and exporting

#### Delivery Management

- Real-time delivery tracking
- Delivery personnel assignment
- Delivery time estimation
- Proof of delivery capture
- Customer satisfaction tracking

#### User Management

- Role-based access control
- User activity auditing
- Password reset and account recovery
- Multi-factor authentication
- Session management and security