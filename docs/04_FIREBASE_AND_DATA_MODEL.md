# For Rent Firebase And Data Model

## Firebase Authentication Usage

For Rent uses Firebase Authentication with email/password accounts for tenants and landlords. Guest browsing is local-only and does not create a Firebase account. On launch, `AuthViewModel` listens to Firebase auth state and fetches the matching Firestore profile from `users/{uid}`.

## Firestore Collections

- `users`
- `properties`
- `requests`

## User Model

File: `For Rent/Models/AppUser.swift`

Fields:

- `id`: Firebase Auth UID and Firestore document ID.
- `email`: user email.
- `role`: `guest`, `tenant`, or `landlord`.
- `firstName`
- `lastName`
- `phone`
- `shortlisted`: array of property IDs saved by the tenant.

## Property Model

File: `For Rent/Models/Property.swift`

Fields:

- `id`: property document ID.
- `title`
- `details`
- `rent`
- `bedrooms`
- `bathrooms`
- `latitude`
- `longitude`
- `imageNames`: local image filenames.
- `landlordId`: owner user ID.
- `isListed`: whether it appears publicly.
- `isAssigned`: whether it has been accepted/assigned.

## Request Model

File: `For Rent/Models/Request.swift`

Fields:

- `id`: request document ID.
- `propertyId`
- `landlordId`
- `tenantId`
- `tenantName`
- `tenantPhone`
- `status`: `pending`, `accepted`, or `rejected`.

## Shortlist/Favorite Model

Shortlist is stored as an array of property IDs on `users/{uid}.shortlisted`, with local cache in `UserDefaults` for quick UI state.

## Role Model

File: `For Rent/Models/Enums.swift`

Roles:

- `guest`: browse/detail/share only.
- `tenant`: browse, save, request, view sent requests.
- `landlord`: add/update/delete/de-list properties and accept/deny requests.

## Data Relationships

- One user can own many properties through `Property.landlordId`.
- One tenant can create many requests through `Request.tenantId`.
- One landlord receives many requests through `Request.landlordId`.
- One property can have many requests, but accepted request marks the property assigned and unlisted.

## CRUD Operations

- Create user: `FirestoreService.createUser`
- Fetch user: `FirestoreService.fetchUser`
- Update user: `FirestoreService.updateUser`
- Fetch available properties: `FirestoreService.fetchListedProperties`
- Fetch landlord-owned properties: `FirestoreService.fetchLandlordProperties`
- Add property: `FirestoreService.addProperty`
- Update property: `FirestoreService.updateProperty`
- Delete property: `FirestoreService.deleteProperty`
- De-list/list property: `FirestoreService.updatePropertyListing`
- Create request: `FirestoreService.createRequest`
- Listen to requests: `FirestoreService.listenToRequests`
- Update request status: `FirestoreService.updateRequestStatus`
- Add/remove shortlist: `updateShortlist`, `removeFromShortlist`

## Query Scoping

- Tenant and guest property browsing queries only listed and unassigned properties.
- Landlord inventory queries only properties where `landlordId` matches the signed-in user.
- Request listeners query by `tenantId` for tenants and `landlordId` for landlords.
- Request creation uses deterministic IDs in the shape `{tenantId}_{propertyId}` to block duplicate pending requests for the same tenant/property pair.

## Security Considerations

- Real `GoogleService-Info.plist` must not be committed.
- `firestore.rules` is included as a public-safe baseline for role-based access.
- Firestore rules should enforce ownership, not only UI checks.
- Landlords should write only their own properties.
- Tenants should write only their own requests and shortlist.
- Guests should have read access only to listed/unassigned properties if public browsing is intended.
- Request acceptance should be restricted to the landlord who owns the request/property.

## Local Setup Notes

1. Create a Firebase project.
2. Add an iOS app with bundle ID `com.yashkanadhia.ForRent`.
3. Enable Authentication -> Email/Password.
4. Enable Firestore.
5. Download `GoogleService-Info.plist`.
6. Place it at `For Rent/Services/GoogleService-Info.plist` for local builds.
7. Do not commit the real plist.
8. Use `For Rent/Services/GoogleService-Info.example.plist` as the public template.
9. Review and deploy `firestore.rules` for shared Firebase environments.
