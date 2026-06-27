# User Flows

## Guest Flow

1. Open the app without signing in.
2. Continue as guest.
3. Browse listed and unassigned properties.
4. Open property details.
5. Share a property.
6. Sign in as a tenant to save or request a property.

## Tenant Flow

1. Create an account or log in as a tenant.
2. Browse listed and unassigned properties.
3. Search listings or filter by max rent.
4. Open a property detail screen.
5. Save or remove the property from shortlist.
6. Send a rental request.
7. Track the inquiry from submitted through acknowledgement, viewing,
   acceptance, rejection, cancellation, or expiry.
8. Update profile details from the profile screen.

## Landlord Flow

1. Create an account or log in as a landlord.
2. Add a rental property with title, details, rent, bedrooms, bathrooms, images, and location.
3. View only properties owned by the logged-in landlord.
4. Update listing details.
5. List, de-list, or delete a property.
6. Review incoming tenant requests.
7. Acknowledge inquiries, schedule viewings, and accept or reject eligible
   inquiries.
8. Accepted requests mark the related property as assigned and remove it from public browsing.

## Permission Expectations

- Guests can browse public listings but cannot save or request properties.
- Tenants can manage their own shortlist and requests.
- Landlords can manage only their own properties and requests.
- Firestore rules should enforce these boundaries in addition to app-side role checks.
